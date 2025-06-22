# Variable for your IP CIDR
variable "my_ip_cidr" {
  description = "Your IP address in CIDR notation (e.g., 192.168.1.100/32)"
  type        = string
  default     = "0.0.0.0/0" # Change this to your actual IP
}

module "ssh_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name                = "ssh-access-sg"
  description         = "Security group for SSH access from specific IP"
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = [var.my_ip_cidr]
  ingress_rules       = ["ssh-tcp"]
  egress_rules        = ["all-all"]
}

module "internal_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "internal-access-sg"
  description = "Security group that allows all traffic from SSH security group"
  vpc_id      = module.vpc.vpc_id
  ingress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.ssh_sg.security_group_id
      description              = "Allow all traffic from SSH security group"
    }
  ]
  egress_rules = ["all-all"]
}
