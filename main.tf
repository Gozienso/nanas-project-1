provider "aws" {
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
  region     = var.AWS_REGION
}

resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name : "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "my-subnet-1" {
  vpc_id            = aws_vpc.my-vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone
  
  tags = {
    Name : "${var.env_prefix}-subnet"
  }
}

#Define the Internet Gateway for the public subnet to talk to the internet
resource "aws_internet_gateway" "my-vpc-igw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

# creating a route table in aws instead of using default route table
/*resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0" # all IPs
    gateway_id = aws_internet_gateway.my-vpc-igw.id
  }

  tags = {
    Name = "${var.env_prefix}-rtb"
  }
}*/


# to use the default route table in aws instead of creating a new route table
resource "aws_default_route_table" "main_rtb" {
  default_route_table_id = aws_vpc.my-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0" # all IPs
    gateway_id = aws_internet_gateway.my-vpc-igw.id
  }

  tags = {
    Name = "${var.env_prefix}-main-rtb"
  }
}

#Define the routing association between a route table
# and a subnet or a route table and an Internet Gateway or virtual private gateway

/*resource "aws_route_table_association" "my-vpc-my-subnet-1" {
  subnet_id      = aws_subnet.my-subnet-1.id
  route_table_id = aws_route_table.my_route_table.id
}*/

#Define the routing association between a route table
# and a subnet or a route table and an Internet Gateway or virtual private gateway
resource "aws_route_table_association" "my-vpc-my-subnet-1" {
  subnet_id      = aws_subnet.my-subnet-1.id
  route_table_id = aws_default_route_table.main_rtb.id
}

resource "aws_key_pair" "mykey" {
	key_name = var.key_name
  #public_key = var.public_key
	public_key = file(var.public_key_location) # link to the id_rsa.pub file in .ssh/id_rsa directory
}

resource "aws_instance" "my_server" {
  ami           = var.aws_ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.my-subnet-1.id
  vpc_security_group_ids = [aws_security_group.my-sg.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true
  key_name = aws_key_pair.mykey.key_name

  user_data = <<EOF
                  #!/bin/bash
                  sudo dnf update -y && sudo dnf install docker -y
                  sudo service docker start
                  sudo usermod -a -G docker ec2-user
                  sudo docker pull nginx
                  sudo docker run --name my-nginx-container -d -p 8080:80 nginx
              EOF

  tags  = {
    Name = "${var.env_prefix}-server"
  }
}

output "my-vpc-id" {
  value = aws_vpc.my-vpc.id
}

output "my-subnet-id" {
  value = aws_subnet.my-subnet-1.id
}

output "public-ip" {
  value = aws_instance.my_server.public_ip
}

output "private_ip" {
  value = aws_instance.my_server.private_ip
}

