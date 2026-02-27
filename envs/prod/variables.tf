variable "project_prefix" { type = string }
variable "account_id"     { type = string }
variable "region"         { type = string }

variable "artifacts_bucket_name" { type = string }
variable "eb_app_name"           { type = string }
variable "eb_env_name"           { type = string }

variable "codebuild_project_name" { type = string }
variable "codebuild_log_group"    { type = string }

variable "codebuild_role_name"    { type = string }
variable "codepipeline_role_name" { type = string }

variable "eb_service_role_name"     { type = string }
variable "eb_ec2_role_name"         { type = string }
variable "eb_instance_profile_name" { type = string }