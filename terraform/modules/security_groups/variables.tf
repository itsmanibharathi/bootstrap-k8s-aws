variable "project_name" {
  type        = string
  description = "Project name for naming/tagging"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "jumpbox_ssh_cidr" {
  type        = string
  description = "CIDR allowed to SSH to jumpbox"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private subnet CIDRs used by internal NLB"
}

variable "tags" {
  type        = map(string)
  description = "Common tags"
  default     = {}
}


