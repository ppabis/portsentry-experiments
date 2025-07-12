variable "red_team_count" {
  type    = number
  default = 2
}

variable "key_path" {
  type    = string
  default = "~/.ssh/id_ed25519.pub"
}

data "aws_ami" "debian_bookworm" {
  most_recent = true
  owners      = ["amazon"] # Debian official account

  filter {
    name   = "name"
    values = ["debian-12-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "portsentry-key"
  public_key = file(var.key_path)
}

# Red Team instance (with SSH access)
resource "aws_instance" "red_team" {
  count = var.red_team_count

  ami                         = data.aws_ami.debian_bookworm.id
  instance_type               = "t4g.nano"
  key_name                    = aws_key_pair.ssh_key.key_name
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [module.ssh_sg.security_group_id]
  associate_public_ip_address = true
  user_data                   = templatefile("red_team.sh", { index = count.index })

  tags = {
    Name = "Red Team"
  }

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }
}

# Blue Team instance (with internal access)
resource "aws_instance" "blue_team" {
  ami                         = data.aws_ami.debian_bookworm.id
  instance_type               = "t4g.nano"
  key_name                    = aws_key_pair.ssh_key.key_name
  subnet_id                   = module.vpc.public_subnets[1]
  vpc_security_group_ids      = [module.internal_sg.security_group_id]
  associate_public_ip_address = true
  user_data                   = file("blue_team.sh")
  iam_instance_profile        = aws_iam_instance_profile.blue_team.name

  tags = {
    Name = "Blue Team"
  }

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }
}
