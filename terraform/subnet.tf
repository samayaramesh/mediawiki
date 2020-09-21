#Public Subnet
resource "aws_subnet" "mw_public_subnet" {
  count  = length(var.azs)
  vpc_id = aws_vpc.mw_vpc.id
  cidr_block = cidrsubnet(var.aws_cidr_vpc, 8, count.index)
  availability_zone = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "mw_public_subnet - ${element(var.azs, count.index)}"
  }
}

#Application Subnet
resource "aws_subnet" "mw_app_subnet" {
  count  = length(var.azs)
  vpc_id = aws_vpc.mw_vpc.id
  cidr_block = cidrsubnet(var.aws_cidr_vpc, 6, count.index + length(var.azs))
  availability_zone = element(var.azs, count.index)
  map_public_ip_on_launch = false
  tags = {
    Name = "mw_app_subnet - ${element(var.azs, count.index)}"
  }
}

#Database Subnet
resource "aws_subnet" "mw_db_subnet" {
  count  = length(var.azs)
  vpc_id = aws_vpc.mw_vpc.id
  cidr_block = cidrsubnet(var.aws_cidr_vpc, 7, count.index + length(var.azs))
  availability_zone = element(var.azs, count.index)
  map_public_ip_on_launch = false
  tags = {
    Name = "mw_db_subnet - ${element(var.azs, count.index)}"
  }
}

resource "aws_eip" "nat" {
  count  = length(var.azs)
  vpc   = true
}
resource "aws_nat_gateway" "ngw" {
  count  = length(var.azs)
  subnet_id     = element(aws_subnet.mw_public_subnet.*.id, count.index)
  allocation_id = element(aws_eip.nat.*.id, count.index)
  #subnet_id     = element(local.subs, count.index)
  #depends_on    = [aws_internet_gateway.igw.id]
  
  tags = {
    Name = "ngw - ${element(var.azs, count.index)}"
  }
}
