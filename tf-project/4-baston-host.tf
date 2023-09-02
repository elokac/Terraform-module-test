# Create a security group for the bastion host (allow SSH access)
resource "aws_security_group" "bastion-sg" {
  name        = "bastion-sg"
  description = "Security group for the bastion host"
  vpc_id      = aws_vpc.new-test.id

  # Allow SSH access (adjust the source IP as needed)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict this to your IP range
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# Create an EC2 instance for the bastion host
resource "aws_instance" "bastion" {
  ami                    = var.bastion-ami
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.bastion-subnet.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.bastion-sg.id]

  user_data = <<-EOF
              #!/bin/bash
              # Install kubectl
              sudo apt update
              sudo apt  install awscli -y
              curl -LO "https://dl.k8s.io/release/v1.23.6/bin/linux/amd64/kubectl"
              sudo chmod +x kubectl
              sudo mv kubectl /usr/local/bin/
              EOF

  tags = {
    Name        = "${var.project}-Bastion-Host"
    project     = var.project
    createdby   = var.createdby
    environment = lookup(var.environment, terraform.workspace)
    manager     = element(var.manager, 0)
  }
}