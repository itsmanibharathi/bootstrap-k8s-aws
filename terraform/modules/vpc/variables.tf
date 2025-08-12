variable "project_name" {
  type        = string
  description = "Project name for naming/tagging"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
}

variable "tags" {
  type        = map(string)
  description = "Common tags"
  default     = {}
}


