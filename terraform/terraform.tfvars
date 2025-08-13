region = "us-east-1"

# Replace with your source IP in CIDR format, e.g., "203.0.113.10/32"
jumpbox_ssh_cidr = "0.0.0.0/0"
jumpbox_key_path = "../ssh/jumpbox-key.pub"
controlplane_key_path = "../ssh/controlplane-key.pub"
workernode_key_path = "../ssh/workernode-key.pub"