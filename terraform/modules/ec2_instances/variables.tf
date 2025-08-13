variable "project_name" {
  type        = string
  description = "Project name for naming/tagging"
}

variable "public_subnet_id" {
  type        = string
  description = "Public subnet ID for jumpbox"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs"
}

variable "jumpbox_sg_id" {
  type        = string
  description = "Security group ID for jumpbox"
}

variable "control_plane_sg_id" {
  type        = string
  description = "Security group ID for control plane nodes"
}

variable "worker_sg_id" {
  type        = string
  description = "Security group ID for worker nodes"
}

variable "jumpbox_key_path" {
  type = string
}

variable "controlplane_key_path" {
  type = string
}

variable "workernode_key_path" {
  type = string
}

variable "jumpbox_instance_type" {
  type = string
}

variable "controlplane_instance_type" {
  type = string
}

variable "workernode_instance_type" {
  type = string
}

variable "worker_count" {
  type = number
}

variable "tags" {
  type        = map(string)
  description = "Common tags"
  default     = {}
}

data "aws_ami" "debian_12" {
  most_recent = true
  owners      = ["136693071363"] # Debian

  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

variable "controlplane_data_volume_size_gb" {
  type    = number
  default = 50
}
variable "worker_data_volume_size_gb" {
  type    = number
  default = 50
}
variable "data_volume_type" {
  type    = string
  default = "gp3"
}

