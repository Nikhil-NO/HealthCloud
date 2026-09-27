# Networking for the always-on demo — we reuse the account's DEFAULT VPC and one of its default
# (public) subnets rather than building a VPC. Rationale: a single public box needs no custom network
# topology, and the default VPC + subnets are FREE and already have an internet gateway + public
# routing. (The ECS stack builds its own VPC because it separates public/private tiers; this one box
# doesn't need that.)

data "aws_vpc" "default" {
  default = true
}

# The default subnets (one per AZ). We place the instance in the first one.
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}
