resource "aws_vpc" "nebari_sandbox_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

# Create IGW and routes for it
resource "aws_internet_gateway" "nebari_sandbox_igw" {
  vpc_id = aws_vpc.nebari_sandbox_vpc.id
}

resource "aws_route_table" "nebari_sandbox_route_table" {
  vpc_id = aws_vpc.nebari_sandbox_vpc.id
}

resource "aws_route" "nebari_sandbox_route-public" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.nebari_sandbox_route_table.id
  gateway_id             = aws_internet_gateway.nebari_sandbox_igw.id
}

# Create subnet and associate public route table
resource "aws_subnet" "nebari_sandbox_subnet" {
  vpc_id     = aws_vpc.nebari_sandbox_vpc.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_route_table_association" "default" {
  subnet_id      = aws_subnet.nebari_sandbox_subnet.id
  route_table_id = aws_route_table.nebari_sandbox_route_table.id
}


# Security group - allow SSH from user's home
resource "aws_security_group" "allow_ssh_home" {
  name        = "allow_ssh_home"
  description = "Allow SSH connections from user home IP"
  vpc_id      = aws_vpc.nebari_sandbox_vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_local_ip}/32"]
  }

  tags = {
    Name = "allow_ssh_home"
  }
}