output "instance_ids" {
    value = [aws_instance.web.*.public_ip]
}

output "pem" {
        value = ["${tls_private_key.key_name.private_key_pem}"]
}

output "elb_dns_name" {
  value = "${aws_elb.mw_elb.dns_name}"
}
