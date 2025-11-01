# ---------------------------------------------
# VPC
# ---------------------------------------------
resource "aws_vpc" "shlo111_vpc" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"

  tags = {
    Name = "shlo111-vpc"
  }
}

# ---------------------------------------------
# Public Subnet
# ---------------------------------------------
resource "aws_subnet" "shlo111_public_subnet" {
  vpc_id     = aws_vpc.shlo111_vpc.id
  cidr_block = var.public_subnet_cidr

  tags = {
    Name = "shlo111-public-subnet"
  }
}

# ---------------------------------------------
# Private Subnet
# ---------------------------------------------
resource "aws_subnet" "shlo111_private_subnet" {
  vpc_id     = aws_vpc.shlo111_vpc.id
  cidr_block = var.private_subnet_cidr

  tags = {
    Name = "shlo111-private-subnet"
  }
}

# ---------------------------------------------
# Internet Gateway
# ---------------------------------------------
resource "aws_internet_gateway" "shlo111_igw" {
  vpc_id = aws_vpc.shlo111_vpc.id

  tags = {
    Name = "shlo111-igw"
  }
}

# ---------------------------------------------
# Route Table for Public Subnet
# ---------------------------------------------
resource "aws_route_table" "shlo111_public_rt" {
  vpc_id = aws_vpc.shlo111_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.shlo111_igw.id
  }

  tags = {
    Name = "shlo111-public-rt"
  }
}

# ---------------------------------------------
# Associate Public Subnet with Route Table
# ---------------------------------------------
resource "aws_route_table_association" "shlo111_public_assoc" {
  subnet_id      = aws_subnet.shlo111_public_subnet.id
  route_table_id = aws_route_table.shlo111_public_rt.id
}

# ---------------------------------------------
# User Data for Nginx
# ---------------------------------------------
data "template_file" "shlo111_user_data" {
  template = file("install_nginx.sh")
}

# ---------------------------------------------
# Security Group for EC2
# ---------------------------------------------
resource "aws_security_group" "shlo111_web_sg" {
  name        = "shlo111-web-sg"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = aws_vpc.shlo111_vpc.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "shlo111-web-sg"
  }
}

# ---------------------------------------------
# EC2 Instance
# ---------------------------------------------
resource "aws_instance" "shlo111_ec2" {
  ami                        = "ami-01760eea5c574eb86"
  instance_type              = "t3.micro"
  subnet_id                  = aws_subnet.shlo111_public_subnet.id
  associate_public_ip_address = true
  user_data                  = data.template_file.shlo111_user_data.rendered
  vpc_security_group_ids     = [aws_security_group.shlo111_web_sg.id]

  tags = {
    Name = "shlo111-web-server"
  }
}

# ---------------------------------------------
# Security Group for Load Balancer
# ---------------------------------------------
resource "aws_security_group" "shlo111_alb_sg" {
  name        = "shlo111-alb-sg"
  description = "Allow HTTP access to the Load Balancer"
  vpc_id      = aws_vpc.shlo111_vpc.id

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "shlo111-alb-sg"
  }
}

# ---------------------------------------------
# Application Load Balancer
# ---------------------------------------------
resource "aws_lb" "shlo111_alb" {
  name               = "shlo111-loadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.shlo111_alb_sg.id]
  subnets            = [
    aws_subnet.shlo111_public_subnet.id,
    aws_subnet.shlo111_private_subnet.id
  ]

  tags = {
    Name = "shlo111-alb"
  }
}

# ---------------------------------------------
# Target Group
# ---------------------------------------------
resource "aws_lb_target_group" "shlo111_tg" {
  name     = "shlo111-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.shlo111_vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  tags = {
    Name = "shlo111-target-group"
  }
}

# ---------------------------------------------
# Target Group Attachment
# ---------------------------------------------
resource "aws_lb_target_group_attachment" "shlo111_tg_attach" {
  target_group_arn = aws_lb_target_group.shlo111_tg.arn
  target_id        = aws_instance.shlo111_ec2.id
  port             = 80
}

# ---------------------------------------------
# Load Balancer Listener
# ---------------------------------------------
resource "aws_lb_listener" "shlo111_listener" {
  load_balancer_arn = aws_lb.shlo111_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.shlo111_tg.arn
  }
}
