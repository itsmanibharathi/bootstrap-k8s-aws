# PKI Generate Role

This role generates all required PKI certificates for a Kubernetes cluster following security best practices.

## Generated Certificates

### Root CA
- `/etc/kubernetes/pki/ca.crt` - Root CA certificate
- `/etc/kubernetes/pki/ca.key` - Root CA private key

### etcd CA (Separate)
- `/etc/kubernetes/pki/etcd/ca.crt` - etcd CA certificate
- `/etc/kubernetes/pki/etcd/ca.key` - etcd CA private key

### API Server
- `/etc/kubernetes/pki/apiserver.crt` - API server serving certificate
- `/etc/kubernetes/pki/apiserver.key` - API server private key
- `/etc/kubernetes/pki/apiserver-kubelet-client.crt` - API server to kubelet client cert
- `/etc/kubernetes/pki/apiserver-kubelet-client.key` - API server to kubelet client key

### etcd Certificates
- `/etc/kubernetes/pki/etcd/server.crt` - etcd server certificate (per node)
- `/etc/kubernetes/pki/etcd/server.key` - etcd server private key (per node)
- `/etc/kubernetes/pki/etcd/peer.crt` - etcd peer certificate (per node)
- `/etc/kubernetes/pki/etcd/peer.key` - etcd peer private key (per node)
- `/etc/kubernetes/pki/etcd/apiserver-etcd-client.crt` - API server to etcd client cert
- `/etc/kubernetes/pki/etcd/apiserver-etcd-client.key` - API server to etcd client key
- `/etc/kubernetes/pki/etcd/healthcheck-client.crt` - etcd healthcheck client cert
- `/etc/kubernetes/pki/etcd/healthcheck-client.key` - etcd healthcheck client key

### Front Proxy
- `/etc/kubernetes/pki/front-proxy-ca.crt` - Front proxy CA certificate
- `/etc/kubernetes/pki/front-proxy-ca.key` - Front proxy CA private key
- `/etc/kubernetes/pki/front-proxy-client.crt` - Front proxy client certificate
- `/etc/kubernetes/pki/front-proxy-client.key` - Front proxy client private key

### Service Account
- `/etc/kubernetes/pki/sa.key` - Service account signing key
- `/etc/kubernetes/pki/sa.pub` - Service account public key

## Features

- **Separate etcd CA**: Uses dedicated CA for etcd certificates for better security isolation
- **Proper file naming**: Converts CFSSL .pem output to Kubernetes standard .crt/.key naming
- **Secure permissions**: Sets 0644 for certificates, 0600 for private keys, root:root ownership
- **Error handling**: Validates certificate generation and fails on errors
- **Idempotent**: Uses `creates` parameter to avoid regenerating existing certificates
- **Cleanup**: Removes temporary .pem and .json files after processing

## Requirements

- CFSSL and cfssljson installed on jumpbox
- OpenSSL for service account key generation
- Proper inventory with control_plane group and private_ip variables

## Variables

- `k8s_pki_dir`: PKI directory (default: /etc/kubernetes/pki)
- `k8s_pki_etcd_dir`: etcd PKI directory (default: /etc/kubernetes/pki/etcd)
- `cluster_domain`: Cluster domain (default: cluster.local)
- `kubernetes_service_ip`: Kubernetes service IP (default: 10.96.0.1)

## Usage

```yaml
- name: Generate Kubernetes PKI
  hosts: jumpbox
  become: true
  roles:
    - pki_generate
```

## Security Best Practices

- Uses 4096-bit RSA keys for all certificates
- Separate CA for etcd isolation
- Proper certificate profiles (server, client, peer)
- Secure file permissions and ownership
- Comprehensive SAN lists for API server certificates
- Validates certificate generation success