# ── The EC2 box that runs the always-on demo ─────────────────────────────────────────
# One t3.small (x86_64, 2 GB) running Amazon Linux 2023, bootstrapped by user-data to install Docker +
# Compose and bring up the whole app (Postgres + backend + frontend + Caddy). x86_64 (NOT Graviton):
# the GHCR images CI publishes are linux/amd64 only, so the box must be x86_64 to run them. 2 GB (not
# t3.micro's 1 GB, which OOMs) + a 2 GB swapfile + a capped JVM heap. An Elastic IP gives it a stable
# address the custom domain's A record points at.

# Latest Amazon Linux 2023 x86_64 AMI, resolved from the SSM public parameter (no hardcoded AMI id).
data "aws_ssm_parameter" "al2023_x86_64" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "demo" {
  ami                    = data.aws_ssm_parameter.al2023_x86_64.value
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.web.id]
  iam_instance_profile   = aws_iam_instance_profile.instance.name

  user_data = templatefile("${path.module}/templates/user-data.sh.tftpl", {
    region          = var.aws_region
    env_param_name  = aws_ssm_parameter.env.name
    compose_content = file("${path.module}/docker-compose.yml")
    caddy_content   = file("${path.module}/Caddyfile")
  })

  # Re-run the bootstrap (recreate the instance) when the user-data changes — e.g. new image tag.
  user_data_replace_on_change = true

  root_block_device {
    volume_size = var.root_volume_gb
    volume_type = "gp3"
    encrypted   = true
  }

  # Require IMDSv2 (token-based metadata) — blocks the classic SSRF-to-metadata credential theft path.
  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  tags = { Name = "${local.name_prefix}-app" }
}

# Stable public IP (free while attached to a running instance). Point the domain's A record here.
resource "aws_eip" "demo" {
  domain   = "vpc"
  instance = aws_instance.demo.id
  tags     = { Name = "${local.name_prefix}-eip" }
}
