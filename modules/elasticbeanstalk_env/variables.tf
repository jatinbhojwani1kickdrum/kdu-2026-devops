variable "app_name" {
  type = string
}

variable "env_name" {
  type = string
}

variable "service_role_name" {
  type = string
}

variable "ec2_role_name" {
  type = string
}

variable "instance_profile_name" {
  type = string
}

variable "environment_type" {
  type    = string
  default = "SingleInstance"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "log_retention_days" {
  type    = number
  default = 7
}