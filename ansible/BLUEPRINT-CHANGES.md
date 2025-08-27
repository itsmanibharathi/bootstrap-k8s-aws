# Blueprint Implementation: Clean Role Separation

This implementation follows the opinionated blueprint that cleanly splits worker node setup into two focused Ansible roles:

## Role 1: `kubelet`
**Purpose**: Installs/configures kubelet + containerd bits and drops a stable kubelet config.

**What it does**:
- Installs containerd, kubelet, kubectl, kubeadm via apt
- Enables and starts containerd service
- Creates kubelet configuration file with proper security settings
- Creates kubelet systemd service unit
- Enables kubelet service (but doesn't start it)

**What it doesn't do**:
- Start kubelet (left for node_join role)
- Handle TLS bootstrap
- Manage CA certificates

## Role 2: `node_join`
**Purpose**: Wires TLS bootstrap (bootstrap kubeconfig), ensures CA is present, and starts/enables kubelet so the node auto-registers.

**What it does**:
- Creates necessary directories
- Places cluster root CA certificate
- Renders bootstrap kubeconfig with bootstrap token
- Starts kubelet service to begin auto-registration

**What it doesn't do**:
- Install software packages
- Configure kubelet settings
- Handle complex token management

## Key Changes from Original

1. **Clean Separation**: Each role has a single, focused responsibility
2. **Simplified Configuration**: Removed complex token generation and RBAC setup from node_join
3. **Modern Paths**: Uses `/var/lib/kubernetes` and `/var/lib/kubelet` as per blueprint
4. **Package Management**: Uses apt to install kubelet instead of manual downloads
5. **Security First**: Proper file permissions and security settings

## Prerequisites

1. **Apply RBAC once on control plane**:
   ```bash
   kubectl apply -f kubelet-bootstrap-rbac.yaml
   ```

2. **Provide CA certificate**: Place your cluster's CA certificate in `roles/node_join/files/ca.crt`

3. **Generate bootstrap token**: Create a valid bootstrap token in format `<id>.<secret>`

## Usage

See `playbooks/worker-setup-example.yml` for usage example.

## Ops Tips

- **Before scaling**: Apply RBAC and verify API server is reachable
- **First node test**: Run on single worker, check `kubectl get csr` and `kubectl get nodes`
- **Token rotation**: Update `kubelet_bootstrap_token` variable as needed
- **Labels/taints**: Set via `kubelet_extra_flags` for deterministic scheduling