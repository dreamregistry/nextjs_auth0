terraform {
  backend "s3" {}

  required_providers {
    random = {
      source  = "registry.terraform.io/hashicorp/random"
      version = "3.2.0"
    }

    auth0 = {
      source  = "registry.terraform.io/auth0/auth0"
      version = "0.32.0"
    }
  }
}

provider "random" {}
provider "auth0" {}

resource "random_pet" "client_name" {}

resource "auth0_client" "client" {
  name                = random_pet.client_name.id
  description         = "Application configured for nextJS"
  app_type            = "regular_web"
  is_first_party      = true
  callbacks           = ["http://${var.app_host}/api/auth/callback"]
  allowed_logout_urls = ["http://${var.app_host}", "http://${var.app_host}/auth/logout"]
  jwt_configuration {
    alg = "RS256"
  }
}

output "AUTH0_CLIENT_ID" {
  sensitive = true
  value     = auth0_client.client.client_id
}

output "AUTH0_CLIENT_SECRET" {
  sensitive = true
  value     = auth0_client.client.client_secret
}

data "auth0_tenant" "current" {}

output "AUTH0_ISSUER_BASE_URL" {
  sensitive = true
  value     = "https://${data.auth0_tenant.current.domain}"
}

output "AUTH0_BASE_URL" {
  sensitive = true
  value     = "http://${var.app_host}"
}

resource "random_uuid" "secret" {}

output "AUTH0_SECRET" {
  sensitive = true
  value     = random_uuid.secret.result
}
