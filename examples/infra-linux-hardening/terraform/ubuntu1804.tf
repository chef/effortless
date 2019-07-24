data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # Canonical
  owners = ["099720109477"]
}

resource "aws_instance" "default" {
  connection {
    host        = coalesce(self.public_ip, self.private_ip)
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(var.aws_key_pair_file)
  }

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = var.aws_key_pair_name
  subnet_id                   = aws_subnet.default.id
  vpc_security_group_ids      = [aws_security_group.default.id]
  associate_public_ip_address = true

  root_block_device {
    delete_on_termination = true
    volume_size           = 30
    volume_type           = "gp2"
  }

  tags = {
    Name      = "${var.aws_key_pair_name}_${random_id.random.hex}_%02d"
    X-Contact = var.tag_contact
  }

  # Build/Export tar archive (This is ran on the machine running Terraform)
  # `hab studio run` is used because export as tar is only supported on Linux
  provisioner "local-exec" {
    working_dir = "../"
    environment = {
      HAB_LICENSE = var.chef_license
    }
    command = <<EOT
      hab pkg build .
      hab studio run 'cd results && source last_build.env && hab pkg export tar $pkg_artifact && mv $pkg_origin-$pkg_name-$pkg_version-$pkg_release.tar.gz hab_artifact.tar.gz'
    EOT
  }

  # Copy tar archive to remote machine
  provisioner "file" {
    source = "../results/hab_artifact.tar.gz"
    destination = "/tmp/hab_artifact.tar.gz"
  }

  # Copy last_build.env (needed to extract variables during install)
  provisioner "file" {
    source = "../results/last_build.env"
    destination = "/tmp/last_build.env"
  }

  # Setup Habitat, extract/install, execute Chef Infra
  provisioner "remote-exec" {
    inline = [
      "export HAB_LICENSE=${var.chef_license}",
      "sudo useradd hab",
      "sudo tar xf /tmp/hab_artifact.tar.gz -C /",
      ". /tmp/last_build.env", # Using `.` here instead of `source` for POSIX compliance (needed for Ubuntu)
      "pkg_prefix=$(find \"/hab/pkgs/$pkg_origin/$pkg_name\" -maxdepth 2 -mindepth 2 | sort | tail -n 1)",
      "cd $pkg_prefix", # Required for paths to be correct with `hab pkg exec`
      "sudo -E /hab/bin/hab pkg exec \"$pkg_origin/$pkg_name\" chef-client -z -c \"$pkg_prefix/config/bootstrap-config.rb\""
    ]
  }

  # Run Chef InSpec Tests (from local machine to remote machine)
  provisioner "local-exec" {
    working_dir = "../"
    environment = {
      CHEF_LICENSE = var.chef_license
    }
    command = <<EOT
      inspec exec test/functional \
        -t ssh://${var.ssh_user}@${aws_instance.default.public_ip} \
        -i ${var.aws_key_pair_file} \
        --sudo
    EOT
  }
}
