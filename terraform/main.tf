provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}

#locals {
#  subs = concat([aws_subnet.mw_subnet0.id], [aws_subnet.mw_subnet1.id], [aws_subnet.mw_subnet2.id])
#}


