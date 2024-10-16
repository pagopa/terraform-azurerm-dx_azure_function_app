locals {
  location_short  = var.environment.location == "italynorth" ? "itn" : var.environment.location == "westeurope" ? "weu" : var.environment.location == "germanywestcentral" ? "gwc" : "neu"
  project         = "${var.environment.prefix}-${var.environment.env_short}-${local.location_short}"
  domain          = var.environment.domain == null ? "-" : "-${var.environment.domain}-"
  app_name_prefix = "${local.project}${local.domain}${var.environment.app_name}"

  subnet = {
    enable_service_endpoints = var.subnet_service_endpoints != null ? concat(
      var.subnet_service_endpoints.cosmos ? ["Microsoft.CosmosDB"] : [],
      var.subnet_service_endpoints.web ? ["Microsoft.Web"] : [],
      var.subnet_service_endpoints.storage ? ["Microsoft.Storage"] : [],
    ) : []
    name = "${local.app_name_prefix}-func-snet-${var.environment.instance_number}"
  }

  app_service_plan = {
    enable = var.app_service_plan_id == null
    name   = "${local.app_name_prefix}-asp-${var.environment.instance_number}"
  }

  function_app = {
    name                   = "${local.app_name_prefix}-func-${var.environment.instance_number}"
    sku_name               = local.sku_name_mapping[local.tier]
    zone_balancing_enabled = local.tier != "s"
    is_slot_enabled        = local.tier == "s" ? 0 : 1
    pep_sites              = "${local.app_name_prefix}-func-pep-${var.environment.instance_number}"
    pep_sites_staging      = "${local.app_name_prefix}-staging-func-pep-${var.environment.instance_number}"
    alert                  = "${local.app_name_prefix}-func-${var.environment.instance_number}] Health Check Failed"
    worker_process_count   = local.worker_process_count_mapping[local.tier]
  }

  function_app_slot = {
    name = "staging"
  }

  application_insights = {
    enable = var.application_insights_connection_string != null
  }

  storage_account = {
    replication_type = local.tier == "s" ? "LRS" : "ZRS"
    name             = replace("${local.project}${replace(local.domain, "-", "")}${var.environment.app_name}stfn${var.environment.instance_number}", "-", "")
    pep_blob_name    = "${local.app_name_prefix}-blob-pep-${var.environment.instance_number}"
    pep_file_name    = "${local.app_name_prefix}-file-pep-${var.environment.instance_number}"
    pep_queue_name   = "${local.app_name_prefix}-queue-pep-${var.environment.instance_number}"
    alert            = "[${replace("${local.project}${replace(local.domain, "-", "")}${var.environment.app_name}stfn${var.environment.instance_number}", "-", "")}] Low Availability"
  }

  private_dns_zone = {
    resource_group_name = var.private_dns_zone_resource_group_name == null ? var.virtual_network.resource_group_name : var.private_dns_zone_resource_group_name
  }
}
