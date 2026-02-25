locals {
  common_tags = {
    Environment = var.environment
    Creator     = var.creator
    Project     = var.name_prefix
  }
}

# DB Subnet Group
resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-${var.environment}-dbsubnet"
  subnet_ids = var.db_subnet_ids

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-${var.environment}-dbsubnet"
  })
}

# RDS MySQL Instance
resource "aws_db_instance" "this" {
  identifier = "${var.name_prefix}-${var.environment}-mysql"

  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = var.instance_class
  allocated_storage    = 20
  storage_type         = "gp2"
  storage_encrypted    = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.db_sg_id]

  publicly_accessible        = false
  multi_az                   = false
  auto_minor_version_upgrade = false
  deletion_protection        = false
  skip_final_snapshot        = true

  tags = merge(local.common_tags, {
    Name = "${var.name_prefix}-${var.environment}-mysql"
  })
}