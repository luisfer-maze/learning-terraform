# Creates/manages KMS CMK
resource "aws_kms_key" "dynamo_db_kms" {
  description              = "Key used to encrypt DynamoDB data"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  is_enabled               = true
  enable_key_rotation      = true
}

# Add an alias to the key
resource "aws_kms_alias" "by_alias" {
  name          = "alias/dfw-ewt-key"
  target_key_id = aws_kms_key.dynamo_db_kms.key_id
}

#Creates the Dynamo DB table
resource "aws_dynamodb_table" "ewt-dynamo-db-table" {
  name                        = var.dynamo_db_table_name
  billing_mode                = var.dynamo_db_table_billing_mode
  hash_key                    = "TenantId_ContactNo"
  range_key                   = ""
  deletion_protection_enabled = var.enable_deletion_protection

  attribute {
    name = "TenantId_ContactNo"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.dynamo_db_kms.arn
  }
}
