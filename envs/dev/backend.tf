terraform {
  backend "s3" {
    bucket         = "jatin-devops-iac2-tfstate-1"
    key            = "dev/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "jatin-devops-iac2-tflock-dev"
    encrypt        = true
  }
}