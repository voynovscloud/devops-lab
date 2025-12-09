# Production-Grade DevOps Platform

> End-to-end cloud-native infrastructure demonstrating enterprise Kubernetes deployment with GitOps, IaC, and automated CI/CD pipelines

<div align="center">

[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://docker.com/)
[![Helm](https://img.shields.io/badge/Helm-0F1689?style=for-the-badge&logo=helm&logoColor=white)](https://helm.sh/)
[![ArgoCD](https://img.shields.io/badge/ArgoCD-EF7B4D?style=for-the-badge&logo=argo&logoColor=white)](https://argo-cd.readthedocs.io/)
[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-FF9900?style=for-the-badge&logo=amazonaws&logoColor=white)](https://aws.amazon.com/)
[![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)](https://github.com/features/actions)
[![Jenkins](https://img.shields.io/badge/Jenkins-D24939?style=for-the-badge&logo=jenkins&logoColor=white)](https://jenkins.io/)
[![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=prometheus&logoColor=white)](https://prometheus.io/)
[![Grafana](https://img.shields.io/badge/Grafana-F46800?style=for-the-badge&logo=grafana&logoColor=white)](https://grafana.com/)
[![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)](https://nodejs.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)](https://postgresql.org/)

</div>

## Overview

Production-ready Kubernetes platform demonstrating modern DevOps practices with complete automation from code commit to production deployment.

**Key Capabilities:**
- Containerized microservices with Node.js and PostgreSQL
- AWS EKS cluster management with Terraform IaC
- GitOps-driven deployments via ArgoCD
- Dual CI/CD pipelines (GitHub Actions for production, Jenkins for local development)
- Full observability stack with Prometheus and Grafana
- Horizontal Pod Autoscaling based on resource metrics
- Enterprise security with RBAC, Secrets management, and non-root containers

## Architecture

```
┌──────────────────────────────────────────────────────────┐
│  Git Repository (Source of Truth)                       │
└────┬─────────────────────────────────┬─────────────────┘
     │                                 │
     ▼                                 ▼
┌─────────────────┐          ┌──────────────────┐
│ GitHub Actions  │          │ Jenkins Pipeline │
│ (Production)    │          │ (Local Dev)      │
└────┬────────────┘          └──────────────────┘
     │
     ▼
┌─────────────────────────────────────────────────────────┐
│  ArgoCD (GitOps Controller)                             │
│  • Auto-sync: 3min interval  • Self-healing enabled     │
└────┬────────────────────────────────────────────────────┘
     │
     ▼
┌─────────────────────────────────────────────────────────┐
│  AWS EKS Cluster (Kubernetes 1.28)                      │
│  ┌──────────────┐  ┌────────────┐  ┌────────────┐      │
│  │ Application  │  │ Prometheus │  │ Grafana    │      │
│  │ HPA: 2-10    │  │ Metrics    │  │ Dashboards │      │
│  └──────────────┘  └────────────┘  └────────────┘      │
│  ┌──────────────────────────────────────────────┐      │
│  │ RDS PostgreSQL (Multi-AZ)                    │      │
│  └──────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────┘
     │
┌────▼─────────────────────────────────────────────────────┐
│  Terraform (IaC)                                         │
│  VPC • Subnets • EKS • RDS • Security Groups • IAM      │
└──────────────────────────────────────────────────────────┘
```

## Quick Start

### Prerequisites

- Docker 20.10+
- kubectl 1.28+
- Helm 3.12+
- Terraform 1.5+
- AWS CLI configured with valid credentials

### Local Development (Minikube)

```bash
# Initialize cluster
minikube start --cpus=4 --memory=8192 --driver=docker
minikube addons enable ingress

# Deploy application
kubectl create namespace production
helm install my-node-app ./devops-lab-chart --namespace production

# Deploy observability stack
kubectl create namespace monitoring
kubectl apply -f k8s/prometheus/
kubectl apply -f k8s/grafana/

# Deploy ArgoCD (optional)
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Configure ingress
kubectl apply -f k8s/ingress-all.yaml
kubectl apply -f k8s/argocd-ingress.yaml
echo "$(minikube ip) app.local grafana.local prometheus.local argocd.local" | sudo tee -a /etc/hosts
```

**Access URLs:**
- Application: `http://app.local`
- Grafana: `http://grafana.local` (admin/admin)
- Prometheus: `http://prometheus.local`
- ArgoCD: `http://argocd.local`

### AWS Production Deployment

```bash
# Configure credentials and secrets
aws configure
export TF_VAR_db_password="<secure-password>"

# Provision infrastructure (~15 minutes)
cd terraform/
terraform init
terraform apply -var-file="terraform-free-tier.tfvars"

# Configure kubectl
aws eks update-kubeconfig --region eu-central-1 --name devops-lab

# Deploy observability stack
kubectl create namespace monitoring
kubectl apply -f k8s/prometheus/
kubectl apply -f k8s/grafana/

# Deploy application with database
RDS_HOST=$(cd terraform && terraform output -raw rds_endpoint)
helm install my-node-app ./devops-lab-chart \
  --namespace production --create-namespace \
  --set database.enabled=true \
  --set database.host=$RDS_HOST \
  --set database.password=$TF_VAR_db_password

# Configure ingress
kubectl apply -f k8s/ingress-all.yaml
kubectl apply -f k8s/argocd-ingress.yaml

# Verify deployment
kubectl get all -n production
kubectl get hpa -n production
kubectl get ingress -A
```

> **Cost Warning:** AWS EKS costs ~€105-110/month (€75 control plane + €30 NAT Gateway). Recommended for short-term portfolio deployments (2-3 days ≈ €7-10).

## Project Structure

```
devops-lab/
├── my-node-app/                  # Node.js application with PostgreSQL
├── devops-lab-chart/             # Helm chart (100+ configurable parameters)
├── terraform/                    # AWS infrastructure (VPC, EKS, RDS)
├── k8s/                          # Kubernetes manifests
│   ├── prometheus/               # Metrics collection
│   ├── grafana/                  # Visualization dashboards
│   └── ingress-all.yaml          # Ingress routing
├── argocd/                       # GitOps configuration
├── .github/workflows/            # GitHub Actions pipelines
├── docs/                         # Documentation
└── Jenkinsfile                   # Jenkins pipeline
```

## CI/CD Pipelines

### GitHub Actions (Production)

**Automated Workflows:**
- **Build & Test:** Validates code quality on every push
- **Docker Build & Push:** Builds multi-stage image and pushes to `ghcr.io`
- **Helm Version Bump:** Auto-increments chart version, triggering ArgoCD deployment

### Jenkins (Local Development)

**Pipeline Stages:** Checkout → Build → Test → Security Scan (Trivy) → Deploy to Minikube

```bash
docker run -d -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --name jenkins jenkins/jenkins:lts
```

### GitOps with ArgoCD

- Auto-sync interval: 3 minutes
- Self-healing: Automatically reverts manual cluster changes
- Git as source of truth for all cluster state
- Automatic pruning of deleted resources

## Monitoring & Observability

### Prometheus
- Scrape interval: 30s | Retention: 15 days | Storage: 10Gi PVC
- Service discovery via Kubernetes annotations

### Grafana
- Pre-configured Prometheus datasource
- Custom dashboard with 12 application metrics panels
- Default credentials: `admin` / `admin`

### Application Metrics

Exposed at `/metrics` endpoint:
- `http_requests_total` — Request counter per route
- `http_request_duration_seconds` — Response latency histogram
- `nodejs_heap_size_used_bytes` — Memory consumption
- `nodejs_eventloop_lag_seconds` — Event loop performance

### Access

**Local (Minikube):**
```bash
echo "$(minikube ip) grafana.local prometheus.local" | sudo tee -a /etc/hosts
```
Access: `http://grafana.local` | `http://prometheus.local`

**AWS (Production):**
```bash
kubectl get ingress -n monitoring
```
Configure DNS A records or use LoadBalancer IP with Host headers.

## Key Features

### Horizontal Pod Autoscaling
- Min: 2 | Max: 10 replicas
- Targets: 60% CPU, 70% memory
- Scale-up threshold: 30s | Scale-down threshold: 5min

```bash
kubectl get hpa -n production -w
```

### High Availability
- Multi-replica deployment (3 replicas default)
- Multi-AZ distribution on AWS
- Rolling updates with zero downtime
- Liveness and readiness probes
- Pod anti-affinity rules for node distribution

### Security
- Non-root container execution
- Kubernetes Secrets for sensitive data
- RBAC authorization
- Network isolation via Security Groups
- Private subnet architecture for databases

## Testing

```bash
# Application health
curl http://app.local/health
curl http://app.local/db-test
curl http://app.local/metrics

# Kubernetes resources
kubectl get hpa -n production -w
kubectl get ingress -A
```

## Cleanup

**Local:**
```bash
helm uninstall my-node-app -n production
kubectl delete namespace production monitoring argocd
minikube delete
```

**AWS (Critical):**
```bash
helm uninstall my-node-app -n production
cd terraform && terraform destroy -var-file="terraform-free-tier.tfvars"

# Verify resource deletion
aws eks list-clusters --region eu-central-1
aws rds describe-db-instances --region eu-central-1
```

## Technical Skills Demonstrated

| Domain | Implementation |
|--------|----------------|
| **Containers** | Multi-stage Docker builds, Alpine-based images, non-root execution |
| **Orchestration** | Kubernetes (Deployments, Services, ConfigMaps, Secrets, Ingress, HPA) |
| **Package Management** | Helm charts with environment-specific value overrides |
| **GitOps** | ArgoCD with automated sync, self-healing, and pruning |
| **Infrastructure as Code** | Terraform modules for VPC, EKS, RDS provisioning |
| **CI/CD** | GitHub Actions workflows, Jenkins declarative pipelines |
| **Observability** | Prometheus metrics collection, Grafana visualization |
| **Networking** | VPC design, multi-AZ architecture, NAT gateways, security groups |
| **Security** | RBAC policies, Kubernetes Secrets, private subnets, least privilege IAM |
| **Cloud Platform** | AWS (EKS, RDS, VPC, IAM, CloudWatch) |
| **Databases** | PostgreSQL with connection pooling, RDS multi-AZ deployments |

## Documentation

- [Helm Chart Guide](devops-lab-chart/README.md)
- [Terraform Infrastructure](terraform/README.md)
- [ArgoCD Configuration](argocd/README.md)
- [Alerting Setup](docs/ALERTING.md)

## License

MIT License - see [LICENSE](LICENSE)

---

**Author:** Deyvid Voynov  
**GitHub:** [@voynovscloud](https://github.com/voynovscloud)
