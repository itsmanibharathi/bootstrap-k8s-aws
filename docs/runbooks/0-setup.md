# 0-setup 
> Repo: `git@github.com:itsmanibharathi/bootstrap-k8s-aws.git`
> Root dir: `k8s-baremetal-private-aws/`

---

## 1) Prerequisites (local)

Install the following on your workstation:

* **Git**
* **Python 3.10+** (with `pip`)
* **OpenSSH client** (`ssh`, `scp`)
* **Terraform** (v1.5+ recommended)
* **AWS account** with credentials configured locally
* **Docker** (optional but recommended for Ansible EE)
* **Ansible Navigator** (uses execution environment `quay.io/ansible/creator-ee:latest`)

### Quick install hints

* macOS (Homebrew):

  ```bash
  brew install git python terraform awscli
  # Docker Desktop from docker.com if needed
  ```

* Ubuntu/Debian:

  ```bash
  sudo apt update
  sudo apt install -y git python3 python3-pip openssh-client unzip
  # Terraform: https://developer.hashicorp.com/terraform/install
  # AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
  ```

* Ansible Navigator:

  ```bash
  pip install ansible-navigator
  # Verify
  ansible-navigator --version
  ```

* AWS credentials:

  ```bash
  aws configure
  # Provide AWS Access Key ID, Secret Access Key, default region, output format
  ```

---

## 2) Clone the repository

```bash
git clone git@github.com:itsmanibharathi/bootstrap-k8s-aws.git
cd bootstrap-k8s-aws/k8s-baremetal-private-aws
```

---

## 3) Bootstrap local project environment

Copy the environment example and update as needed:

```bash
cp .env.example .env
# Edit .env: set AWS region, profile, cluster name/prefix, etc.
```

Optional helpful exports for this shell session:

```bash
export AWS_PROFILE=<your-profile>
export AWS_REGION=<your-region>   # e.g., ap-south-1
```

---

## 4) Generate SSH keys (jump host, control node, worker node)

Create keys under the `ssh/` folder. **Do not commit private keys.**

```bash

mkdir -p ssh
chmod 700 ssh

# Jump host key
ssh-keygen -t ed25519 -C "jumpbox" -f ssh/jumpbox-key -N ""

# Control plane node key
ssh-keygen -t ed25519 -C "controlplane" -f ssh/controlplane-key -N ""

# Worker node key
ssh-keygen -t ed25519 -C "workernode" -f ssh/workernode-key -N ""
```

Ensure correct permissions:

```bash
chmod 600 ssh/*-key
```

