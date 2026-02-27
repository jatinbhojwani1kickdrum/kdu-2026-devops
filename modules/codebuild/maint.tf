resource "aws_codebuild_project" "this" {
  name          = var.project_name
  description   = "Build project for CI/CD Spring Boot app"
  service_role  = var.service_role_arn
  build_timeout = 30

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.buildspec
  }

  logs_config {
    cloudwatch_logs {
      group_name  = var.log_group_name
      stream_name = var.log_stream_name
    }
  }
}