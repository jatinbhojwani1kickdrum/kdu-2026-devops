variable "project_name" {
  type = string
}

variable "service_role_arn" {
  type = string
}

variable "buildspec" {
  type    = string
  default = "buildspec.yml"
}

variable "log_group_name" {
  type = string
}

variable "log_stream_name" {
  type    = string
  default = "build-log"
}