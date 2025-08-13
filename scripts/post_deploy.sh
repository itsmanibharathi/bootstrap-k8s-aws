#!/bin/bash

set -euo pipefail

# --- locate repo root or script dir ---
if git rev-parse --show-toplevel >/dev/null 2>&1; then
  REPO_ROOT="$(git rev-parse --show-toplevel)"
else
  REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
fi


JUMPBOX_KEY_NAME="jumpbox-key"
CONTROL_KEY_NAME="controlplane-key"
WORKER_KEY_NAME="workernode-key"
EXUSION_USER="root"
SSH_LOCAL_PATH="$REPO_ROOT/ssh"
SSH_REMOTE_PATH="~/.ssh"

TERRAFORM_DIR="$REPO_ROOT/terraform"
ANSIBLE_DIR="$REPO_ROOT/ansible"
SSH_DIR="$REPO_ROOT/ssh"

# --- ansible output ---

echo "🔍 Fetching Terraform outputs..."
TF_OUTPUT=$(terraform -chdir="${TERRAFORM_DIR}" output -json)
echo "TF_OUTPUT: $TF_OUTPUT"

JUMPBOX_NAME=$(echo "$TF_OUTPUT" | jq -r '.jumpbox_name.value')
JUMPBOX_IP=$(echo "$TF_OUTPUT" | jq -r '.jumpbox_public_ip.value')
JUMPBOX_PRIVATE_IP=$(echo "$TF_OUTPUT" | jq -r '.jumpbox_private_ip.value')
CONTROL_NAMES=($(echo "$TF_OUTPUT" | jq -r '.control_plane_names.value[]'))
CONTROL_PRIVATE_IP=($(echo "$TF_OUTPUT" | jq -r '.control_plane_private_ips.value[]'))
WORKER_NAMES=($(echo "$TF_OUTPUT" | jq -r '.worker_names.value[]'))
WORKER_PRIVATE_IP=($(echo "$TF_OUTPUT" | jq -r '.worker_private_ips.value[]'))

# --- Ansible inventory ---
ANSIBLE_INVENTORY_FILE="$ANSIBLE_DIR/inventory.ini"
echo "🔧 Generating Ansible inventory at $ANSIBLE_INVENTORY_FILE..."

cat > "$ANSIBLE_INVENTORY_FILE" <<EOF
[jumpbox]
$JUMPBOX_NAME

[control_plane]
$(
for i in "${!CONTROL_NAMES[@]}"; do
  echo "${CONTROL_NAMES[$i]}"
done)

[worker_nodes]
$(
for i in "${!WORKER_NAMES[@]}"; do
  echo "${WORKER_NAMES[$i]}"
done)

EOF


#  # --- SSH config ---

ssh_config() {
  local path="$1"
  local include_proxy="$2"

  [[ -n "$path" && "${path: -1}" != "/" ]] && path="${path}/"
  if [ "$include_proxy" = true ]; then
    # jumpbox entry
    echo "Host $JUMPBOX_NAME jumpbox"
    echo "    HostName $JUMPBOX_IP"
    echo "    User $EXUSION_USER"
    echo "    IdentityFile ${path}${JUMPBOX_KEY_NAME}"
    echo "    ForwardAgent yes"
    echo "    StrictHostKeyChecking no"
    echo ""
  fi

  echo "# ==================="
  echo "# Control Plane Nodes"
  echo "# ==================="
  for i in "${!CONTROL_NAMES[@]}"; do
    NAME="${CONTROL_NAMES[$i]} cp-$((i+1))"   # two aliases on one Host line is fine
    IP="${CONTROL_PRIVATE_IP[$i]}"
    echo "Host $NAME"
    echo "    HostName $IP"
    echo "    User $EXUSION_USER"
    echo "    IdentityFile ${path}${CONTROL_KEY_NAME}"
    if [ "$include_proxy" = true ]; then
      echo "    ProxyJump jumpbox"
      echo "    StrictHostKeyChecking no"
    fi
    echo ""
  done

  if [ "${#WORKER_NAMES[@]}" -gt 0 ]; then
    echo "# ================"
    echo "# Worker Nodes"
    echo "# ================"
    for i in "${!WORKER_NAMES[@]}"; do
      NAME="${WORKER_NAMES[$i]} worker-$((i+1))"
      IP="${WORKER_PRIVATE_IP[$i]}"
      echo "Host $NAME"
      echo "    HostName $IP"
      echo "    User $EXUSION_USER"
      echo "    IdentityFile ${path}${WORKER_KEY_NAME}"
      if [ "$include_proxy" = true ]; then
        echo "    ProxyJump jumpbox"
        echo "    StrictHostKeyChecking no"
      fi
      echo ""
    done
  fi
}
# --- Generate SSH config ---
CONFIG_FILE=$(mktemp)
ssh_config "$SSH_LOCAL_PATH" true > $SSH_LOCAL_PATH/config

ssh_config "$SSH_REMOTE_PATH" false > $CONFIG_FILE



