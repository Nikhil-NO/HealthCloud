# Secrets + runtime config for the box, delivered via SSM Parameter Store (SecureString) rather than
# baked into user-data (which is readable from instance metadata). Terraform generates the DB and
# audit-HMAC secrets; the Cognito client secret comes from the client resource. All of it is rendered
# into a single .env parameter the instance reads once at boot (see templates/env.tftpl + user-data).

resource "random_password" "db" {
  length  = 24
  special = false # alphanumeric — avoids any shell/URL/JDBC quoting surprises on the box
}

resource "random_password" "audit_hmac" {
  length  = 48
  special = false
}

# The complete .env for the docker compose stack: non-secret config + the three secrets.
locals {
  env_file_content = templatefile("${path.module}/templates/env.tftpl", {
    backend_image  = local.backend_image
    frontend_image = local.frontend_image
    domain_name    = var.domain_name
    acme_email     = var.acme_email

    db_user     = "healthcloud"
    db_password = random_password.db.result
    audit_hmac  = random_password.audit_hmac.result

    cognito_client_id     = aws_cognito_user_pool_client.app.id
    cognito_client_secret = aws_cognito_user_pool_client.app.client_secret
    cognito_issuer_uri    = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.main.id}"
    cognito_hosted_ui     = "${aws_cognito_user_pool_domain.main.domain}.auth.${var.aws_region}.amazoncognito.com"
    redirect_uri          = local.redirect_uri
    logout_uri            = local.logout_uri
  })
}

resource "aws_ssm_parameter" "env" {
  name        = "/${local.name_prefix}/env"
  description = "docker compose .env for the always-on HealthCloud demo (config + secrets)."
  type        = "SecureString" # encrypted with the default aws/ssm KMS key
  value       = local.env_file_content

  tags = { Name = "${local.name_prefix}-env" }
}
