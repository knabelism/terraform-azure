terraform {
    backend "remote" {
        organization = "akauto"
        workspaces {
            name = "akauto-tf-tower"
        }
    }
}