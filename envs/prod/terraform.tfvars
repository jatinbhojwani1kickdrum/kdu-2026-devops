project_prefix = "jatin-ci-cd"
account_id     = "743298171118"
region         = "us-east-2"

# Reuse the SAME bucket
artifacts_bucket_name = "jatin-ci-cd-artifacts-us-east-2"

# Reuse SAME EB App, only env changes
eb_app_name = "jatin-ci-cd-app"
eb_env_name = "jatin-ci-cd-prod-env"

# Prod CodeBuild project name/log group
codebuild_project_name = "jatin-ci-cd-build-prod"
codebuild_log_group    = "/aws/codebuild/jatin-ci-cd-build-prod"

codebuild_role_name    = "jatin-ci-cd-codebuild-role-prod"
codepipeline_role_name = "jatin-ci-cd-codepipeline-role-prod"

eb_service_role_name     = "jatin-ci-cd-eb-service-role-prod"
eb_ec2_role_name         = "jatin-ci-cd-eb-ec2-role-prod"
eb_instance_profile_name = "jatin-ci-cd-eb-instance-profile-prod"