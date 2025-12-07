# DevOps Lab

> Production-grade cloud-native platform with Kubernetes, GitOps, and Infrastructure as Code

[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=flat&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![ArgoCD](https://img.shields.io/badge/ArgoCD-EF7B4D?style=flat&logo=argo&logoColor=white)](https://argo-cd.readthedocs.io/)
[![Helm](https://img.shields.io/badge/Helm-0F1689?style=flat&logo=helm&logoColor=white)](https://helm.sh/)
[![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=flat&logo=prometheus&logoColor=white)](https://prometheus.io/)
[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=flat&logo=terraform&logoColor=white)](https://terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-FF9900?style=flat&logo=amazonaws&logoColor=white)](https://aws.amazon.com/)

---

## Overview

Full-stack DevOps platform demonstrating modern cloud-native deployment practices. Features automated CI/CD, GitOps workflows, Infrastructure as Code, and comprehensive observability.

**Stack**: Node.js + PostgreSQL | Docker | Kubernetes + Helm | ArgoCD | Terraform | Prometheus + Grafana

**Infrastructure**: AWS (VPC, EKS, RDS) with multi-AZ deployment, private subnets, and auto-scaling capabilities.

## Architecture

```
GitHub (Source) → CI/CD Pipeline → Container Registry
                       ↓
                   ArgoCD (GitOps)
                       ↓
    ┌──────────────────────────────────────┐
    │         Kubernetes Cluster           │
    │  ┌────────┐  ┌────────┐  ┌────────┐ │
    │  │Node.js │  │PostgreS│  │Prometh │ │
    │  │App x3  │←→│QL (RDS)│  │eus     │ │
    │  │Auto-   │  │        │  │Grafana │ │
    │  │scaling │  │        │  │        │ │
    │  └────────┘  └────────┘  └────────┘ │
    └──────────────────────────────────────┘
```

## Features

- **GitOps Workflow**: ArgoCD automatically syncs Kubernetes cluster with Git repository
- **Auto-Scaling**: HPA scales pods (2-10) based on CPU (60%) and memory (70%) thresholds
- **CI/CD Automation**: GitHub Actions builds, tests, pushes Docker images, auto-updates Helm charts
- **Infrastructure as Code**: Terraform provisions AWS VPC, EKS cluster, RDS PostgreSQL
- **Observability**: Prometheus metrics collection with Grafana dashboards
- **High Availability**: Multi-replica deployments across availability zones
- **Security**: Private subnets, non-root containers, resource limits

## Quick Start

### Local Development

```bash
# Prerequisites: Docker, Minikube, kubectl, Helm
minikube start --cpus=4 --memory=8192 --disk-size=20g
minikube addons enable ingress metrics-server

./deploy-k8s.sh

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f argocd/application.yaml

echo "$(minikube ip) app.local argocd.local grafana.local prometheus.local" | sudo tee -a /etc/hosts
```

### AWS Deployment

```bash
cd terraform && terraform init
export TF_VAR_db_password="SecurePassword123!"
terraform apply

aws eks update-kubeconfig --region eu-central-1 --name devops-lab
helm install devops-lab ./devops-lab-chart
```

### Access

| Service | URL | Credentials |
|---------|-----|-------------|
| Application | http://app.local | - |
| ArgoCD | http://argocd.local | admin / `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" \| base64 -d` |
| Grafana | http://grafana.local | admin / admin |
| Prometheus | http://prometheus.local | - |

## Project Structure

```
devops-lab/
├── .github/workflows/     # CI/CD automation
├── my-node-app/           # Node.js application
├── devops-lab-chart/      # Helm chart
├── argocd/                # GitOps configuration
├── terraform/             # AWS infrastructure
├── k8s/                   # Kubernetes manifests
└── deploy-k8s.sh          # Deployment script
```

## Commands

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
