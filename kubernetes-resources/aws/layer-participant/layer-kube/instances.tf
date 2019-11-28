resource "aws_security_group" "sg_kubernetes" {
  name        = "sg_kubernetes"
  description = "Allow SSH traffic"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  # for ETCD
  egress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  tags {
    Name = "sg_for_bastion"
  }
}

// resource "aws_instance" "master" {
//   ami                         = "ami-3548444c"
//   instance_type               = "m3.medium"
//   vpc_security_group_ids      = ["${aws_security_group.sg_kubernetes.id}"]
//   subnet_id                   = "${var.subnet_a}"
//   associate_public_ip_address = false
//   key_name                    = "sandbox-key"
//   user_data                   = "${file("${path.cwd}/layer-kube/bootstrap.sh")}"

//   count = "${var.nb-participants}"

//   tags {
//     Role = "master"
//     Name = "master-${count.index}"
//   }
// }

// resource "aws_route53_record" "master-dns" {
//   count   = "${var.nb-participants}"
//   zone_id = "${var.private_dns_zone_id}"
//   name    = "master-${count.index}.${var.private_dns_zone}"
//   type    = "CNAME"
//   ttl     = "300"
//   records = ["${element(aws_instance.master.*.private_dns, count.index)}"]
// }

// resource "aws_instance" "worker-a" {
//   count                       = "${var.nb-participants}"
//   ami                         = "ami-3548444c"
//   instance_type               = "m3.medium"
//   vpc_security_group_ids      = ["${aws_security_group.sg_kubernetes.id}"]
//   subnet_id                   = "${var.subnet_a}"
//   associate_public_ip_address = false
//   key_name                    = "sandbox-key"
//   user_data                   = "${file("${path.cwd}/layer-kube/bootstrap.sh")}"

//   tags {
//     Role = "worker-a"
//     Name = "worker-a-${count.index}"
//   }
// }

// resource "aws_route53_record" "worker-a-dns" {
//   count   = "${var.nb-participants}"
//   zone_id = "${var.private_dns_zone_id}"
//   name    = "worker-a-${count.index}.${var.private_dns_zone}"
//   type    = "CNAME"
//   ttl     = "300"
//   records = ["${element(aws_instance.worker-a.*.private_dns, count.index)}"]
// }

// resource "aws_instance" "worker-b" {
//   count                       = "${var.nb-participants}"
//   ami                         = "ami-3548444c"
//   instance_type               = "m3.medium"
//   vpc_security_group_ids      = ["${aws_security_group.sg_kubernetes.id}"]
//   subnet_id                   = "${var.subnet_b}"
//   associate_public_ip_address = false
//   key_name                    = "sandbox-key"
//   // user_data                   = "${file("${path.cwd}/layer-kube/bootstrap.sh")}"

//   tags {
//     Role = "worker-b"
//     Name = "worker-b-${count.index}"
//   }
// }

// resource "aws_route53_record" "worker-b-dns" {
//   count   = "${var.nb-participants}"
//   zone_id = "${var.private_dns_zone_id}"
//   name    = "worker-b-${count.index}.${var.private_dns_zone}"
//   type    = "CNAME"
//   ttl     = "300"
//   records = ["${element(aws_instance.worker-b.*.private_dns, count.index)}"]
// }

// resource "aws_instance" "worker-c" {
//   count                       = "${var.nb-participants}"
//   ami                         = "ami-3548444c"
//   instance_type               = "m3.medium"
//   vpc_security_group_ids      = ["${aws_security_group.sg_kubernetes.id}"]
//   subnet_id                   = "${var.subnet_c}"
//   associate_public_ip_address = false
//   key_name                    = "sandbox-key"
//   // user_data                   = "${file("${path.cwd}/layer-kube/bootstrap.sh")}"

//   tags {
//     Role = "worker-c"
//     Name = "worker-c-${count.index}"
//   }
// }

// resource "aws_route53_record" "worker-c-dns" {
//   count   = "${var.nb-participants}"
//   zone_id = "${var.private_dns_zone_id}"
//   name    = "worker-c-${count.index}.${var.private_dns_zone}"
//   type    = "CNAME"
//   ttl     = "300"
//   records = ["${element(aws_instance.worker-c.*.private_dns, count.index)}"]
// }
