#!/bin/bash
sudo yum update -y
sudo yum install -y docker git wget

sudo service docker start
sudo usermod -aG docker ec2-user

sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

sudo docker volume create portainer_data
sudo docker run -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data --restart always --name portainer portainer/portainer-ce

#Clone du repos git et déploiement du compose depuis github
sudo git clone https://github.com/Amos-MUTEB/m2EsnprojectMoream.git

cd /m2EsnprojectMoream/si-client/
###cd /m2EsnprojectMoream/si-central/
docker-compose up -d



