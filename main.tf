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

data "aws_region" "current" {}
data "auth0_tenant" "current" {}

resource "random_pet" "client_name" {}

resource "auth0_client" "client" {
  name                = random_pet.client_name.id
  description         = "Application configured for nextJS"
  app_type            = "regular_web"
  is_first_party      = true
  callbacks           = ["${var.app_host}/api/auth/callback"]
  allowed_logout_urls = [var.app_host, "${var.app_host}/auth/logout"]
  jwt_configuration {
    alg = "RS256"
  }
}

resource "aws_ssm_parameter" "client_secret" {
  name        = "/auth0_cli/${auth0_client.client.name}/client-secret"
  description = "The auth0 client secret"
  type        = "SecureString"
  value       = auth0_client.client.client_secret
}

resource "aws_ssm_parameter" "auth0_secret" {
  name        = "/auth0_cli/${auth0_client.client.name}/auth0-secret"
  description = "The auth0 sdk session secret"
  type        = "SecureString"
  value       = random_uuid.secret.result
}

resource "random_uuid" "secret" {}


output "AUTH0_CLIENT_ID" {
  sensitive = true
  value     = auth0_client.client.client_id
}

output "AUTH0_CLIENT_SECRET" {
  value = {
    type   = "ssm"
    arn    = aws_ssm_parameter.client_secret.arn
    key    = aws_ssm_parameter.client_secret.name
    region = data.aws_region.current.name
  }
}

output "AUTH0_ISSUER_BASE_URL" {
  value = "https://${data.auth0_tenant.current.domain}"
}

output "AUTH0_BASE_URL" {
  value = var.app_host
}


output "AUTH0_SECRET" {
  value = {
    type   = "ssm"
    arn    = aws_ssm_parameter.auth0_secret.arn
    key    = aws_ssm_parameter.auth0_secret.name
    region = data.aws_region.current.name
  }
}
