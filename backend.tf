terraform {
  backend "s3" {
    bucket         = "jatin-serverless-terraform-state-devops"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}