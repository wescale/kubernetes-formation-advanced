output "sg_bastion" {
  value = "${aws_security_group.allow_ssh.id}"
}

output "list_bastion" {
  value = "${join(",",aws_instance.bastion.*.public_ip)}"
}
