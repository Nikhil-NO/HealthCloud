# ── Amazon Cognito user pool for the always-on demo ──────────────────────────────────
# A DEDICATED pool, independent of the ECS stack's pool, so this demo owns its own login and a
# `terraform destroy` of the ECS stack never affects it. Same shape as the ECS cognito.tf (ADR-004:
# Cognito + Spring BFF), but its callback/logout URLs point at the custom HTTPS domain.
#
# Cost: $0 (Cognito free tier ≤ 50k MAU). Safe to leave up 24/7.

data "aws_caller_identity" "current" {}

resource "aws_cognito_user_pool" "main" {
  name = "${local.name_prefix}-users"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = false
  }

  # Users are admin-provisioned (below); no public self-signup. CognitoOidcUserService also rejects
  # any login with no ACTIVE AppUser, so this is defense in depth.
  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  mfa_configuration = "OPTIONAL"
  software_token_mfa_configuration {
    enabled = true
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  deletion_protection = "INACTIVE"
}

# Confidential app client (the Spring BFF holds the session). Callback/logout URLs are the HTTPS
# custom domain only — the demo is always served over Caddy TLS on that domain.
resource "aws_cognito_user_pool_client" "app" {
  name         = "${local.name_prefix}-bff"
  user_pool_id = aws_cognito_user_pool.main.id

  generate_secret = true

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid", "email", "profile"]
  supported_identity_providers         = ["COGNITO"]

  callback_urls = [local.redirect_uri]
  logout_urls   = [local.logout_uri]

  # Only the hosted-UI auth-code flow + refresh rotation (no direct password/SRP flows).
  explicit_auth_flows = ["ALLOW_REFRESH_TOKEN_AUTH"]

  prevent_user_existence_errors = "ENABLED"
}

# The free hosted login page: https://<prefix>-<account>.auth.<region>.amazoncognito.com
resource "aws_cognito_user_pool_domain" "main" {
  domain       = "${local.name_prefix}-${data.aws_caller_identity.current.account_id}"
  user_pool_id = aws_cognito_user_pool.main.id
}

# Hosted-UI branding (logo + CSS) for the sign-in page. This is otherwise AWS-only drift: Cognito stores
# UI customization per client, NOT in Terraform, so a recreated pool loses the HealthCloud branding and
# falls back to Cognito's plain default page. Declaring it here makes `terraform apply` restore the dark
# navy + teal theme and the logo automatically. The CSS + logo live beside this config in cognito-ui/
# (synthetic branding, safe to commit). The customizable class names are Cognito's fixed vocabulary.
resource "aws_cognito_user_pool_ui_customization" "app" {
  user_pool_id = aws_cognito_user_pool.main.id
  client_id    = aws_cognito_user_pool_client.app.id

  css        = file("${path.module}/cognito-ui/hosted-ui.css")
  image_file = filebase64("${path.module}/cognito-ui/logo.png")

  # The hosted-UI domain must exist before customization can attach to the pool.
  depends_on = [aws_cognito_user_pool_domain.main]
}

# The 14 synthetic demo users (one per seeded AppUser email). NO password here — a post-apply script
# sets the published synthetic passwords (see README). SUPPRESS = no invitation email.
resource "aws_cognito_user" "seed" {
  for_each = toset(local.demo_user_emails)

  user_pool_id   = aws_cognito_user_pool.main.id
  username       = each.value
  message_action = "SUPPRESS"

  attributes = {
    email          = each.value
    email_verified = "true"
  }
}
