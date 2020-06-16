# Create a VPC
resource "aws_vpc" "main-vpc" {
    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Name = "main-vpc"
        Created = "with Terraform"
    }
}

# Create the subnets. For simplicity we just create 2 subnets, one as public and one as private

resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
      Name = "private-subnet"
      Created = "with Terraform"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = "10.0.10.0/24"
  map_public_ip_on_launch = true

  tags = {
      Name = "public-subnet"
      Created = "with Terraform"
  }
}

  # Create Internet Gateway for the public subnet

resource "aws_internet_gateway" "internet-gw" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "internet-gw"
    Created = "with Terraform"
  }
}

# Create network interface to attach the EIP too

resource "aws_network_interface" "network-interface" {
  subnet_id       = aws_subnet.public-subnet.id

  tags = {
    Name = "nat-network-interface"
    Created = "with Terraform"
  }
  #security_groups = ["${aws_security_group.web.id}"]
}

# Create Elastic IP for the NAT GW

resource "aws_eip" "eip-nat-gw" {
  vpc      = true

  tags = {
  Name = "eip-nat-gw"
  Created = "with Terraform"
  }
}

# Create NAT GT inside public subnet for the private one to connect to 

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.eip-nat-gw.id
  subnet_id     = aws_subnet.public-subnet.id

  tags = {
    Name = "NAT-GW"
    Created = "with Terraform"
  }
}

# Create ACL for main vpc

resource "aws_network_acl" "main-acl" {
  vpc_id = aws_vpc.main-vpc.id
  subnet_ids = ["${aws_subnet.public-subnet.id}", "${aws_subnet.private-subnet.id}"]

  egress {
    protocol   = "-1"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "main-acl"
    Created = "with Terraform"
  }
}


# Create Route Table for public subnet

resource "aws_route_table" "private-route" {
  vpc_id = aws_vpc.main-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-gw.id
  }

  tags = {
    Name = "private-route"
    Created = "with Terraform"
  }
}

resource "aws_route_table" "public-route" {
  vpc_id = aws_vpc.main-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gw.id
  }

  tags = {
    Name = "public-route"
    Created = "with Terraform"
  }
}

# Route table association

resource "aws_route_table_association" "private-routetable" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-route.id
}

resource "aws_route_table_association" "public-routetable" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-route.id
}

# Security Group allowing all traffic within ht vpc

resource "aws_security_group" "allow-vpc-traffic" {
  name        = "allow-vpc-traffic"
  description = "Allow all traffic within the entire vpc"
  vpc_id      = aws_vpc.main-vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${aws_vpc.main-vpc.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-vpc-traffic"
    Created = "with Terraform"
  }
}