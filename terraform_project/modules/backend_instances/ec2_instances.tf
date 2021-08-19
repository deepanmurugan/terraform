data "aws_ami" "ubuntu" {
  count       = var.custom_ami ? 0 : 1
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}

resource "aws_instance" "web_instances" {
  count                   = length(var.private_subnet_id)
  ami                     = var.custom_ami ? var.custom_ami_id : data.aws_ami.ubuntu[0].id
  instance_type           = var.instance_type
  disable_api_termination = var.disable_api_termination
  tenancy                 = var.tenancy
  placement_group         = aws_placement_group.web_placement_group.id
  subnet_id               = element(var.private_subnet_id, count.index)
  key_name                = aws_key_pair.aws_key.id
  vpc_security_group_ids  = [aws_security_group.security_group_web.id]
  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }
  #user_data = file("${path.module}/install_apache.sh")
  user_data = file("${path.module}/install_apache.sh")
  tags = merge(
    var.default_tags,
    {
      Name = "${lookup(var.default_tags, "AppName", "Provide Proper Key")}-Instance-${count.index}"
    },
  )
}

resource "aws_placement_group" "web_placement_group" {
  name     = "web_placement_group"
  strategy = "spread"
  tags = merge(
    var.default_tags,
    {
      Name = "${lookup(var.default_tags, "AppName", "Provide Proper Key")}-PlacementGroup}"
    },
  )
}

resource "aws_key_pair" "aws_key" {
  key_name   = "aws-key"
  public_key = var.public_key
  tags = merge(
    var.default_tags,
    {
      Name = "${lookup(var.default_tags, "AppName", "Provide Proper Key")}-KeyPair}"
    },
  )
}

resource "aws_security_group" "security_group_web" {
  name_prefix = "${lookup(var.default_tags, "AppName", "Provide Proper Key")}-sg"
  description = var.description
  vpc_id      = var.vpc_id

  tags = merge(
    var.default_tags,
    {
      Name = "${lookup(var.default_tags, "AppName", "Provide Proper Key")}-sg"
    },
  )
}

resource "aws_security_group_rule" "allow_from_lb" {
  type                     = "ingress"
  from_port                = var.to_port
  to_port                  = var.to_port
  protocol                 = "tcp"
  source_security_group_id = var.lb_security_group
  security_group_id        = aws_security_group.security_group_web.id
}
resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.security_group_web.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}