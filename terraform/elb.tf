### Creating ELB
resource "aws_elb" "mw_elb" {
  name = "MediaWikiELB"
 # subnets     = element(aws_subnet.mw_public_subnet.*.id, count.index)
  subnets     = aws_subnet.mw_public_subnet.*.id
  security_groups = [aws_security_group.mw_sg_elb.id]
  instances = aws_instance.webserver.*.id
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:8080/"
  }
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}
