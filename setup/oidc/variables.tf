variable "github_repository" {
  description = "GitHub repository in format 'owner/repo'"
  type        = string
  # Example: "your-username/terraform-vpc-project"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}
