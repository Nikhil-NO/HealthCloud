# Security group for the demo box: only the public web ports are open. There is deliberately NO SSH
# (port 22) ingress — shell access is via AWS Systems Manager Session Manager (see iam.tf), so there
# is no key pair to manage and no open SSH port to attack.
resource "aws_security_group" "web" {
  name        = "${local.name_prefix}-web"
  description = "Public HTTP/HTTPS for the always-on HealthCloud demo (no SSH; SSM for shell)."
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description      = "HTTP (Caddy serves the ACME challenge here and redirects to HTTPS)"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTPS (the app)"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description      = "All outbound (pull images from GHCR, reach Cognito/ACME/SSM)"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = { Name = "${local.name_prefix}-web" }
}
