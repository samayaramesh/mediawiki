#Setting up VPC
resource "aws_vpc" "mw_vpc" {
  cidr_block = var.aws_cidr_vpc
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "MediaWikiVPC"
  }
}

#Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.mw_vpc.id
  tags = {
    Name = "MediaWikiIGW"
  }
}
