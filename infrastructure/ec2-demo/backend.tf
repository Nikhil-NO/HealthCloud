# Terraform state for the always-on demo.
#
# Reuses the SAME S3 bucket the ECS stack created (infrastructure/terraform/bootstrap), but under a
# DIFFERENT key — so the two configs have completely independent state and never step on each other.
# The bucket is versioned + encrypted + private, with S3-native locking (no DynamoDB).
#
# `terraform init` needs AWS creds (it reads/writes remote state). For offline `validate`, use
# `terraform init -backend=false`.
terraform {
  backend "s3" {
    bucket       = "healthcloud-tfstate-927747714796"
    key          = "healthcloud/ec2-demo/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
