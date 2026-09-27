# AWS provider for the always-on demo. default_tags stamps every taggable resource so the console
# clearly shows this stack is a separate, Terraform-managed thing from the ECS showcase.
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}
