# Required variables. Create a terraform.tfvars.

variable "aws_key_pair_name" {
  description = "The name of the key pair to associate with your instances. Required for SSH access."
}

variable "aws_key_pair_file" {
  description = "The path to the file on disk for the private key associated with the AWS key pair associated with your instances. Required for SSH access."
}

variable "aws_region" {
  description = "The name of the selected AWS region / datacenter. Example: us-west-2"
}

variable "chef_license" {
  description = "How the Chef License should be accepted. Example: accept-no-persist"
}

variable "tag_contact" {
  description = "The email address associated with the person or team that is standing up this resource. Used to contact if problems occur."
}

# AWS (defaults should be sufficient)

variable "aws_profile" {
  default     = "default"
  description = "The AWS profile to use from your ~/.aws/credentials file."
}

variable "ssh_user" {
  default     = "ubuntu"
  description = "The user used for SSH connections and path variables."
}
