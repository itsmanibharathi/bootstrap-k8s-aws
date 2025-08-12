variable "project_name" {
  type        = string
  description = "Project name for naming/tagging"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "public_subnet_cidr" {
  type        = string
  description = "Public subnet CIDR"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private subnet CIDRs (3)"
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones for subnets"
}

variable "tags" {
  type        = map(string)
  description = "Common tags"
  default     = {}
}


