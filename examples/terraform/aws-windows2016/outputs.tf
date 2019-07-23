output "public_ip_list" {
  value = "${aws_instance.default.*.public_ip}"
}

output "random_string" {
  value = "${random_string.random.result}"
}
