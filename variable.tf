variable "AWS_ACCESS_KEY" {
 description = "AWS ACCESS KEY"
}

variable "AWS_SECRET_KEY" {
  description = "AWS SECRET KEY"
}

variable "AWS_REGION" {
  description = "AWS REGION"
}

variable "avail_zone" {
   description = "availability zone"
}

variable "vpc_cidr_block" {
  description = "vpc cidr block"
}

variable "subnet_cidr_block" {
  description = "subnet cidr block"
}

variable "env_prefix" {
  description = "vpc environment"
}

variable "aws_ami" {
   description = "ami identity number"
}

variable "instance_type" {
  description = "instance type"
}

variable "instance_name" {
  description = "instance name"
}

variable "key_name" {
    description = "The name of the key pair"
}

variable "public_key_location" {
  description = "The path to the public key file location"
}

/*
variable "public_key" {
  #description = "public key"
}
*/