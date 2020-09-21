variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "aws_cidr_vpc" {
  default = "10.0.0.0/16"
}

variable "aws_sg_ec2" {
  default = "sg-ec2-mediawiki"
}

variable "aws_sg_elb" {
  default = "sg-elb-mediawiki"
}

variable "instance_count" {
    default = 2
}

variable "aws_instance_type" {
  default = "t2.micro"
}

variable "azs" {
  type = list
  default = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}

variable "region" {
  description = "AWS region for hosting our your network"
  default = "ap-south-1"
}

variable "private_key" {
  default = "/home/centos/automation_apac.pem"
}

variable "public_key" {
  default = "/home/centos/automation_apac.pub"
}

variable "key_name" {
  default = "automation-apac"
}

variable "aws_ami" {
  default = "ami-01ddffd4157cae748"
}

variable "ansible_user" {
  default = "centos"
}

variable "aws_webserver" {
  type = list
  default = ["MediaWiki-Web-1", "MediaWiki-Web-2"]
}

variable "aws_dbserver" {
  default = "MediaWiki-db"
}
