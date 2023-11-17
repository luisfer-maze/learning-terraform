variable "dynamo_db_table_name" {
  description = "DynamoDB table name"
  type        = string
  default     = "ewt-dynamo-db-table"
}

variable "dynamo_db_table_billing_mode" {
  description = "Billing mode for DynamoDB table"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "enable_deletion_protection" {
  description = "Enables deletion protection"
  type        = bool
  default     = false
}
