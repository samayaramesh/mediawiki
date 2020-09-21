### Creating Launch Configuration
data "aws_availability_zones" "all" {}

resource "aws_launch_configuration" "mw_lc" {
  image_id               = var.aws_ami
  instance_type          = var.aws_instance_type
  security_groups        = [aws_security_group.mw_sg_ec2.id]
  
  lifecycle {
    create_before_destroy = true
  }
}

## Creating AutoScaling Group
resource "aws_autoscaling_group" "mw_asg" {
  launch_configuration = aws_launch_configuration.mw_lc.id
 #availability_zones = element(var.azs, count.index)
  availability_zones = data.aws_availability_zones.all.names
  min_size = 0
  max_size = 10
  load_balancers = [aws_elb.mw_elb.name]
  health_check_type = "ELB"
  tag {
    key = "Name"
    value = "mw_asg"
    propagate_at_launch = true
    }
}
