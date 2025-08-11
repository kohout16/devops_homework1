# pro účely úkolu použijeme existujici default VPC. V reálné aplikaci použijeme VPC vlastní.
# data "aws_vpc" "myvpc" {

#   default = true
# }

# Create VPC
resource "aws_vpc" "myvpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "lesson7-vpc"
  }
}

# Public Subnet 1 (AZ A)
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "lesson7-subnet-1"
  }
}

# Public Subnet 2 (AZ B)
resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "lesson7-subnet-2"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "lesson7-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "subnet1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "subnet2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.public.id
}

# data "aws_subnets" "albsubnets" {
#   filter {
#     name   = "vpc-id"
#     values = [aws_vpc.myvpc.id]
#   }
# }


# pro účely úkolu použijeme stejné subnets. V praxi použijeme různé subnets pro ALB a ECS tasks.
# data "aws_subnets" "ecssubnets" {
#   filter {
#     name   = "vpc-id"
#     values = [aws_vpc.myvpc.id]
#   }
# }

# data "aws_subnet" "example" {
#   for_each = toset(data.aws_subnets.example.ids)
#   id       = each.value
# }

# output "subnet_cidr_blocks" {
#   value = [for s in data.aws_subnet.example : s.cidr_block]
# }