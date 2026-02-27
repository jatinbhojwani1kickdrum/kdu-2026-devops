project_prefix = "jatin-ci-cd"
account_id     = "743298171118"
region         = "us-east-2"

artifacts_bucket_name = "jatin-ci-cd-artifacts-us-east-2"

eb_app_name = "jatin-ci-cd-app"
eb_env_name = "jatin-ci-cd-dev-env"

codebuild_project_name = "jatin-ci-cd-build"
codebuild_log_group    = "/aws/codebuild/jatin-ci-cd-build"

codebuild_role_name    = "jatin-ci-cd-codebuild-role"
codepipeline_role_name = "jatin-ci-cd-codepipeline-role"

eb_service_role_name     = "jatin-ci-cd-eb-service-role"
eb_ec2_role_name         = "jatin-ci-cd-eb-ec2-role"
eb_instance_profile_name = "jatin-ci-cd-eb-instance-profile"