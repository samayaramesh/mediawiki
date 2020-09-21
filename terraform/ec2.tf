# Launch the instance
resource "aws_instance" "webserver" {
  depends_on = [aws_security_group.mw_sg_ec2]
  ami           = var.aws_ami
  instance_type = var.aws_instance_type
  key_name  = var.key_name
  count= var.instance_count
  vpc_security_group_ids = [aws_security_group.mw_sg_ec2.id]
  subnet_id = element(aws_subnet.mw_app_subnet.*.id, count.index)
  associate_public_ip_address = true
  tags = {
    Name = element(var.aws_webserver, count.index)
  }
  provisioner "remote-exec" {
     inline = ["sudo yum install python -y"]
        connection {
                type        = "ssh"
                private_key = file(var.private_key)
                user        = var.ansible_user
                host        = self.public_ip
  }
 }
   provisioner "local-exec" {
    command = "ansible-playbook site.yml -u var.ansible_user --private-key var.private_key -i tag_Name_web"
  }
}

resource "aws_instance" "dbserver" {
  depends_on = [aws_security_group.mw_sg_ec2]
  ami           = var.aws_ami
  instance_type = var.aws_instance_type
  count = 1
  key_name  = var.key_name
  vpc_security_group_ids = [aws_security_group.mw_sg_ec2.id]
  #subnet_id     = aws_subnet.mw_subnet2.id
  subnet_id = element(aws_subnet.mw_db_subnet.*.id, count.index)
  associate_public_ip_address = true
  tags = {
    Name = var.aws_dbserver
  }
  
  provisioner "remote-exec" {
    inline = ["sudo yum install python -y"]
        connection {
                type        = "ssh"
                private_key = file(var.private_key)
                user        = var.ansible_user
                host        = self.public_ip
  }
 }
   provisioner "local-exec" {
   command = "ansible-playbook site.yml -u var.ansible_user --private-key var.private_key -i tag_Name_db"
  }
}
