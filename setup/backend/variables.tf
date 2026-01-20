variable "bucket_name" {
  description = "S3 bucket name for Terraform state"
  type        = string
  default     = ""
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for state locking"
  type        = string
  default     = "terraform-locks"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}
