# Input variables for the always-on demo. Sensible defaults so `validate`/`plan` run with no tfvars;
# override in terraform.tfvars if any of these change.

variable "aws_region" {
  description = "AWS region to deploy into (keep it the same as the ECS stack)."
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project name; prefixes resource names and the Project tag."
  type        = string
  default     = "healthcloud"
}

variable "environment" {
  description = "Environment label (drives naming + the Environment tag). 'demo' keeps this stack's names distinct from the ECS 'dev' stack."
  type        = string
  default     = "demo"
}

variable "domain_name" {
  description = "The custom domain the demo is served on (apex). Its DNS A record is pointed at this box's Elastic IP after apply."
  type        = string
  default     = "healthcloud-demo.com"
}

variable "acme_email" {
  description = "Contact email Caddy registers with Let's Encrypt for the TLS cert (expiry notices). Your own address; overridable."
  type        = string
  default     = "oggunikhil174@gmail.com"
}

variable "instance_type" {
  description = "EC2 instance type. t3.small (x86_64, 2 GB) — matches the linux/amd64 GHCR images and has enough RAM for Postgres + JVM + nginx + Caddy (t3.micro's 1 GB OOMs). Drawn from credits."
  type        = string
  default     = "t3.small"
}

variable "root_volume_gb" {
  description = "Root EBS volume size (GB). Holds the OS, Docker images, and the Postgres data volume."
  type        = number
  default     = 20
}

variable "github_owner" {
  description = "GHCR owner (lowercase) the app images are published under by CI. Images: ghcr.io/<owner>/healthcloud-backend|frontend."
  type        = string
  default     = "nikhil-oggu"
}

variable "image_tag" {
  description = "The GHCR image tag to run. 'latest' tracks main; pin to a sha-<short> tag for an immutable deploy."
  type        = string
  default     = "latest"
}

variable "state_bucket" {
  description = "S3 bucket that holds Terraform state (created once by infrastructure/terraform/bootstrap; reused here under a different key)."
  type        = string
  default     = "healthcloud-tfstate-927747714796"
}
