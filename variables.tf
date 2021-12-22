variable "vm_prefix" {
  default = "automation-platform"
}

variable "server_count" {
  # default = "3"
  default = "1"
}

variable "admin_username" {
  default = "knabelism"
}

variable "resourcegroup" {
  type = string
}

variable "location" {
  type = string
}

variable "subscriptionID" {
  type = string
}

variable "clientID" {
  type = string
}

variable "clientSecret" {
  type = string
}

variable "tenantID" {
  type = string
}

