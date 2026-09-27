output "elastic_ip" {
  description = "The box's stable public IP. Create an A record: healthcloud-demo.com → this IP (and www → this IP)."
  value       = aws_eip.demo.public_ip
}

output "instance_id" {
  description = "EC2 instance id (for SSM Session Manager: `aws ssm start-session --target <id>`)."
  value       = aws_instance.demo.id
}

output "app_url" {
  description = "The public HTTPS URL (live once DNS points at the Elastic IP and Caddy issues the cert)."
  value       = local.app_url
}

output "cognito_user_pool_id" {
  description = "Cognito user pool id (needed by the post-apply set-passwords script)."
  value       = aws_cognito_user_pool.main.id
}

output "cognito_client_id" {
  description = "Cognito app client id."
  value       = aws_cognito_user_pool_client.app.id
}

output "cognito_hosted_ui_domain" {
  description = "Cognito hosted login page."
  value       = "https://${aws_cognito_user_pool_domain.main.domain}.auth.${var.aws_region}.amazoncognito.com"
}

# A ready-to-follow checklist printed after apply, so the manual DNS + password steps are obvious.
output "next_steps" {
  description = "What to do after apply."
  value       = <<-EOT
    1. DNS (at Namecheap): add an A record  @ -> ${aws_eip.demo.public_ip}  and  www -> ${aws_eip.demo.public_ip}
    2. Wait for DNS to propagate, then Caddy auto-issues HTTPS for ${var.domain_name} (a few minutes).
    3. Set the 14 demo passwords in Cognito: run ./set-demo-passwords.sh ${aws_cognito_user_pool.main.id}
    4. Open ${local.app_url} and sign in with any role (published synthetic passwords on the login page).
    Debug shell (no SSH): aws ssm start-session --target ${aws_instance.demo.id}
  EOT
}
