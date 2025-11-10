terraform {
  required_providers {
    btp = {
      source  = "SAP/btp"
      version = "~>1.12.0"
    }
    cloudfoundry = {
      source  = "cloudfoundry/cloudfoundry"
      version = "1.9.0"
    }
  }
}

# -------------------
# VARIABILI
# -------------------
variable "subaccountid" {
  type = string
}

variable "spaceid" {
  type = string
}

variable "print-server-plan" {
  type    = string
  default = "default"
}

# -------------------
# DATA SOURCE
# -------------------
data "btp_subaccount" "current" {
  id = var.subaccountid
}

# -------------------
# ENTITLEMENTS & SUBSCRIPTION
# -------------------
resource "btp_subaccount_entitlement" "print-server" {
  subaccount_id = var.subaccountid
  service_name  = "print-server"
  plan_name     = var.print-server-plan
}

# -------------------
# CLOUD FOUNDRY SERVICES
# -------------------
data "cloudfoundry_service_plan" "print-server" {
  depends_on            = [btp_subaccount_entitlement.print-server]
  name                  = var.print-server-plan
  service_offering_name = "print-server"
}

resource "cloudfoundry_service_instance" "print-server" {
  name         = "print-server"
  type         = "managed"
  space        = var.spaceid
  service_plan = data.cloudfoundry_service_plan.print-server.id
}

resource "cloudfoundry_service_credential_binding" "print-server-key" {
  type             = "key"
  name             = "print-server-key"
  service_instance = cloudfoundry_service_instance.print-server.id
}

# -------------------
# OUTPUT
# -------------------
output "service-key" {
  value     = cloudfoundry_service_credential_binding.print-server-key
  sensitive = true
}
