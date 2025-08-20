# Kubernetes Multi-Master Cluster Setup

This Ansible playbook collection sets up a production-ready Kubernetes multi-master cluster with:

- **3 Control Plane Nodes** (High Availability)
- **HAProxy Load Balancer** (on jumpbox)
- **Cilium CNI** with eBPF networking
- **Complete Security Stack** (RBAC, OPA, Network Policies)
- **Observability Stack** (Prometheus, Grafana, Loki, Jaeger)

## Architecture

```
[Users] → [Jumpbox: HAProxy] → [Control Plane 1,2,3] ← → [Worker Nodes]
              ↓                      ↓                        ↓
    [Load Balancer: 6443]      [ALL Components]         [Node Components]
    [PKI Certificates]         [API + Scheduler]        [kubelet]
                              [Controller + etcd]       [kube-proxy]
                              [kubelet + kube-proxy]    [containerd]
                              [containerd + cilium]     [cilium-agent]
```

## Network Configuration

- **AWS VPC**: `10.0.0.0/16` (your existing infrastructure)
- **Pod Network**: `172.16.0.0/16` (non-overlapping)
- **Service Network**: `192.168.0.0/16` (non-overlapping)
- **DNS Domain**: `k8s.local`

## Prerequisites

1. **Infrastructure**: Terraform-deployed AWS infrastructure
2. **SSH Access**: Configured SSH keys and jumpbox access
3. **Ansible Navigator**: Installed and configured
4. **Inventory**: Updated with correct hostnames

## Quick Start

### 1. Validate Connectivity
```bash
./validate-cluster.sh
```

### 2. Run Complete Setup
```bash
./run-cluster-setup.sh
```

### 3. Run Individual Phases
```bash
# Phase 1: PKI Setup
ansible-navigator run playbooks/01-pki-setup.yml -i inventory.ini

# Phase 2: HAProxy Setup
ansible-navigator run playbooks/02-haproxy-setup.yml -i inventory.ini

# Phase 3: Base Nodes
ansible-navigator run playbooks/03-base-nodes.yml -i inventory.ini

# Phase 4: Control Plane
ansible-navigator run playbooks/04-control-plane.yml -i inventory.ini

# Phase 5: Workers (if any)
ansible-navigator run playbooks/05-worker-join.yml -i inventory.ini

# Phase 6: Cilium CNI
ansible-navigator run playbooks/06-cilium-cni.yml -i inventory.ini

# Phase 7: Security
ansible-navigator run playbooks/07-security-setup.yml -i inventory.ini

# Phase 8: Observability
ansible-navigator run playbooks/08-observability.yml -i inventory.ini
```

## Post-Installation

### Access Cluster
```bash
# SSH to any control plane node
ssh -F ../ssh/config k8s-ha-cluster-cp-1

# Check cluster status
kubectl get nodes -o wide
kubectl get pods -A
```

### Access Services
- **Grafana**: `http://<any-node-ip>:30080` (admin/admin123)
- **HAProxy Stats**: `http://<jumpbox-ip>:8404/stats`

### Verify Installation
```bash
# Check all nodes are Ready
kubectl get nodes

# Check all system pods are Running
kubectl get pods -n kube-system

# Test Cilium connectivity
cilium connectivity test

# Check network policies
kubectl get networkpolicies -A
```

## Troubleshooting

### Common Issues

1. **Node Not Ready**: Check kubelet logs
   ```bash
   systemctl status kubelet
   journalctl -u kubelet -f
   ```

2. **Pod Network Issues**: Check Cilium
   ```bash
   kubectl get pods -n kube-system -l k8s-app=cilium
   cilium status
   ```

3. **API Server Access**: Check HAProxy
   ```bash
   systemctl status haproxy
   curl -k https://10.0.1.100:6443/healthz
   ```

### Logs and Artifacts
- **Ansible Logs**: `ansible-navigator.log`
- **Playbook Artifacts**: `artifacts/`
- **Join Commands**: `/tmp/join-commands.txt` (on first CP)

## Security Features

- **Zero-Trust Networking**: Default-deny network policies
- **RBAC**: Role-based access control
- **OPA Gatekeeper**: Policy enforcement
- **Sealed Secrets**: Encrypted secret management
- **Runtime Security**: Falco threat detection (optional)

## Customization

Edit `group_vars/all.yml` to customize:
- Kubernetes version
- Network CIDRs
- Security policies
- Component versions

## Support

For issues or questions:
1. Check logs in `ansible-navigator.log`
2. Verify connectivity with `./validate-cluster.sh`
3. Review individual playbook outputs in `artifacts/`