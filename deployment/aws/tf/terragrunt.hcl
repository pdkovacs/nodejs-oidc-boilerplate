remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "bitkitchen-tf-state"
    key    = "nodejs-boilerplate/apigw-private-integration/${path_relative_to_include()}"
    region = "eu-west-1"
    encrypt        = true
  }
}

generate "versions" {
  path = "versions.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
}
provider "aws" {
  alias  = "global"
  region = "us-east-1"
}
EOF
}

terraform {
  extra_arguments "common_vars" {
    commands = ["plan", "apply", "destroy"]

    arguments = [
      "-var-file=../common.tfvars"
    ]
  }
}

inputs = {
  app_domain_name = get_env("APP_DOMAIN_NAME", "")
  acm_cert_domain = get_env("ACM_CERT_DOMAIN", "")
  app_name = get_env("APP_NAME", "nodejs-oidc-boilerplate-backend")
  app_version = get_env("APP_VERSION", "")
  testuser_password = get_env("NODE_OIDC_BPLATE_TEST_USER_PASSWORD")
  privileged_testuser_password = get_env("NODE_OIDC_BPLATE_PRIVILEGED_TEST_USER_PASSWORD")
}
