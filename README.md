# DevOps Lab

**Production-ready Kubernetes environment with GitOps, CI/CD, and observability**

[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=flat&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![ArgoCD](https://img.shields.io/badge/ArgoCD-EF7B4D?style=flat&logo=argo&logoColor=white)](https://argo-cd.readthedocs.io/)
[![Helm](https://img.shields.io/badge/Helm-0F1689?style=flat&logo=helm&logoColor=white)](https://helm.sh/)
[![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=flat&logo=prometheus&logoColor=white)](https://prometheus.io/)

---

## Overview

Enterprise-grade Kubernetes environment demonstrating GitOps continuous delivery, infrastructure as code, and observability.

**Tech Stack:** Kubernetes • ArgoCD • Helm • Jenkins • Prometheus • Grafana • Node.js

### Architecture

```
GitHub (Source of Truth)
    ↓
ArgoCD (GitOps Engine)
    ↓
Kubernetes Cluster
├── Node App (3 replicas)
├── Prometheus (Monitoring)
├── Grafana (Dashboards)
└── Nginx Ingress Controller
```

---

## Quick Start

### Prerequisites

- Kubernetes cluster (Minikube/K3s)
- kubectl configured
- Helm 3
- Docker

### Deploy

```bash
# Clone repository
git clone https://github.com/voynovscloud/devops-lab.git
cd devops-lab

# Deploy infrastructure
./deploy-k8s.sh

# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Configure ArgoCD for HTTP access
kubectl patch configmap argocd-cmd-params-cm -n argocd --type merge -p '{"data":{"server.insecure":"true"}}'
kubectl rollout restart deployment argocd-server -n argocd
kubectl apply -f k8s/argocd-ingress.yaml

# Setup Ingress
sudo bash -c "cat >> /etc/hosts << EOF
$(minikube ip) app.local
$(minikube ip) grafana.local
$(minikube ip) prometheus.local
$(minikube ip) argocd.local
EOF"

# Deploy application via GitOps
kubectl apply -f argocd/application.yaml
```

---

## Access Services

| Service | URL | Credentials |
|---------|-----|-------------|
| **Node App** | http://app.local | - |
| **ArgoCD** | http://argocd.local | admin / (see below) |
| **Grafana** | http://grafana.local | admin / admin |
| **Prometheus** | http://prometheus.local | - |
| **Jenkins** | http://localhost:8081 | (Docker) |

```bash
# Get ArgoCD password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Get Jenkins password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

---

## GitOps Workflow

Changes pushed to Git are automatically deployed to Kubernetes via ArgoCD:

```bash
# Edit Helm values
vim devops-lab-chart/values.yaml

# Commit and push
git add devops-lab-chart/values.yaml
git commit -m "Update configuration"
git push origin main

# ArgoCD syncs automatically within 3 minutes
```

---

## Helm Deployment

```bash
# Install
helm install devops-lab ./devops-lab-chart

# Upgrade
helm upgrade devops-lab ./devops-lab-chart --set replicaCount=5

# Rollback
helm rollback devops-lab
```

---

## CI/CD Pipeline

Jenkins pipeline with automated stages:

1. **Checkout** - Clone from Git
2. **Build** - Build Docker image
3. **Test** - Health checks and unit tests
4. **Security Scan** - Trivy vulnerability scanning
5. **Deploy** - Deploy to Kubernetes

```bash
# Start Jenkins
./run-jenkins.sh
```

---

## Monitoring

- **Prometheus**: Metrics collection with auto-discovery (http://prometheus.local)
- **Grafana**: Dashboard visualization with pre-configured datasource (http://grafana.local)

---

## Project Structure

```
devops-lab/
├── my-node-app/           # Node.js Express application
├── devops-lab-chart/      # Helm chart for GitOps deployment
├── argocd/                # ArgoCD configuration
├── k8s/                   # Kubernetes manifests
├── Jenkinsfile            # CI/CD pipeline definition
├── deploy-k8s.sh          # Deployment automation
└── run-jenkins.sh         # Jenkins setup script
```

---

## Key Features

- **GitOps Automation** - Continuous delivery from Git
- **Self-Healing** - ArgoCD maintains desired state
- **Helm Packaging** - Parameterized Kubernetes deployments
- **CI/CD Pipeline** - Automated build, test, and security scanning
- **Monitoring Stack** - Prometheus and Grafana integration
- **Horizontal Autoscaling** - HPA with CPU/memory targets
- **Security Scanning** - Trivy vulnerability detection
- **High Availability** - Multi-replica deployments

---

## Useful Commands

```bash
# Check status
./check-status.sh
kubectl get pods -A
kubectl get applications -n argocd

# View logs
kubectl logs -f deployment/node-app -n devops-lab
kubectl logs -f -n argocd -l app.kubernetes.io/name=argocd-server

# Scale application
kubectl scale deployment/node-app -n devops-lab --replicas=5
helm upgrade devops-lab ./devops-lab-chart --set replicaCount=5

# Rebuild node app
./fix-nodeapp.sh
```

---

## License

MIT License - see [LICENSE](LICENSE) file

---

**Repository:** https://github.com/voynovscloud/devops-lab
