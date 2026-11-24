variable "project_name" {
  description = "Prefix used to name every resource."
  type        = string
  default     = "parcial-ecs"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,20}$", var.project_name))
    error_message = "project_name must be 3-21 chars: lowercase letters, digits and hyphens, starting with a letter."
  }
}

variable "aws_region" {
  description = "AWS region where the infrastructure is created."
  type        = string
  default     = "us-east-1"
}

variable "github_repository" {
  description = "GitHub repository with the Dockerfile, in 'owner/name' format."
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$", var.github_repository))
    error_message = "github_repository must use the 'owner/name' format."
  }
}

variable "github_branch" {
  description = "Branch whose pushes trigger the pipeline."
  type        = string
  default     = "main"
}

variable "codeconnection_arn" {
  description = "ARN of an existing AWS CodeConnections connection to GitHub, already in AVAILABLE status."
  type        = string

  validation {
    condition     = can(regex("^arn:aws:(codeconnections|codestar-connections):", var.codeconnection_arn))
    error_message = "codeconnection_arn must be a CodeConnections (or CodeStar Connections) ARN."
  }
}
