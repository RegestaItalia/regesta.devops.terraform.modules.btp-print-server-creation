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

# -------------------
# DATA SOURCE
# -------------------
data "btp_subaccount" "current" {
  id = var.subaccountid
}

# -------------------
# ENTITLEMENTS & SUBSCRIPTION
# -------------------
resource "btp_subaccount_entitlement" "print-app" {
  subaccount_id = var.subaccountid
  service_name  = "print-app"
  plan_name     = "standard"
}
resource "btp_subaccount_entitlement" "print-receiver" {
  subaccount_id = var.subaccountid
  service_name  = "print"
  plan_name     = "receiver"
}
resource "btp_subaccount_entitlement" "print-sender" {
  subaccount_id = var.subaccountid
  service_name  = "print"
  plan_name     = "sender"
}

# -------------------
# PRINT SERVER UI INTEGRATION
# -------------------
resource "btp_subaccount_subscription" "print-app" {
  depends_on    = [btp_subaccount_entitlement.print-app]
  subaccount_id = var.subaccountid
  app_name      = "print-app"
  plan_name     = "standard"
}

# -------------------
# CLOUD FOUNDRY SERVICES
# -------------------
data "cloudfoundry_service_plan" "print-sender" {
  depends_on            = [btp_subaccount_entitlement.print-sender]
  name                  = "sender"
  service_offering_name = "print"
}

resource "cloudfoundry_service_instance" "print-sender" {
  name         = "print_snd"
  type         = "managed"
  space        = var.spaceid
  service_plan = data.cloudfoundry_service_plan.print-sender.id
}

resource "cloudfoundry_service_credential_binding" "print-sender-key" {
  type             = "key"
  name             = "print-sender-key"
  service_instance = cloudfoundry_service_instance.print-sender.id
}

data "cloudfoundry_service_plan" "print-receiver" {
  depends_on            = [btp_subaccount_entitlement.print-receiver]
  name                  = "receiver"
  service_offering_name = "print"
}

resource "cloudfoundry_service_instance" "print-receiver" {
  name         = "print_rcv"
  type         = "managed"
  space        = var.spaceid
  service_plan = data.cloudfoundry_service_plan.print-receiver.id
}

resource "cloudfoundry_service_credential_binding" "print-receiver-key" {
  type             = "key"
  name             = "print-receiver-key"
  service_instance = cloudfoundry_service_instance.print-receiver.id
}

# -------------------
# OUTPUT
# -------------------
output "sender-service-key" {
  value     = cloudfoundry_service_credential_binding.print-sender-key
  sensitive = true
}

output "receiver-service-key" {
  value     = cloudfoundry_service_credential_binding.print-receiver-key
  sensitive = true
}
