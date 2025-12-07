# DevOps Lab

**Production-ready Kubernetes environment with GitOps, CI/CD, and observability**

![GitHub Actions](https://img.shields.io/badge/GitHub%20Actions-enabled-2088FF?style=flat&logo=githubactions&logoColor=white)
![CI Status](https://img.shields.io/badge/CI-passing-brightgreen?style=flat&logo=jenkins)
![Helm Lint](https://img.shields.io/badge/Helm-lint%20passing-0F1689?style=flat&logo=helm)
![Docker Build](https://img.shields.io/badge/Docker-build%20passing-2496ED?style=flat&logo=docker&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-validated-7B42BC?style=flat&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-ready-FF9900?style=flat&logo=amazonaws&logoColor=white)
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

### Local (Minikube)
- **Prometheus**: Metrics collection with auto-discovery (http://prometheus.local)
- **Grafana**: Dashboard visualization with pre-configured datasource (http://grafana.local)

### Production (EKS)

Install kube-prometheus-stack:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set nodeExporter.enabled=true \
  --set kubeStateMetrics.enabled=true \
  --set grafana.enabled=true

# Access Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```

See [k8s/prometheus/HELM_INSTALL.md](k8s/prometheus/HELM_INSTALL.md) for detailed configuration.

---

## Autoscaling

Horizontal Pod Autoscaler configured for automatic scaling:

- **Min Replicas**: 2
- **Max Replicas**: 10
- **CPU Target**: 60%
- **Memory Target**: 70%

```bash
# Apply HPA
kubectl apply -f k8s/node-app/hpa.yaml

# Check HPA status
kubectl get hpa -n devops-lab
```

---

## CI/CD with GitHub Actions

Automated workflows for continuous integration and deployment:

### Workflows

1. **build.yaml** - Build, test, and validate Docker images
2. **push.yaml** - Push images to GitHub Container Registry
3. **helm-update.yaml** - Auto-bump Helm chart versions

### Setup

Enable GitHub Actions in your repository. Workflows run automatically on push to main branch.

---

## AWS Deployment with Terraform

Deploy to production AWS infrastructure with EKS, VPC, and RDS.

### Infrastructure

- **VPC**: 2 public + 2 private subnets across AZs
- **EKS Cluster**: Kubernetes 1.28 with 2 node groups (t3.medium)
- **RDS PostgreSQL**: db.t3.micro with automated backups

### Deploy to AWS

```bash
cd terraform

# Initialize
terraform init

# Set database password
export TF_VAR_db_password="YourSecurePassword123!"

# Deploy infrastructure (~30 minutes)
terraform apply

# Configure kubectl
aws eks update-kubeconfig --region eu-central-1 --name devops-lab

# Deploy application with database
export RDS_ENDPOINT=$(terraform output -raw rds_endpoint)
export DB_NAME=$(terraform output -raw rds_database_name)

helm install devops-lab ../devops-lab-chart \
  --set database.enabled=true \
  --set database.host="${RDS_ENDPOINT%%:*}" \
  --set database.name="${DB_NAME}" \
  --set database.user="dbadmin" \
  --set database.password="${TF_VAR_db_password}"
```

**Cost**: ~$184-244/month  
**Deployment time**: ~30 minutes

See [terraform/README.md](terraform/README.md) for detailed instructions.

---

## Project Structure

```
devops-lab/
├── .github/workflows/     # GitHub Actions CI/CD
│   ├── build.yaml         # Build and test workflow
│   ├── push.yaml          # Docker image push workflow
│   └── helm-update.yaml   # Helm version bump workflow
├── my-node-app/           # Node.js Express application with PostgreSQL support
├── devops-lab-chart/      # Helm chart for GitOps deployment
├── argocd/                # ArgoCD configuration
│   ├── application.yaml   # Application manifest
│   └── project.yaml       # Project definition
├── terraform/             # AWS infrastructure as code (VPC, EKS, RDS)
├── k8s/                   # Kubernetes manifests
│   ├── node-app/          # App manifests + HPA + ServiceMonitor
│   └── prometheus/        # Monitoring stack installation guide
├── Jenkinsfile            # Jenkins CI/CD pipeline
├── deploy-k8s.sh          # Deployment automation
└── run-jenkins.sh         # Jenkins setup script
```

---

## Key Features

- **GitOps Automation** - Continuous delivery from Git with ArgoCD
- **GitHub Actions** - Automated CI/CD workflows
- **Self-Healing** - ArgoCD maintains desired state
- **Helm Packaging** - Parameterized Kubernetes deployments
- **Infrastructure as Code** - Terraform for AWS (VPC, EKS, RDS)
- **Monitoring Stack** - Prometheus and Grafana (kube-prometheus-stack)
- **Horizontal Autoscaling** - HPA with CPU/memory targets
- **Database Integration** - PostgreSQL support with connection pooling
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
