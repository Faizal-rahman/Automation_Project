
output "public_vms_public_ips" {
  value = aws_instance.public_vms[*].public_ip
}

output "public_vms_ips" {
  value = aws_instance.public_vms[*].private_ip
}

output "lb_dns" {
  value = aws_elb.web_elb.dns_name
}

output "bastion_ip" {
  value = aws_eip.bastion_eip.public_ip
}