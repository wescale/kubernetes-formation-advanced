output "sg_bastion" {
  value = "${aws_security_group.allow_ssh.id}"
}
