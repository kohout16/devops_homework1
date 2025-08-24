# Provider configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.8.0"
    }
  }
  
  backend "s3" {
# bucket vytvořit ručně např. přes AWS console služba S3 -> create. Jméno musí být unikátní např. tfstate-<číslo aws účtu>-eu-central-1
    bucket = "tfstate-563748388258-eu-central-1"
    key    = "ecs-demo/terraform.tfstate"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = var.aws_region
}




# # Získání aktuálního Amazon Linux 2 AMI
# data "aws_ami" "amazon_linux_2" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm-*-x86_64-gp2"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }

## Vytvoření key pair pro SSH přístup
#resource "aws_key_pair" "ec2_key" {
#  key_name   = var.key_name
#  public_key = file(var.public_key_path)
#}

# # Security group pro SSH přístup
# resource "aws_security_group" "ec2_sg" {
#   name        = "${var.name_prefix}-sg"
#   description = "Security group pro EC2 instanci s SSH pristupem"

#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#     description = "SSH pristup"
#   }

#   # Přidáme HTTP port pro bonus úkol s Apache
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#     description = "HTTP pristup"
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#     description = "Povoleni veskereho odchoziho provozu"
#   }

#   tags = {
#     Name        = "${var.name_prefix}-sg"
#     Environment = var.environment
#     Course      = var.course_name
#   }
# }

# EC2 instance
resource "aws_instance" "ec2_instance" {
  ami                    = "ami-0a72753edf3e631b7"
  instance_type          = var.instance_type
  #key_name               = aws_key_pair.ec2_key.key_name
  subnet_id              = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.ecs_tasks.id]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<html><body><h1>Terraform EC2 Instance</h1><p>Vytvořeno pomocí Terraform pro ${var.course_name}</p></body></html>" > /var/www/html/index.html

    

  EOF

  tags = {
    Name        = "${var.name_prefix}-instance"
    Environment = var.environment
    Course      = var.course_name
  }
}

# ECR Repository
resource "aws_ecr_repository" "python_calculator" {
name = var.repository_name
image_tag_mutability = "MUTABLE"

image_scanning_configuration {
scan_on_push = true
}
}

resource "aws_ecr_repository" "mynginx" {
  name = "mynginx"
}

# ECR Lifecycle Policy
resource "aws_ecr_lifecycle_policy" "python_calculator_policy" {
repository = aws_ecr_repository.python_calculator.name

policy = jsonencode({
rules = [
{
rulePriority = 1
description = "Keep last 10 images"
selection = {
tagStatus = "tagged"
tagPrefixList = ["v"]
countType = "imageCountMoreThan"
countNumber = 10
}
action = {
type = "expire"
}
}
]
})
}
