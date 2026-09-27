# Naming, tags, image refs, and the demo user list — centralized so every resource stays consistent.
locals {
  # e.g. "healthcloud-demo" — distinct from the ECS stack's "healthcloud-dev".
  name_prefix = "${var.project}-${var.environment}"

  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
    Stack       = "ec2-demo" # makes it obvious in the console this is the always-on box, not the ECS showcase
  }

  # The app container images CI publishes to GHCR (must be public — see README prerequisites).
  backend_image  = "ghcr.io/${var.github_owner}/healthcloud-backend:${var.image_tag}"
  frontend_image = "ghcr.io/${var.github_owner}/healthcloud-frontend:${var.image_tag}"

  # Public URLs (Caddy serves HTTPS on the apex domain; the OIDC callback path is Spring's default).
  app_url      = "https://${var.domain_name}"
  redirect_uri = "https://${var.domain_name}/login/oauth2/code/cognito"
  logout_uri   = "https://${var.domain_name}/"

  # The 14 synthetic demo users, one per seeded AppUser email (both orgs × 7 roles). Cognito needs a
  # matching user for each so a recruiter can sign in as any role. Passwords are NOT set here (that
  # would land in state) — a documented post-apply script sets the SAME published synthetic passwords
  # the login page shows (see README). Emails are ${role}@${org-domain}.
  demo_user_emails = [
    "patient@northcare.example.org",
    "provider@northcare.example.org",
    "provider2@northcare.example.org",
    "coordinator@northcare.example.org",
    "reviewer@northcare.example.org",
    "admin@northcare.example.org",
    "auditor@northcare.example.org",
    "patient@greenvalley.example.org",
    "provider@greenvalley.example.org",
    "provider2@greenvalley.example.org",
    "coordinator@greenvalley.example.org",
    "reviewer@greenvalley.example.org",
    "admin@greenvalley.example.org",
    "auditor@greenvalley.example.org",
  ]
}
