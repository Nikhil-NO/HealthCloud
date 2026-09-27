# IAM for the demo box. The instance assumes a role that lets it (a) be managed by SSM Session
# Manager for shell access without SSH, and (b) read the one SecureString SSM parameter holding the
# app's .env (secrets + config) at boot.

data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "instance" {
  name               = "${local.name_prefix}-instance"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

# SSM Session Manager: browser/CLI shell into the box with no SSH key and no open port 22.
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Read the app's .env parameter (SecureString) — scoped to exactly that parameter, plus the KMS
# decrypt it needs, constrained to the SSM service (least privilege).
data "aws_iam_policy_document" "read_env" {
  statement {
    sid       = "ReadAppEnvParam"
    actions   = ["ssm:GetParameter"]
    resources = [aws_ssm_parameter.env.arn]
  }

  statement {
    sid       = "DecryptViaSsm"
    actions   = ["kms:Decrypt"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ssm.${var.aws_region}.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "read_env" {
  name   = "read-app-env"
  role   = aws_iam_role.instance.id
  policy = data.aws_iam_policy_document.read_env.json
}

resource "aws_iam_instance_profile" "instance" {
  name = "${local.name_prefix}-instance"
  role = aws_iam_role.instance.name
}
