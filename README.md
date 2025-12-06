# DevOps Lab

**Production-ready Kubernetes environment with GitOps, CI/CD, and observability**

![CI Status](https://img.shields.io/badge/CI-passing-brightgreen?style=flat&logo=jenkins)
![Helm Lint](https://img.shields.io/badge/Helm-lint%20passing-0F1689?style=flat&logo=helm)
![Docker Build](https://img.shields.io/badge/Docker-build%20passing-2496ED?style=flat&logo=docker&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Kubernetes](https://img.shields.io/badge/Kubernetes-1.28+-326CE5?style=flat&logo=kubernetes&logoColor=white)

[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=flat&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![ArgoCD](https://img.shields.io/badge/ArgoCD-EF7B4D?style=flat&logo=argo&logoColor=white)](https://argo-cd.readthedocs.io/)
[![Helm](https://img.shields.io/badge/Helm-0F1689?style=flat&logo=helm&logoColor=white)](https://helm.sh/)
[![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=flat&logo=prometheus&logoColor=white)](https://prometheus.io/)
[![Grafana](https://img.shields.io/badge/Grafana-F46800?style=flat&logo=grafana&logoColor=white)](https://grafana.com/)
[![Jenkins](https://img.shields.io/badge/Jenkins-D24939?style=flat&logo=jenkins&logoColor=white)](https://www.jenkins.io/)

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

## Quick Commands

| Action | Command | Description |
|--------|---------|-------------|
| **Deploy** | `./deploy-k8s.sh` | Deploy all infrastructure |
| **Deploy GitOps** | `kubectl apply -f argocd/application.yaml` | Deploy via ArgoCD |
| **Check Status** | `./check-status.sh` | Check all pods and services |
| **View Logs** | `kubectl logs -f deployment/node-app -n devops-lab` | Stream application logs |
| **Scale Up** | `kubectl scale deployment/node-app -n devops-lab --replicas=5` | Scale to 5 replicas |
| **Scale (Helm)** | `helm upgrade devops-lab ./devops-lab-chart --set replicaCount=5` | Scale via Helm |
| **Rollback** | `helm rollback devops-lab` | Rollback to previous version |
| **Rebuild App** | `./fix-nodeapp.sh` | Rebuild and redeploy node app |
| **ArgoCD Sync** | `kubectl patch app devops-lab-app -n argocd -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{}}}' --type merge` | Force ArgoCD sync |
| **Get Pods** | `kubectl get pods -A` | List all pods |
| **Get Apps** | `kubectl get applications -n argocd` | List ArgoCD applications |

---

## License

MIT License - see [LICENSE](LICENSE) file

---

**Repository:** https://github.com/voynovscloud/devops-lab
