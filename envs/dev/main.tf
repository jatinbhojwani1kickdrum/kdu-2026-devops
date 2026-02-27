module "artifacts" {
  source      = "../../modules/artifacts_bucket"
  bucket_name = var.artifacts_bucket_name
}

module "codebuild_iam" {
  source              = "../../modules/iam_codebuild"
  role_name           = var.codebuild_role_name
  artifacts_bucket_arn = module.artifacts.bucket_arn
}

module "codebuild" {
  source          = "../../modules/codebuild"
  project_name    = var.codebuild_project_name
  service_role_arn = module.codebuild_iam.role_arn
  log_group_name  = var.codebuild_log_group
}

module "eb_app" {
  source     = "../../modules/elasticbeanstalk_app"
  app_name   = var.eb_app_name
  create_app = true
}

module "eb_env" {
  source                = "../../modules/elasticbeanstalk_env"
  app_name              = var.eb_app_name
  env_name              = var.eb_env_name
  service_role_name     = var.eb_service_role_name
  ec2_role_name         = var.eb_ec2_role_name
  instance_profile_name = var.eb_instance_profile_name
  environment_type      = "SingleInstance"
  instance_type         = "t3.micro"
}

module "codepipeline_iam" {
  source               = "../../modules/iam_codepipeline"
  role_name            = var.codepipeline_role_name
  artifacts_bucket_arn = module.artifacts.bucket_arn
  codebuild_project_arn = module.codebuild.project_arn

  eb_service_role_arn = module.eb_env.eb_service_role_arn
  eb_ec2_role_arn     = module.eb_env.eb_ec2_role_arn
  codebuild_role_arn  = module.codebuild_iam.role_arn
}

output "dev_eb_cname" {
  value = module.eb_env.cname
}