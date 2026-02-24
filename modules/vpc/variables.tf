variable "name_prefix" {
  type = string
}

variable "environment" {
  type = string
}

variable "creator" {
  type = string
}

variable "purpose" {
  type    = string
  default = "three-tier-architecture"
}

variable "vpc_cidr" {
  type = string
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

variable "azs" {
  type = list(string)
}