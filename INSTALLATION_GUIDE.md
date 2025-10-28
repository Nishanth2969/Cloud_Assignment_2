# Installation Guide for Prerequisites

This guide covers installing all necessary tools for the assignment.

## Already Installed

You already have:
- Docker Desktop (version 28.0.4)
- Docker Compose (version 2.37.1)

## Tools to Install

### 1. Minikube

Minikube runs a local Kubernetes cluster on your machine.

**macOS (using Homebrew):**
```bash
brew install minikube
```

**macOS (direct download):**
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64
sudo install minikube-darwin-amd64 /usr/local/bin/minikube
```

**Verify installation:**
```bash
minikube version
```

### 2. kubectl

kubectl is the Kubernetes command-line tool.

**macOS (using Homebrew):**
```bash
brew install kubectl
```

**macOS (direct download):**
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/kubectl
```

**Verify installation:**
```bash
kubectl version --client
```

## Post-Installation Setup

### 1. Start Minikube for the First Time

```bash
# Start with Docker driver
minikube start --driver=docker

# This will:
# - Download the Minikube ISO
# - Create a VM/container
# - Configure kubectl to use Minikube
```

### 2. Verify Everything is Working

```bash
# Check Minikube status
minikube status

# Check kubectl can connect
kubectl cluster-info

# Check nodes
kubectl get nodes
```

Expected output for `minikube status`:
```
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

### 3. Enable Useful Minikube Addons (Optional)

```bash
# Enable metrics server (for kubectl top)
minikube addons enable metrics-server

# Enable dashboard
minikube addons enable dashboard

# List all addons
minikube addons list
```

## Docker Hub Account

You need a Docker Hub account to push images.

1. Go to https://hub.docker.com
2. Sign up for a free account
3. Verify your email
4. Note your username (you'll need it for pushing images)

## Verification Commands

Run these to ensure everything is ready:

```bash
# Docker
docker --version
docker ps

# Docker Compose
docker-compose --version

# Minikube
minikube version
minikube status

# kubectl
kubectl version --client
kubectl cluster-info
```

## Common Installation Issues

### Issue: Minikube won't start

**Error:** "Exiting due to DRV_NOT_HEALTHY"

**Solution:**
```bash
# Make sure Docker Desktop is running
# Then try:
minikube delete
minikube start --driver=docker
```

### Issue: kubectl command not found

**Solution:**
```bash
# Add to PATH (add to ~/.zshrc or ~/.bash_profile)
export PATH="/usr/local/bin:$PATH"

# Reload shell
source ~/.zshrc
```

### Issue: Permission denied for Minikube

**Solution:**
```bash
# Make sure user is in docker group
sudo usermod -aG docker $USER

# Log out and back in, or run:
newgrp docker
```

### Issue: Minikube uses too much memory

**Solution:**
```bash
# Start with less memory
minikube start --memory=4096 --cpus=2

# Or delete and recreate
minikube delete
minikube start --driver=docker --memory=4096
```

## Resource Requirements

Minimum requirements:
- 2 CPU cores
- 4GB RAM
- 20GB free disk space
- Internet connection (for downloading images)

Recommended:
- 4 CPU cores
- 8GB RAM
- 40GB free disk space

## Useful Resources

- Docker Documentation: https://docs.docker.com
- Minikube Documentation: https://minikube.sigs.k8s.io/docs/
- kubectl Documentation: https://kubernetes.io/docs/reference/kubectl/
- Docker Hub: https://hub.docker.com

## Next Steps

Once everything is installed:
1. Read `STEP_BY_STEP.md` for execution instructions
2. Follow `README.md` for quick start
3. Use `COMMANDS.txt` for command reference
4. Refer to `DEMO_SCRIPT.md` for live demo preparation

