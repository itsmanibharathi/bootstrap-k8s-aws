# node_join

Bootstraps Kubernetes worker nodes using kubelet TLS bootstrap with auto-approval + certificate rotation. Uses a jumpbox with `kubectl` to create the bootstrap token, RBAC, and to verify node registration.

## Variables
- `node_join_jumpbox_host` (default: `jumpbox`)
- `node_join_api_server_url` (required: e.g. `https://api.k8s.com:6443`)
- `node_join_ca_cert_path` (default: `/etc/kubernetes/pki/ca.crt`)
- `node_join_bootstrap_token` (optional; provide to reuse a token)
- `node_join_enable_rbac` (default: `true`)
- `node_join_wait_retries` (default: `30`)
- `node_join_wait_delay` (default: `10`)

## Requirements
- Jumpbox has `kubectl` configured to the target cluster (cluster-admin).
- Workers have kubelet + container runtime installed.
- Workers can reach API server on TCP 6443; time synced (NTP).

## Example
