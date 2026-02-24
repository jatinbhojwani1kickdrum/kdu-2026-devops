variable "name_prefix" {
  type = string
}

variable "environment" {
  type = string
}

variable "creator" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "app_subnet_ids" {
  type = list(string)
}

variable "bastion_sg_id" {
  type = string
}

variable "app_sg_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type = string
}


variable "db_endpoint" { type = string }
variable "db_username" { type = string }
variable "db_password" {
  type      = string
  sensitive = true
}

variable "frontend_repo" { type = string }
variable "backend1_repo" { type = string }
variable "backend2_repo" { type = string }