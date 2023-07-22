provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "TerFormDeployPortainer080523" {
  ami           = "ami-04f1014c8adcfa670" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
#  key_name      = "terraform_dev"
#  user_data     = file("file.sh")
#  security_groups = [ "Docker" ]
  tags = {
     Name = "DockerServerInstance070523"
   }
  user_data = <<-EOF
    #!/bin/bash
    sudo amazon-linux-extras install docker -y
    sudo service docker start
    sudo usermod -a -G docker ec2-user
    sudo docker run -d -p 9000:9000 --name portainer portainer/portainer
    EOF
}

resource "aws_security_group" "Docker" {  
  name_prefix = "Docker"

  ingress {
    from_port = 9000
    to_port   = 9000
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  
  tags = {
     type = "terraform-test-security-group"
  }
}
