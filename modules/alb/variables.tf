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

variable "public_subnet_ids" {
  type = list(string)
}

variable "alb_sg_id" {
  type = string
}

variable "app_asg_name" {
  type = string
}