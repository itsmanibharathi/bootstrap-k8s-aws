variable "project_name" {
  type        = string
  description = "Project name for naming/tagging"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for NLB"
}

variable "control_plane_instance_ids" {
  type        = list(string)
  description = "Control plane instance IDs to register in target group"
}

variable "tags" {
  type        = map(string)
  description = "Common tags"
  default     = {}
}


