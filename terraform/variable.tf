variable "access_key" {
    default = "AKIA5RVKB3P2PE2545WV"
}

variable "secret_key" {
    default = "oO5M8QIqY6PBFwBB3OfVpettQPUS3j0+BqAzvHB/"
}

variable "aws_cidr_vpc" {
  default = "10.0.0.0/16"
}

variable "aws_cidr_subnet1" {
  default = "10.0.1.0/24"
}

variable "aws_cidr_subnet2" {
  default = "10.0.2.0/24"
}

variable "aws_cidr_subnet3" {
  default = "10.0.3.0/24"
}

variable "aws_sg" {
  default = "sg_mediawiki"
}

variable "instance_count" {
    default = 1
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
  default = "/home/centos/application/Keys/automation-apac.pem"
}

variable "public_key {
  default = "/home/centos/application/Keys/automation-apac.pub"
}

variable "key_name" {
  default = "automation-apac"
}

variable "aws_ami" {
  default = {
  ap-south-1 = "ami-01ddffd4157cae748"
  }
}

variable "ansible_user" {
  default = "centos"
}

variable "aws_tags" {
  type = map
  default = {
    "webserver1" = "MediaWiki-Web-1"
	"webserver2" = "MediaWiki-Web-2"
    "dbserver" = "MediaWikiDB" 
  }
}
