#!/usr/bin/env bash
# Post-apply step: set permanent passwords for the 14 synthetic Cognito demo users.
#
# Passwords cannot live in Terraform (they would land in state), so they are set here via the AWS CLI.
# These are the SAME synthetic passwords the login page publishes (frontend/src/auth/LoginPage.tsx) —
# intentionally public so recruiters can self-serve. They reach only synthetic, tenant-isolated data.
#
# Usage:  ./set-demo-passwords.sh <user-pool-id>
#   e.g.  ./set-demo-passwords.sh "$(terraform output -raw cognito_user_pool_id)"
set -euo pipefail

POOL_ID="${1:-}"
if [[ -z "$POOL_ID" ]]; then
  echo "usage: $0 <user-pool-id>   (e.g. \$(terraform output -raw cognito_user_pool_id))" >&2
  exit 1
fi

# "email password" pairs — must match LoginPage.tsx ORGS[*].passwords exactly. A plain indexed array
# (not an associative one) so this works on macOS's stock bash 3.2, which has no `declare -A`.
USERS=(
  "patient@northcare.example.org Samnorthcare123"
  "provider@northcare.example.org Northcare123"
  "provider2@northcare.example.org Providernc123"
  "coordinator@northcare.example.org Coordinatornc123"
  "reviewer@northcare.example.org Reviewernc123"
  "admin@northcare.example.org Adminnc123"
  "auditor@northcare.example.org Auditornc123"
  "patient@greenvalley.example.org Samgv123"
  "provider@greenvalley.example.org Greenvalley123"
  "provider2@greenvalley.example.org Providergv123"
  "coordinator@greenvalley.example.org Coordinatorgv123"
  "reviewer@greenvalley.example.org Reviewergv123"
  "admin@greenvalley.example.org Admingc123"
  "auditor@greenvalley.example.org Auditorgv123"
)

for pair in "${USERS[@]}"; do
  email="${pair%% *}"    # everything before the first space
  password="${pair##* }" # everything after the last space
  echo "setting password for $email"
  aws cognito-idp admin-set-user-password \
    --user-pool-id "$POOL_ID" \
    --username "$email" \
    --password "$password" \
    --permanent
done

echo "done — all 14 demo passwords set (permanent)."
