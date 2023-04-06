#!/bin/bash
sudo dnf update -y 
sudo dnf install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo docker pull nginx
sudo docker run --name my-nginx-container -d -p 8080:80 nginx
            
