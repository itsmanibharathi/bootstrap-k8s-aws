variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for tagging"
  type        = string
  default     = "k8s-ha-cluster"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the three private subnets (a, b, c)"
  type        = list(string)
  default = [
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24",
  ]
}

variable "azs" {
  description = "Availability Zones used for the subnets"
  type        = list(string)
  default = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c",
  ]
}

variable "jumpbox_ssh_cidr" {
  description = "CIDR allowed to SSH into the jumpbox (e.g., your_ip/32)"
  type        = string
}


variable "jumpbox_instance_type" {
  description = "Instance type for jumpbox"
  type        = string
  default     = "t3.micro"
}

variable "controlplane_instance_type" {
  description = "Instance type for control plane nodes"
  type        = string
  default     = "t3.medium"
}

variable "workernode_instance_type" {
  description = "Instance type for worker nodes"
  type        = string
  default     = "t3.large"
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 0
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

locals {
  common_tags = {
    Project = var.project_name
    owner   = "mani"
  }
}

variable "jumpbox_key_path" {
  default = "ssh/jumpbox-key.pub"
}

variable "controlplane_key_path" {
  default = "ssh/controlplane-key.pub"
}

variable "workernode_key_path" {
  default = "ssh/workernode-key.pub"
}