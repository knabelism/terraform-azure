terraform {
  backend "remote" {
    organization = "akauto"
    workspaces {
      name = "automation_platform"
    }
  }
}