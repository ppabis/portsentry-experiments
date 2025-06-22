module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "portsentry-vpc"
  cidr = "10.199.199.0/24"

  azs            = ["eu-west-2a", "eu-west-2b"]
  public_subnets = ["10.199.199.0/26", "10.199.199.64/26"]

  # Disable NAT gateways since we only want public subnets
  enable_nat_gateway = false
  single_nat_gateway = false

  # Enable DNS hostnames and support
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Tags
  public_subnet_tags = {
    Type = "Public"
  }
}
