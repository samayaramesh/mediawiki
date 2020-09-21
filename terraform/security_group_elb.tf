### Creating Security Group for ELB
resource "aws_security_group" "mw_sg_elb" {
  name = "mw_sg_elb"
  vpc_id = aws_vpc.mw_vpc.id
  ingress {
    from_port = 80
    to_port  = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = "0"
    to_port  = "0"
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}