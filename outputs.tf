# ---------------------------------------------
# EC2 Outputs
# ---------------------------------------------
output "shlo111_ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.shlo111_ec2.public_ip
}

output "shlo111_ec2_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.shlo111_ec2.public_dns
}

output "shlo111_ec2_id" {
  description = "Instance ID of the EC2 instance"
  value       = aws_instance.shlo111_ec2.id
}

# ---------------------------------------------
# Load Balancer Outputs
# ---------------------------------------------
output "shlo111_alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.shlo111_alb.dns_name
}

output "shlo111_alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.shlo111_alb.arn
}

output "shlo111_target_group_arn" {
  description = "ARN of the Target Group"
  value       = aws_lb_target_group.shlo111_tg.arn
}

# ---------------------------------------------
# Network Outputs
# ---------------------------------------------
output "shlo111_vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.shlo111_vpc.id
}

output "shlo111_public_subnet_id" {
  description = "Public Subnet ID"
  value       = aws_subnet.shlo111_public_subnet.id
}

output "shlo111_private_subnet_id" {
  description = "Private Subnet ID"
  value       = aws_subnet.shlo111_private_subnet.id
}

output "shlo111_security_group_id" {
  description = "Security Group ID for the Web Server"
  value       = aws_security_group.shlo111_web_sg.id
}

output "shlo111_alb_security_group_id" {
  description = "Security Group ID for the ALB"
  value       = aws_security_group.shlo111_alb_sg.id
}
