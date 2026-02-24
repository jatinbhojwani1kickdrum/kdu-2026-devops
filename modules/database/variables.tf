variable "name_prefix" { type = string }
variable "environment" { type = string }
variable "creator"     { type = string }

variable "db_subnet_ids" {
  type = list(string)
}

variable "db_sg_id" {
  type = string
}

variable "db_name" {
  type    = string
  default = "company"
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}