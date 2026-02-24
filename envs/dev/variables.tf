variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "name_prefix" {
  type    = string
  default = "jatin-devops-iac2"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "creator" {
  type    = string
  default = "Jatin"
}

# Network
variable "vpc_cidr" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "app_subnet_cidrs" {
  type = list(string)
}

variable "db_subnet_cidrs" {
  type = list(string)
}
variable "db_password" {
  type      = string
  sensitive = true
}