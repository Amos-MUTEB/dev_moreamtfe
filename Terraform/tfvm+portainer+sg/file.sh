#!/bin/bash
 sudo amazon-linux-extras install docker -y
 sudo service docker start
 sudo usermod -a -G docker ec2-user
 sudo docker run -d -p 9000:9000 --name portainer portainer/portainer
