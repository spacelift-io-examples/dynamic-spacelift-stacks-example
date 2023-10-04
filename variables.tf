variable "aws_account" {
  description = "AWS Account Name with environment"
  type        = string
}

variable "project_root" {
  description = "Project root"
  type        = string
}

variable "branch_name" {
  description = "Branch name"
  type        = string
}
variable "cloud_integration_id" {
  description = "Spacelift Cloud Integration id"
  type        = string
}

variable "context_id" {
  description = "Spacelift main context id"
  type        = string
}

variable "repository_name" {
  description = "Name of repository in vc-vantage org"
  type        = string
}

variable "space_id" {
  description = "Spacelift Space ID"
  type        = string
}

# Optional values
variable "terraform_version" {
  description = "Terraform version"
  type        = string
  default     = "1.3.7"
}
