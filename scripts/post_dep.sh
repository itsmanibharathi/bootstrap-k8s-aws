#!/bin/bash

set -e

# 🔧 Config
JUMPBOX_KEY_NAME="jumpbox-key"
CONTROL_KEY_NAME="controlnode-key"
WORKER_KEY_NAME="workernode-key"
EXUSION_USER="root"
SSH_LOCAL_PATH="./ssh"
SSH_REMOTE_PATH="~/.ssh"

echo "🔍 Fetching Terraform outputs..."
TF_OUTPUT=$(terraform -chdir=./terraform output -json)

JUMPBOX_IP=$(echo "$TF_OUTPUT" | jq -r '.jumpbox_public_ip.value')
JUMPBOX_PRIVATE_IP=$(echo "$TF_OUTPUT" | jq -r '.jumpbox_private_ip.value')
CONTROL_NAMES=($(echo "$TF_OUTPUT" | jq -r '.control_plane_names.value[]'))
CONTROL_IPS=($(echo "$TF_OUTPUT" | jq -r '.control_plane_private_ips.value[]'))
WORKER_NAMES=($(echo "$TF_OUTPUT" | jq -r '.worker_names.value[]'))
WORKER_IPS=($(echo "$TF_OUTPUT" | jq -r '.worker_private_ips.value[]'))

# # 🪪 Copy SSH keys to jumpbox
# echo "🔑 Copying SSH keys to jumpbox at $JUMPBOX_IP..."
# scp -i "$JUMPBOX_KEY" "$CONTROL_KEY" "$JUMPBOX_USER@$JUMPBOX_IP:/tmp/controlnode-key"
# scp -i "$JUMPBOX_KEY" "$WORKER_KEY" "$JUMPBOX_USER@$JUMPBOX_IP:/tmp/workernode-key"

# # 🛠️ Move keys to /root/.ssh and fix perms
# echo "🛠️  Setting up keys on jumpbox..."
# ssh -i "$JUMPBOX_KEY" "$JUMPBOX_USER@$JUMPBOX_IP" <<'EOF'
#   sudo mkdir -p /root/.ssh
#   sudo mv /tmp/controlnode-key /root/.ssh/
#   sudo mv /tmp/workernode-key /root/.ssh/
#   sudo chmod 600 /root/.ssh/controlnode-key /root/.ssh/workernode-key
# EOF

# 🧾 Generate SSH config locally
# CONFIG_FILE=$(mktemp)
ssh_config() {
  local path="$1"
  local include_proxy="$2"

  [[ -n "$path" && "${path: -1}" != "/" ]] && path="${path}/"
  if [ "$include_proxy" = true ]; then
    # jumpbox entry
    echo "Host jumpbox"
    echo "    HostName $JUMPBOX_IP"
    echo "    User $JUMPBOX_USER"
    echo "    IdentityFile ${path}${JUMPBOX_KEY}"
    echo "    ForwardAgent yes"
    echo "    StrictHostKeyChecking no"
    echo ""
  fi

  echo "# ==================="
  echo "# Control Plane Nodes"
  echo "# ==================="
  for i in "${!CONTROL_NAMES[@]}"; do
    NAME="${CONTROL_NAMES[$i]} cp-$((i+1))"   # two aliases on one Host line is fine
    IP="${CONTROL_IPS[$i]}"
    echo "Host $NAME"
    echo "    HostName $IP"
    echo "    User root"
    echo "    IdentityFile ${path}${CONTROL_KEY}"
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
      IP="${WORKER_IPS[$i]}"
      echo "Host $NAME"
      echo "    HostName $IP"
      echo "    User root"
      echo "    IdentityFile ${path}${WORKER_KEY}"
      if [ "$include_proxy" = true ]; then
        echo "    ProxyJump jumpbox"
        echo "    StrictHostKeyChecking no"
      fi
      echo ""
    done
  fi
}

# ensure output directory exists

# write the file (no need for process substitution)
ssh_config $(pwd) true > ./ssh/config
ssh_config "~/.ssh/" > ../ssh/config2



# # 📦 Copy config to jumpbox
# echo "📤 Uploading SSH config to jumpbox..."
# scp -i "$JUMPBOX_KEY" "$CONFIG_FILE" "$JUMPBOX_USER@$JUMPBOX_IP:/tmp/ssh_config"
# ssh -i "$JUMPBOX_KEY" "$JUMPBOX_USER@$JUMPBOX_IP" \
#   "sudo mv /tmp/ssh_config /root/.ssh/config && \
#    sudo chown root:root /root/.ssh/config && \
#    sudo chmod 600 /root/.ssh/config && \
#    sudo chmod 700 /root/.ssh"

# rm "$CONFIG_FILE"

# # 🚀 SSH Validation Script
# VALIDATE_SCRIPT=$(mktemp)
# chmod +x "$VALIDATE_SCRIPT"

# {
#   echo "#!/bin/bash"
#   echo "set -e"
#   echo 'echo "🔐 Validating control plane nodes..."'
#   for i in "${!CONTROL_NAMES[@]}"; do
#     NAME="cp-$((i+1))"
#     IP="${CONTROL_IPS[$i]}"
#     echo "echo -n '➡️  $NAME ($IP): '"
#     echo "ssh -o StrictHostKeyChecking=no -i /root/.ssh/controlnode-key admin@$IP 'hostname' >/dev/null 2>&1 && echo '✅ SSH Success' || echo '❌ SSH Failed'"
#   done

#   echo 'echo ""'
#   echo 'echo "🔐 Validating worker nodes..."'
#   for i in "${!WORKER_NAMES[@]}"; do
#     NAME="worker-$((i+1))"
#     IP="${WORKER_IPS[$i]}"
#     echo "echo -n '➡️  $NAME ($IP): '"
#     echo "ssh -o StrictHostKeyChecking=no -i /root/.ssh/workernode-key admin@$IP 'hostname' >/dev/null 2>&1 && echo '✅ SSH Success' || echo '❌ SSH Failed'"
#   done
# } > "$VALIDATE_SCRIPT"

# echo "📤 Uploading validation script..."
# scp -i "$JUMPBOX_KEY" "$VALIDATE_SCRIPT" "$JUMPBOX_USER@$JUMPBOX_IP:/tmp/validate_nodes.sh"
# ssh -i "$JUMPBOX_KEY" "$JUMPBOX_USER@$JUMPBOX_IP" "sudo bash /tmp/validate_nodes.sh"

# # 🧹 Cleanup
# rm "$VALIDATE_SCRIPT"

# echo "✅ Done: Keys installed, config generated, SSH validated."


# # what to update /etc/hosts file


# # # 📝 Prepare /etc/hosts entries
# # echo "📚 Updating /etc/hosts on jumpbox..."

# # HOSTS_FILE=$(mktemp)

# # {
# #   # Default system entries
# #   echo "127.0.0.1       localhost"
# #   echo "::1             localhost ip6-localhost ip6-loopback"
# #   echo "ff02::1         ip6-allnodes"
# #   echo "ff02::2         ip6-allrouters"
# #   echo ""
# #   echo "##### Control Plane Nodes #####"
# #   for i in "${!CONTROL_NAMES[@]}"; do
# #     HOST="${CONTROL_NAMES[$i]}"
# #     IP="${CONTROL_IPS[$i]}"
# #     echo "$IP ${HOST}.kubernetes.local ${HOST}"
# #   done
# #   echo ""
# #   echo "##### Worker Nodes #####"
# #   for i in "${!WORKER_NAMES[@]}"; do
# #     HOST="${WORKER_NAMES[$i]}"
# #     IP="${WORKER_IPS[$i]}"
# #     echo "$IP ${HOST}.kubernetes.local ${HOST}"
# #   done
# # } > "$HOSTS_FILE"

# # # 🧠 De-duplicate and merge /etc/hosts safely
# # scp -i "$JUMPBOX_KEY" "$HOSTS_FILE" "$JUMPBOX_USER@$JUMPBOX_IP:/tmp/hosts_additions"
# # ssh -i "$JUMPBOX_KEY" "$JUMPBOX_USER@$JUMPBOX_IP" <<'EOF'
# #   sudo bash -c '
# #     TMP_FILE="/tmp/hosts_additions"
# #     FINAL_FILE="/etc/hosts"
# #     # Backup current hosts
# #     cp "$FINAL_FILE" "$FINAL_FILE.bak"
# #     # Extract existing static system lines
# #     grep -E "^(127\.0\.0\.1|::1|ff02::1|ff02::2)" "$FINAL_FILE.bak" > "$FINAL_FILE"
# #     echo "" >> "$FINAL_FILE"
# #     echo "# === Kubernetes Cluster Nodes ===" >> "$FINAL_FILE"
# #     # Append unique lines
# #     grep -vE "^(127\.0\.0\.1|::1|ff02::1|ff02::2)" "$TMP_FILE" | while read -r LINE; do
# #       IP=$(echo "$LINE" | awk "{print \$1}")
# #       HOSTNAME=$(echo "$LINE" | awk "{print \$2}")
# #       if ! grep -q "$HOSTNAME" "$FINAL_FILE"; then
# #         echo "$LINE" >> "$FINAL_FILE"
# #       fi
# #     done
# #     chmod 644 "$FINAL_FILE"
# #   '
# # EOF

# # rm "$HOSTS_FILE"


# # ==============================
# # 📝 Build consistent /etc/hosts file
# # ==============================

# echo "📚 Building unified /etc/hosts file..."

# HOSTS_FILE=$(mktemp)

# {
#   echo "127.0.0.1       localhost"
#   echo "::1             localhost ip6-localhost ip6-loopback"
#   echo "ff02::1         ip6-allnodes"
#   echo "ff02::2         ip6-allrouters"
#   echo ""
#   echo "# === Kubernetes Cluster Nodes ==="
#   # proxy server
#   echo "${JUMPBOX_PRIVATE_IP} api.k8s.local api"
  
#   echo "##### Control Plane Nodes #####"
#   for i in "${!CONTROL_NAMES[@]}"; do
#     NAME="${CONTROL_NAMES[$i]}"
#     IP="${CONTROL_IPS[$i]}"
#     echo "$IP ${NAME}.k8s.local ${NAME}"
#   done
#   echo ""
#   echo "##### Worker Nodes #####"
#   for i in "${!WORKER_NAMES[@]}"; do
#     NAME="${WORKER_NAMES[$i]}"
#     IP="${WORKER_IPS[$i]}"
#     echo "$IP ${NAME}.k8s.local ${NAME}"
#   done
# } > "$HOSTS_FILE"

# echo "📤 Uploading hosts file to jumpbox..."
# scp -i "$JUMPBOX_KEY" "$HOSTS_FILE" "$JUMPBOX_USER@$JUMPBOX_IP:/tmp/hosts.new"

# # ==============================
# # 🛠️ Update /etc/hosts on jumpbox
# # ==============================
# echo "🛠️  Updating /etc/hosts on jumpbox..."
# ssh -i "$JUMPBOX_KEY" "$JUMPBOX_USER@$JUMPBOX_IP" <<'EOF'
#   sudo cp /etc/hosts /etc/hosts.bak
#   sudo mv /tmp/hosts.new /etc/hosts
#   sudo chmod 644 /etc/hosts
# EOF

# # ==============================
# # 📡 Distribute /etc/hosts to all nodes via jumpbox (as root)
# # ==============================

# for i in "${!CONTROL_NAMES[@]}"; do
#   NAME="${CONTROL_NAMES[$i]}"
#   IP="${CONTROL_IPS[$i]}"
#   echo "🔁 Sending to control node: $NAME ($IP)"
#   ssh -i "$JUMPBOX_KEY" "$JUMPBOX_USER@$JUMPBOX_IP" <<EOF
#     sudo scp /etc/hosts $NAME:/tmp/hosts
#     sudo ssh $NAME 'sudo mv /tmp/hosts /etc/hosts && sudo chmod 644 /etc/hosts'
# EOF
# done

# for i in "${!WORKER_NAMES[@]}"; do
#   NAME="${WORKER_NAMES[$i]}"
#   IP="${WORKER_IPS[$i]}"
#   echo "🔁 Sending to worker node: $NAME ($IP)"
#   ssh -i "$JUMPBOX_KEY" "$JUMPBOX_USER@$JUMPBOX_IP" <<EOF
#     sudo scp  /etc/hosts $NAME:/tmp/hosts
#     sudo ssh -i /root/.ssh/workernode-key $NAME 'sudo mv /tmp/hosts /etc/hosts && sudo chmod 644 /etc/hosts'
# EOF
# done
