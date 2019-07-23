output "public_ip_list" {
  value = "${aws_instance.default.*.public_ip}"
}
