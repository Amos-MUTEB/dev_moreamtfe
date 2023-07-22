provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "TerFormDeployPortainer070523" {
  ami           = "ami-04f1014c8adcfa670" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
#  key_name      = "terraform_dev"

  tags = {
    Name = "TerFormDeployPortainer070523"
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo amazon-linux-extras install docker -y
    sudo service docker start
    sudo usermod -a -G docker ec2-user
    sudo docker run -d -p 9000:9000 --name portainer portainer/portainer
    EOF

  # Open port 9000 for HTTP traffic
  security_groups = [
    aws_security_group.allow_http.id,
  ]
}

resource "aws_security_group" "allow_http" {
  name_prefix = "allow_http"
  
  ingress {
    from_port = 9000
    to_port   = 9000
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

