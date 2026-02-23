resource "aws_dynamodb_table" "messages" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST" # on-demand (cheap)
  hash_key     = "messageId"

  attribute {
    name = "messageId"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    Name        = "Messages Table"
    Environment = "dev"
  }
}