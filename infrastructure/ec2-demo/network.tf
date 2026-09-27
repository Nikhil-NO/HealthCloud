# Networking for the always-on demo — we reuse the account's DEFAULT VPC and one of its default
# (public) subnets rather than building a VPC. Rationale: a single public box needs no custom network
# topology, and the default VPC + subnets are FREE and already have an internet gateway + public
# routing. (The ECS stack builds its own VPC because it separates public/private tiers; this one box
# doesn't need that.)

data "aws_vpc" "default" {
  default = true
}

# Which AZs actually offer our instance type — not every AZ does (e.g. us-east-1e has no t3.micro),
# and RunInstances hard-fails if the subnet's AZ can't host the type. So we restrict subnet selection
# to AZs that support it, rather than hardcoding one.
data "aws_ec2_instance_type_offerings" "supported" {
  filter {
    name   = "instance-type"
    values = [var.instance_type]
  }
  location_type = "availability-zone"
}

# The default subnets in a supported AZ. We place the instance in the first one.
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
  filter {
    name   = "availability-zone"
    values = data.aws_ec2_instance_type_offerings.supported.locations
  }
}
