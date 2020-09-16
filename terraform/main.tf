provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

# Setting up VPC
resource "aws_vpc" "mw_vpc" {
  cidr_block = var.aws_cidr_vpc
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "MediaWikiVPC"
  }
}
data "aws_availability_zones" "all" {}
#Subnets
resource "aws_subnet" "mw_subnet1" {
  vpc_id = aws_vpc.mw_vpc.id
  cidr_block = var.aws_cidr_subnet1
  availability_zone = data.aws_availability_zones.all.names

  tags = {
    Name = "MediaWikiSubnet1"
  }
}

resource "aws_subnet" "mw_subnet2" {
  vpc_id = aws_vpc.mw_vpc.id
  cidr_block = var.aws_cidr_subnet2
  availability_zone = data.aws_availability_zones.all.names
  tags = {
    Name = "MediaWikiSubnet2"
  }
}

resource "aws_subnet" "mw_subnet3" {
  vpc_id = aws_vpc.mw_vpc.id
  cidr_block = var.aws_cidr_subnet2
  availability_zone = data.aws_availability_zones.all.names
  tags = {
    Name = "MediaWikiSubnet3"
  }
}

### Creating Security Group for EC2
resource "aws_security_group" "mw_sg" {
  name = "mw_sg"
  vpc_id = aws_vpc.mw_vpc.id
  ingress {
    from_port = 22 
    to_port  = 22
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
   ingress {
    from_port = 80
    to_port  = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 3306
    to_port  = 3306
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

resource "tls_private_key" "automation_apac" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "automation_apac" {
  key_name   = var.key_name
  public_key = tls_private_key.automation_apac.public_key_openssh
}

# Launch the instance
resource "aws_instance" "webserver1" {
  ami           = var.aws_ami
  instance_type = var.aws_instance_type
  key_name  = var.key_name
  vpc_security_group_ids = [aws_security_group.mw_sg.id]
  subnet_id     = aws_subnet.mw_subnet1.id
  associate_public_ip_address = true
  tags = {
    Name = lookup(var.aws_tags,"webserver1")
    group = "web"
  }
}

resource "aws_instance" "webserver2" {
  #depends_on = [aws_security_group.mw_sg]
  ami           = var.aws_ami
  instance_type = var.aws_instance_type
  key_name  = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.mw_sg.id]
  subnet_id     = aws_subnet.mw_subnet2.id 
  associate_public_ip_address = true
  tags = {
    Name = lookup(var.aws_tags,"webserver2")
    group = "web"
  }
}

resource "aws_instance" "dbserver" {
  #depends_on = [aws_security_group.mw_sg]
  ami           = var.aws_ami
  instance_type = var.aws_instance_type
  key_name  = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.mw_sg.id]
  subnet_id     = aws_subnet.mw_subnet2.id

  tags = {
    Name = lookup(var.aws_tags,"dbserver")
    group = "db"
  }
}
## Creating Launch Configuration
resource "aws_launch_configuration" "mw_lc" {
  image_id               = lookup(var.aws_ami,var.region)
  instance_type          = var.aws_instance_type
  security_groups        = [aws_security_group.mw_sg.id]
  key_name               = var.key_name

  provisioner "remote-exec" {
    inline = ["sudo yum install python -y"]
	connection {
		type        = ssh
		private_key = file(var.private_key)
		user        = var.ansible_user
  }
}
  provisioner "local-exec" {
    command = "ansible-playbook site.yml -u var.ansible_user --private-key var.private_key -i tag_Name_web"
  }
  provisioner "local-exec" {
    command = "ansible-playbook site.yml -u var.ansible_user --private-key var.private_key -i tag_Name_db"  
  }
  lifecycle {
    create_before_destroy = true
  }
}

### Creating ELB
resource "aws_elb" "mw_elb" {
  name = "MediaWikiELB"
  subnets         = [aws_subnet.mw_subnet1.id, aws_subnet.mw_subnet2.id]
  security_groups = [aws_security_group.mw_sg.id]
  instances = [aws_instance.webserver1.id, aws_instance.webserver2.id]
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

## Creating AutoScaling Group
resource "aws_autoscaling_group" "mw_asg" {
  launch_configuration = aws_launch_configuration.mw_lc.id
  availability_zones = data.aws_availability_zones.all.names
  min_size = 2
  max_size = 10
  load_balancers = [aws_elb.mw_elb.name]
  health_check_type = "ELB"
  tag {
    key = "Name"
    value = "mw_asg"
    propagate_at_launch = true
  }
}

