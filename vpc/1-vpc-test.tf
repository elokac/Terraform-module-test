resource "aws_vpc" "new-test" {
  cidr_block = var.cidr

  enable_dns_hostnames = "true"
  enable_dns_support   = "true"

  tags = {
    Name        = var.vpc_name
    project     = var.project
    createdby   = var.createdby
    environment = lookup(var.environment, terraform.workspace)
    manager     = element(var.manager, 0)
  }
}

# Creating 1st web subnet 
resource "aws_subnet" "public-subnet-1" {
  vpc_id                  = aws_vpc.new-test.id
  cidr_block              = var.public-subnet1_cidr
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name                                        = "public subnet 1"
    project                                     = var.project
    createdby                                   = var.createdby
    environment                                 = lookup(var.environment, terraform.workspace)
    manager                                     = element(var.manager, 0)
  }
}
# Creating 2nd web subnet 
resource "aws_subnet" "public-subnet-2" {
  vpc_id                  = aws_vpc.new-test.id
  cidr_block              = var.public-subnet2_cidr
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = {
    Name                                        = "public subnet 2"
    project                                     = var.project
    createdby                                   = var.createdby
    environment                                 = lookup(var.environment, terraform.workspace)
    manager                                     = element(var.manager, 0)
  }
}
# Creating 1st application subnet 
resource "aws_subnet" "private-subnet-1" {
  vpc_id                  = aws_vpc.new-test.id
  cidr_block              = var.private-subnet1_cidr
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1a"
  tags = {
    Name                                        = "Private Subnet 1"
    project                                     = var.project
    createdby                                   = var.createdby
    environment                                 = lookup(var.environment, terraform.workspace)
    manager                                     = element(var.manager, 0)
  }
}
# Creating 2nd application subnet 
resource "aws_subnet" "private-subnet-2" {
  vpc_id                  = aws_vpc.new-test.id
  cidr_block              = var.private-subnet2_cidr
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1b"
  tags = {
    Name                                        = "Private Subnet 2"
    project                                     = var.project
    createdby                                   = var.createdby
    environment                                 = lookup(var.environment, terraform.workspace)
    manager                                     = element(var.manager, 0)
  }
}
# Create Database Private Subnet
resource "aws_subnet" "database-subnet1" {
  vpc_id            = aws_vpc.new-test.id
  cidr_block        = var.db-subnet1_cidr
  availability_zone = "us-east-1a"
  tags = {
    Name        = "Database Subnet 1"
    project     = var.project
    createdby   = var.createdby
    environment = lookup(var.environment, terraform.workspace)
    manager     = element(var.manager, 0)
  }
}

resource "aws_subnet" "database-subnet2" {
  vpc_id            = aws_vpc.new-test.id
  cidr_block        = var.db-subnet2_cidr
  availability_zone = "us-east-1b"
  tags = {
    Name        = "Database Subnet 2 "
    project     = var.project
    createdby   = var.createdby
    environment = lookup(var.environment, terraform.workspace)
    manager     = element(var.manager, 0)
  }
}

# Create a public subnet for the bastion host
resource "aws_subnet" "bastion-subnet" {
  vpc_id                  = aws_vpc.new-test.id
  cidr_block              = var.bastion-subnet-cidr
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name        = "Bastion Subnet"
    project     = var.project
    createdby   = var.createdby
    environment = lookup(var.environment, terraform.workspace)
    manager     = element(var.manager, 0)
  }
}

# Creating Internet Gateway 
resource "aws_internet_gateway" "I-gateway" {
  vpc_id = aws_vpc.new-test.id
}

resource "aws_eip" "nat-eip-1" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.I-gateway]

  tags = {
    Name        = "nat-eip-1"
    project     = var.project
    createdby   = var.createdby
    environment = lookup(var.environment, terraform.workspace)
    manager     = element(var.manager, 0)
  }
}
resource "aws_eip" "nat-eip-2" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.I-gateway]

  tags = {
    Name        = "nat-eip-2"
    project     = var.project
    createdby   = var.createdby
    environment = lookup(var.environment, terraform.workspace)
    manager     = element(var.manager, 0)
  }
}

resource "aws_nat_gateway" "nat-gw-1" {
  allocation_id = aws_eip.nat-eip-1.id
  subnet_id     = aws_subnet.public-subnet-1.id

  tags = {
    Name        = "nat gatway 1"
    project     = var.project
    createdby   = var.createdby
    environment = lookup(var.environment, terraform.workspace)
    manager     = element(var.manager, 0)
  }

  depends_on = [aws_internet_gateway.I-gateway]
}

resource "aws_nat_gateway" "nat-gw-2" {
  allocation_id = aws_eip.nat-eip-2.id
  subnet_id     = aws_subnet.public-subnet-2.id


  tags = {
    Name        = "nat gatway 2"
    project     = var.project
    createdby   = var.createdby
    environment = lookup(var.environment, terraform.workspace)
    manager     = element(var.manager, 0)
  }

  depends_on = [aws_internet_gateway.I-gateway]
}


# Creating Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.new-test.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.I-gateway.id
  }
  tags = {
    Name        = "Route to internet"
    project     = var.project
    createdby   = var.createdby
    environment = lookup(var.environment, terraform.workspace)
    manager     = element(var.manager, 0)
  }
}

resource "aws_route_table" "private-1" {
  vpc_id = aws_vpc.new-test.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw-1.id
  }

  tags = {
    Name        = "private 1"
    project     = var.project
    createdby   = var.createdby
    environment = lookup(var.environment, terraform.workspace)
    manager     = element(var.manager, 0)
  }
}

resource "aws_route_table" "private-2" {
  vpc_id = aws_vpc.new-test.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw-2.id
  }
  tags = {
    Name        = "private 2"
    project     = var.project
    createdby   = var.createdby
    environment = lookup(var.environment, terraform.workspace)
    manager     = element(var.manager, 0)
  }
}

# Associate the public route table(s) with the public subnet(s)
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.public.id
}

# Associate the private route table(s) with the private subnet(s)
resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private-subnet-1.id
  route_table_id = aws_route_table.private-1.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private-subnet-2.id
  route_table_id = aws_route_table.private-2.id
}

# Associate the private route table(s) with the baston-host subnet(s)
resource "aws_route_table_association" "baston" {
  subnet_id      = aws_subnet.bastion-subnet.id
  route_table_id = aws_route_table.public.id
}