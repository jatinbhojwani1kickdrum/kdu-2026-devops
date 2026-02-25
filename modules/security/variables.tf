variable "name_prefix" {
  type = string
}

variable "environment" {
  type = string
}

variable "creator" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into bastion"
  type        = string
}