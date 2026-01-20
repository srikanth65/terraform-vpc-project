variable "github_repository" {
  description = "GitHub repository in format 'owner/repo'"
  type        = string
  default     = "*/terraform-vpc-project"
  # Example: "your-username/terraform-vpc-project"
  # Use wildcard "*" for username if you want to allow any owner
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}
