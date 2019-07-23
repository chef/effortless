data "template_file" "install-hab" {
  template = "${file("${path.module}/../templates/install-hab.sh.tpl")}"

  vars {
    ssh_user = "${var.ssh_user}"
  }
}

data "template_file" "hab-sup" {
  template = "${file("${path.module}/../templates/hab-sup.service")}"

  vars {
    flags = ""
  }
}

resource "aws_instance" "default" {
  connection {
    user        = "${var.ssh_user}"
    private_key = "${file("${var.aws_key_pair_file}")}"
    agent       = false
  }

  ami                         = "${data.aws_ami.centos.id}"
  instance_type               = "m5.large"
  key_name                    = "${var.aws_key_pair_name}"
  subnet_id                   = "${aws_subnet.default.id}"
  vpc_security_group_ids      = ["${aws_security_group.default.id}"]
  associate_public_ip_address = true
  ebs_optimized               = true

  root_block_device {
    delete_on_termination = true
    volume_size           = 100
    volume_type           = "gp2"
  }

  tags {
    Name       = "${format("${var.aws_key_pair_name}_${random_id.random.hex}_%02d", count.index + 1)}"
    X-Contact     = "${var.tag_contact}"
    X-TTL         = "${var.tag_ttl}"
  }

  provisioner "file" {
    content     = "${data.template_file.hab-sup.rendered}"
    destination = "/home/${var.ssh_user}/hab-sup.service"
  }

  provisioner "file" {
    content     = "${data.template_file.install-hab.rendered}"
    destination = "/tmp/install-hab.sh"
  }

  provisioner "file" {
    content     = "hab svc log"
    destination = "/tmp/svc-load.log"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${format("${var.aws_key_pair_name}_${random_id.random.hex}_%02d", count.index + 1)}",
      "chmod +x /tmp/install-hab.sh",
      "sudo /tmp/install-hab.sh",
      # https://github.com/habitat-sh/habitat/issues/6260
      "sudo hab svc load ${habitat_origin}/${habitat_package} --strategy at-once >> /tmp/svc-load.log 2>&1",
      ]
  }
}
