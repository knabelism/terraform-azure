variable "vm_prefix" {
  default = "knabelism-vm"
}

variable "server_count" {
  default = "0"
  # default = "1"
  # default = "2"
  # default = "3"
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