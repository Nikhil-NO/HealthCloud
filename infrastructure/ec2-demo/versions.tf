# Toolchain + provider pins for the ALWAYS-ON portfolio demo (post-roadmap, 2026-09).
#
# This is a SEPARATE, self-contained Terraform config from infrastructure/terraform/ (the on-demand
# ECS/Fargate showcase). It stands up one cheap EC2 box that runs the whole app 24/7 behind a custom
# domain, so the resume/LinkedIn link is always clickable — see README.md. It shares NOTHING with the
# ECS stack (its own state, its own Cognito pool), so destroying that stack never breaks this demo.
terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    # Generates the Postgres + audit-HMAC secrets so no secret is ever hand-written into config.
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # State backend lives in backend.tf (the same S3 bucket the ECS stack uses, but a DIFFERENT key,
  # so the two states never collide).
}
