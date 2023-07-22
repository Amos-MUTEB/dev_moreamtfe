# Deployement of EC2 standalone
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_instance" "TerraformDeployTest200423" {
  ami           = "ami-04f1014c8adcfa670" 
  instance_type = "t2.micro"

  tags = {
    Name = "TerraformDeployTest200423"
  }
}
# ami-04f1014c8adcfa670

