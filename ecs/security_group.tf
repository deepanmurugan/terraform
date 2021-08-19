# Application load balancer Security group opens traffic to public
resource "aws_security_group" "test_public_sg" {
  name        = "test_public_sg"
  description = "Test public access security group"
  vpc_id      = aws_vpc.ECS-VPC.id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = [
    "0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
    "0.0.0.0/0"]
  }

  egress {
    # allow all traffic to private SN
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    cidr_blocks = [
    "0.0.0.0/0"]
  }

  tags = {
    Name = "test_public_sg"
  }
}

# Security group for ecs instances allow traffic only from ALB
resource "aws_security_group" "ecs-instance_sg" {
  description = "controls direct access to application instances"
  vpc_id      = aws_vpc.ECS-VPC.id
  name        = "ecs-instance-sg"

  ingress {
    protocol    = "tcp"
    from_port   = 32768
    to_port     = 65535
    description = "Access from ALB"

    security_groups = [
      "${aws_security_group.test_public_sg.id}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
