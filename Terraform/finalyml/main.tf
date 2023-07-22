provider "aws" {
  region = "eu-west-1"
}

### KEYPAIR ###
resource "tls_private_key" "keypair" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "keypair" {
  key_name   = "moreamkeylinux"
  public_key = tls_private_key.keypair.public_key_openssh
}

resource "local_file" "moream5_ssh_key" {
  filename = "${aws_key_pair.keypair.key_name}.pem"
  content  = tls_private_key.keypair.private_key_pem
}

# Create VPC
resource "aws_vpc" "moream_vpc" {
  cidr_block = "10.0.0.0/16"  # Replace with your desired CIDR block
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


## Create security group
resource "aws_security_group" "terraformdocker_sg" {
  name = "terraform_docker_sg"
  description = "Terraform Security Group"

  vpc_id = aws_vpc.moream_vpc.id
  ingress {
    from_port = 9000
    to_port   = 9000
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
     type = "terraform-test-security-group"
  }
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

#associate route table with the subnets
resource "aws_route_table_association" "moream_association_az1a" {
  subnet_id      = aws_subnet.moream_subnet_az1a.id
  route_table_id = aws_route_table.moream_route_table.id
}

resource "aws_route_table_association" "moream_association_az1b" {
  subnet_id      = aws_subnet.moream_subnet_az1b.id
  route_table_id = aws_route_table.moream_route_table.id
}

## Create Instance EC2
resource "aws_instance" "TerFKeypair010623" {
  ami           = "ami-04f1014c8adcfa670"
  instance_type = "t2.small"
  key_name      = aws_key_pair.keypair.key_name
  user_data     = file("shellcmd.sh")
  subnet_id    = aws_subnet.moream_subnet_az1a.id
#  vpc_security_group_ids = ["<desired_security_group_id>"]

  vpc_security_group_ids = [aws_security_group.terraformdocker_sg.id]

  tags = {
    Name = "terF_Inst&KeyP220623_ajout"
  }
}

## Création du loadbalancer 
resource "aws_lb" "moream_load_balancer" {
  name = "moream-alb-apps"
  load_balancer_type = "application"
  subnets            = ["aws_subnet.moream_subnet_az1a.id", "aws_subnet.moream_subnet_az1b.id"]
  security_groups = [aws_security_group.terraformdocker_sg.id]
  
  tags = {
    Environment = "Moream-Application-LB"
  }
#  access_logs = {
#    bucket = "moream-alb-logs"
#  }
}
  # Create a target group for the load balancer
resource "aws_lb_target_group" "moream_target_group" {

      name      = "MOREAM-WP-8080"
      protocol = "HTTP"
      port     = 8080
      vpc_id = aws_vpc.moream_vpc.id
      target_type      = "instance"
      
    }

 # Create an HTTPS Listener for the load balancer
resource "aws_lb_listener" "moream_https_listener" {
      
      load_balancer_arn  = aws_lb.moream_load_balancer.arn
      port               = 443
      protocol           = "HTTPS"
#      certificate_arn    = "arnawsiam:123456789012server-certificate/test_cert-123456789012"

      default_action {
        type             = "forward"
      }
}
 # Create an HTTP Listener for the load balancer
resource "aws_lb_listener" "moream_http_listener" {

      load_balancer_arn = aws_lb.moream_load_balancer.arn
      port               = 80
      protocol           = "HTTP"
 
      default_action {
        type             = "forward"
      }
}
