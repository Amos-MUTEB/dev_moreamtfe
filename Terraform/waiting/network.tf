# Create VPC
resource "aws_vpc" "moream_vpc" {
  cidr_block = "10.0.0.0/16"  # Replace with your desired CIDR block
}
# Create internet gateway
resource "aws_internet_gateway" "moream_igw" {
  vpc_id = aws_vpc.moream_vpc.id
}

# Create route table
resource "aws_route_table" "moream_route_table" {
  vpc_id = aws_vpc.moream_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.moream_igw.id
  }
}

# Create first subnet within the VPC (Availability Zone A)
resource "aws_subnet" "moream_subnet_az1a" {
  vpc_id                  = aws_vpc.moream_vpc.id
  cidr_block              = "10.0.1.0/24"  # Replace with your desired subnet CIDR block for AZ1
  availability_zone       = "eu-west-1a"   # Replace with your desired availability zone
  map_public_ip_on_launch = true           # Enable auto-assigning public IP addresses

  tags = {
    Name = "Moream Subnet AZ1 a"
  }
}

# Create second subnet within the VPC (Availability Zone B)
resource "aws_subnet" "moream_subnet_az1b" {
  vpc_id                  = aws_vpc.moream_vpc.id
  cidr_block              = "10.0.2.0/24"  # Replace with your desired subnet CIDR block for AZ2
  availability_zone       = "eu-west-1b"   # Replace with your desired availability zone
  map_public_ip_on_launch = true           # Enable auto-assigning public IP addresses

  tags = {
    Name = "Moream Subnet AZ1 b"
  }
}

# Associate route table with the subnets
resource "aws_route_table_association" "moream_association_az1a" {
  subnet_id      = aws_subnet.moream_subnet_az1a.id
  route_table_id = aws_route_table.moream_route_table.id
}

resource "aws_route_table_association" "moream_association_az1b" {
  subnet_id      = aws_subnet.moream_subnet_az1b.id
  route_table_id = aws_route_table.moream_route_table.id
}
