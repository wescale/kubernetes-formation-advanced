data "template_file" "data_file" {
  template = "${file("data.tpl")}"

  vars {
    zone_id  = "${aws_route53_zone.demo_private_zone.zone_id}"
    vpc_cidr = "${var.vpc_cidr}"
    vpc_id   = "${aws_vpc.demo_vpc.id}"

    priv_a_cidr = "${var.private_subnet_a_cidr}"
    priv_a_id   = "${aws_subnet.demo_sn_private_a.id}"
    priv_a_nat  = "${aws_nat_gateway.demo_nat_a_gw.id}"

    priv_b_cidr = "${var.private_subnet_b_cidr}"
    priv_b_id   = "${aws_subnet.demo_sn_private_b.id}"
    priv_b_nat  = "${aws_nat_gateway.demo_nat_b_gw.id}"

    priv_c_cidr = "${var.private_subnet_c_cidr}"
    priv_c_id   = "${aws_subnet.demo_sn_private_c.id}"
    priv_c_nat  = "${aws_nat_gateway.demo_nat_c_gw.id}"

    pub_a_cidr = "${var.public_subnet_a_cidr}"
    pub_a_id   = "${aws_subnet.demo_sn_public_a.id}"

    pub_b_cidr = "${var.public_subnet_b_cidr}"
    pub_b_id   = "${aws_subnet.demo_sn_public_b.id}"

    pub_c_cidr = "${var.public_subnet_c_cidr}"
    pub_c_id   = "${aws_subnet.demo_sn_public_c.id}"
  }
}

resource "local_file" "foo" {
  content  = "${data.template_file.data_file.rendered}"
  filename = "${path.module}/../data.yaml"
}

output "sn_public_a_id" {
  value = "${aws_subnet.demo_sn_public_a.id}"
}

output "sn_public_b_id" {
  value = "${aws_subnet.demo_sn_public_b.id}"
}

output "sn_public_c_id" {
  value = "${aws_subnet.demo_sn_public_c.id}"
}

output "sn_private_a_id" {
  value = "${aws_subnet.demo_sn_private_a.id}"
}

output "sn_private_b_id" {
  value = "${aws_subnet.demo_sn_private_b.id}"
}

output "sn_private_c_id" {
  value = "${aws_subnet.demo_sn_private_c.id}"
}

output "sn_private_array" {
  value = [
    "${aws_subnet.demo_sn_private_a.id}",
    "${aws_subnet.demo_sn_private_b.id}",
    "${aws_subnet.demo_sn_private_c.id}",
  ]
}

output "sn_public_array" {
  value = [
    "${aws_subnet.demo_sn_public_a.id}",
    "${aws_subnet.demo_sn_public_b.id}",
    "${aws_subnet.demo_sn_public_c.id}",
  ]
}

output "vpc_id" {
  value = "${aws_vpc.demo_vpc.id}"
}

output "vpc_cidr" {
  value = "${var.vpc_cidr}"
}

output "private_dns_zone" {
  value = "${var.private_dns_zone}"
}

output "private_dns_zone_id" {
  value = "${aws_route53_zone.demo_private_zone.zone_id}"
}
