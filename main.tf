resource "aws_s3_bucket" "terraform_state" {
  bucket = "jatin-serverless-terraform-state-devops"

  tags = {
    Name        = "Terraform State Bucket"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform Lock Table"
    Environment = "dev"
  }
}

module "website" {
  source = "./modules/website"

  bucket_name = "jatin-serverless-website-devops"
}

module "database" {
  source = "./modules/database"

  table_name = "jatin-messages-table"
}

module "api" {
  source = "./modules/api"

  table_name = module.database.table_name
}