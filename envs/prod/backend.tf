terraform {
  backend "s3" {
    bucket         = "jatin-ci-cd-terraformstate-1"
    key            = "prod/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "jatin-terraform-locks-CI_CD"
    encrypt        = true
  }
}