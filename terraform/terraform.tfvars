region = "us-east-1"

# Replace with your source IP in CIDR format, e.g., "203.0.113.10/32"
jumpbox_ssh_cidr = "0.0.0.0/0"

# Existing AWS key pair names (do not create in Terraform)
jumpbox_key_name      = "jumpbox-key"
controlplane_key_name = "controlnode-key"
workernode_key_name   = "workernode-key"


