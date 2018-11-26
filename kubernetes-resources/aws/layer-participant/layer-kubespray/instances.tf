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

  tags {
    Name = "sg_for_bastion"
  }
}

variable "count_master" {
  default = 1
}

resource "aws_instance" "master" {
  count = "${var.count_master}"
  ami                         = "ami-00035f41c82244dab"
  instance_type               = "m3.medium"
  vpc_security_group_ids      = ["${aws_security_group.sg_kubernetes.id}"]
  subnet_id                   = "${var.subnet_a}"
  associate_public_ip_address = false
  key_name                    = "sandbox-key"
  user_data                   = "${file("bootstrap.sh")}"

  tags {
    Role = "master"
    Name = "master-${count.index}"
  }
}

resource "aws_route53_record" "master-dns" {
  count = "${var.count_master}"
  zone_id = "${data.terraform_remote_state.layer-base.private_dns_zone_id}"
  name    = "master-${count.index}.${data.terraform_remote_state.layer-base.private_dns_zone}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${element(aws_instance.master.*.private_dns, count.index)}"]
}



variable "count_worker" {
  default = 2
}


resource "aws_instance" "worker" {
  count = "${var.count_worker}"
  ami                         = "ami-00035f41c82244dab"
  instance_type               = "m3.medium"
  vpc_security_group_ids      = ["${aws_security_group.sg_kubernetes.id}"]
  subnet_id                   = "${var.subnet_a}"
  associate_public_ip_address = false
  key_name                    = "sandbox-key"
  user_data                   = "${file("bootstrap.sh")}"

  tags {
    Role = "worker"
    Name = "worker-${count.index}"
  }
}


resource "aws_route53_record" "worker-dns" {
  count = "${var.count_worker}"
  zone_id = "${data.terraform_remote_state.layer-base.private_dns_zone_id}"
  name    = "worker-${count.index}.${data.terraform_remote_state.layer-base.private_dns_zone}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${element(aws_instance.worker.*.private_dns, count.index)}"]
}

