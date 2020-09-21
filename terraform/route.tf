resource "aws_route_table" "public" {
  vpc_id = aws_vpc.mw_vpc.id

  tags = {
    "Name" = "Public route table"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  count = length(var.azs)

  subnet_id      = element(aws_subnet.mw_public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "application" {
  count  = length(var.azs)
  vpc_id = aws_vpc.mw_vpc.id

  tags = {
    "Name" = "Application route table - ${element(var.azs, count.index)}"
  }
}

resource "aws_route" "application_gateway" {
  count = length(var.azs)

  route_table_id         = element(aws_route_table.application.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.ngw.*.id, count.index)
}

resource "aws_route_table_association" "application" {
  count = length(var.azs)

  subnet_id      = element(aws_subnet.mw_app_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.application.*.id, count.index)
}


resource "aws_route_table" "database" {
  count  = length(var.azs)
  vpc_id = aws_vpc.mw_vpc.id

  tags = {
    "Name" = "Database route table - ${element(var.azs, count.index)}"
  }
}

resource "aws_route" "database_gateway" {
  count = length(var.azs)

  route_table_id         = element(aws_route_table.database.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.ngw.*.id, count.index)
}

resource "aws_route_table_association" "database" {
  count = length(var.azs)

  subnet_id      = element(aws_subnet.mw_db_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.database.*.id, count.index)
}


