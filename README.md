# DevOps Lab - Production Kubernetes Platform

> Complete end-to-end DevOps pipeline featuring Kubernetes, GitOps, Infrastructure as Code, and CI/CD automation

<div align="center">

### Technologies Used

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

## 📋 Project Overview

This project demonstrates a **production-ready DevOps pipeline** with modern cloud-native practices, showcasing:

- ✅ **Containerized Application** - Node.js REST API with PostgreSQL
- ✅ **Kubernetes Orchestration** - EKS cluster with Helm package management
- ✅ **GitOps Deployment** - ArgoCD auto-sync and self-healing
- ✅ **Infrastructure as Code** - Terraform provisioning AWS resources
- ✅ **CI/CD Automation** - GitHub Actions + Jenkins pipelines
- ✅ **Monitoring & Observability** - Prometheus + Grafana stack
- ✅ **Auto-scaling** - HPA based on CPU/memory metrics
- ✅ **Production Security** - RBAC, Secrets, non-root containers

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   GitHub Repository                         │
│             (Single Source of Truth)                        │
└──────────────┬──────────────────────────┬───────────────────┘
               │                          │
    ┌──────────▼────────────┐  ┌─────────▼──────────┐
    │  GitHub Actions       │  │   Jenkins Pipeline  │
    │  • Test & Build       │  │   • Local Dev       │
    │  • Push to ghcr.io    │  │   • Minikube        │
    │  • Helm Version Bump  │  │   • Health Checks   │
    └──────────┬────────────┘  └────────────────────┘
               │
               ▼
    ┌─────────────────────────────────────────────────────┐
    │              ArgoCD (GitOps)                        │
    │     Auto-sync every 3min • Self-healing             │
    └──────────┬──────────────────────────────────────────┘
               │
               ▼
    ┌─────────────────────────────────────────────────────┐
    │          Kubernetes Cluster (AWS EKS)               │
    │  ┌─────────────────┐  ┌────────────┐  ┌──────────┐ │
    │  │  Node App       │  │ Prometheus │  │ Grafana  │ │
    │  │  (3 replicas)   │  │ (metrics)  │  │ (dashb.) │ │
    │  │  HPA: 2-10 pods │  └────────────┘  └──────────┘ │
    │  └─────────────────┘                                │
    │  ┌──────────────────────────────────────────────┐   │
    │  │   PostgreSQL RDS (Multi-AZ)                  │   │
    │  └──────────────────────────────────────────────┘   │
    └─────────────────────────────────────────────────────┘
               │
    ┌──────────▼─────────────────────────────────────────┐
    │     Terraform (Infrastructure as Code)             │
    │  • VPC (10.0.0.0/16, 2 AZs)                       │
    │  • EKS Cluster (Kubernetes 1.28)                  │
    │  • RDS PostgreSQL 15.7 (db.t3.micro)              │
    │  • NAT Gateway • Security Groups • IAM Roles      │
    └────────────────────────────────────────────────────┘
```

## 🚀 Quick Start

### Prerequisites

```bash
docker --version        # 20.10+
kubectl version        # 1.28+
helm version          # 3.12+
terraform --version   # 1.5+
aws configure         # AWS credentials
```

### Local Development (Minikube)

```bash
# 1. Start Minikube cluster
minikube start --cpus=4 --memory=8192 --driver=docker
minikube addons enable ingress

# 2. Deploy monitoring stack
kubectl create namespace monitoring
kubectl apply -f k8s/prometheus/
kubectl apply -f k8s/grafana/

# 3. Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Get ArgoCD password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# 4. Deploy application
helm install my-node-app ./devops-lab-chart \
  --namespace production \
  --create-namespace

# 5. Access application
kubectl port-forward -n production svc/my-node-app 3000:80

# Test endpoints
curl http://localhost:3000/health
curl http://localhost:3000/metrics
```

### AWS Production Deployment

```bash
# 1. Configure AWS and set DB password
aws configure
export TF_VAR_db_password="SecurePassword123!"

# 2. Deploy infrastructure (~15 minutes)
cd terraform/
terraform init
terraform apply -var-file="terraform-free-tier.tfvars"

# 3. Configure kubectl for EKS
aws eks update-kubeconfig --region eu-central-1 --name devops-lab-v2

# 4. Deploy monitoring
kubectl create namespace monitoring
kubectl apply -f k8s/prometheus/
kubectl apply -f k8s/grafana/

# 5. Deploy application with RDS
RDS_HOST=$(cd terraform && terraform output -raw rds_endpoint)
helm install my-node-app ./devops-lab-chart \
  --namespace production \
  --create-namespace \
  --set database.enabled=true \
  --set database.host=$RDS_HOST \
  --set database.password=$TF_VAR_db_password

# 6. Verify deployment
kubectl get all -n production
kubectl get hpa -n production
```

> **💰 AWS Cost:** ~€105-110/month (EKS €75 + NAT €30). Deploy for 2-3 days (~€7-10) for portfolio, then destroy.

## 📂 Project Structure

```
devops-lab/
├── my-node-app/              # Node.js Express application
│   ├── server.js             # REST API (/health, /metrics, /db-test)
│   ├── database.js           # PostgreSQL connection pool
│   ├── metrics.js            # Prometheus metrics (prom-client)
│   ├── Dockerfile            # Multi-stage Alpine build
│   └── package.json          # Dependencies
│
├── devops-lab-chart/         # Helm chart for Kubernetes
│   ├── Chart.yaml            # Chart metadata (v1.0.x)
│   ├── values.yaml           # Configuration (100+ parameters)
│   └── templates/            # Kubernetes manifests
│       ├── deployment.yaml   # 3 replicas, rolling updates
│       ├── service.yaml      # ClusterIP service
│       ├── hpa.yaml          # Auto-scaling (2-10 pods)
│       ├── ingress.yaml      # NGINX Ingress routing
│       ├── secret.yaml       # Database credentials
│       └── configmap.yaml    # Environment variables
│
├── terraform/                # AWS Infrastructure as Code
│   ├── main.tf               # Provider configuration
│   ├── vpc.tf                # VPC, subnets, NAT gateway
│   ├── eks.tf                # EKS cluster + node groups
│   ├── rds.tf                # PostgreSQL RDS instance
│   ├── variables.tf          # Input variables
│   ├── outputs.tf            # Output values
│   └── terraform-free-tier.tfvars  # Cost-optimized config
│
├── k8s/                      # Raw Kubernetes manifests
│   ├── prometheus/           # Metrics collection
│   ├── grafana/              # Visualization dashboards
│   ├── node-app/             # Application manifests
│   ├── ingress-all.yaml      # Combined ingress rules
│   └── argocd-ingress.yaml   # ArgoCD UI access
│
├── argocd/                   # GitOps configuration
│   ├── application.yaml      # ArgoCD app definition
│   └── project.yaml          # ArgoCD project
│
├── .github/workflows/        # CI/CD pipelines
│   ├── build.yaml            # Test on every push
│   ├── push.yaml             # Build & push Docker image
│   └── helm-update.yaml      # Auto-bump chart version
│
├── Jenkinsfile               # Jenkins pipeline (local dev)
└── scripts/
    ├── load-test.sh          # HPA testing script
    └── nuclear-cleanup.sh    # AWS cleanup utility
```

## 🔄 CI/CD Pipelines

### GitHub Actions (Production)

**Workflow 1: Build & Test** (`.github/workflows/build.yaml`)
- Triggers on every push
- Runs unit tests with npm
- Validates code quality

**Workflow 2: Docker Build & Push** (`.github/workflows/push.yaml`)
- Triggers on push to main
- Builds multi-stage Docker image
- Pushes to `ghcr.io/voynovscloud/devops-lab-nodeapp`

**Workflow 3: Helm Version Bump** (`.github/workflows/helm-update.yaml`)
- Auto-increments chart version
- Commits to Git → ArgoCD auto-deploys

### Jenkins (Local Development)

**Pipeline Stages** (`Jenkinsfile`):
1. **Checkout** - Clone repo & get commit SHA
2. **Build** - Create Docker image
3. **Test** - Health check validation
4. **Security Scan** - Trivy vulnerability scan
5. **Deploy to Minikube** - Local K8s deployment

```bash
# Run Jenkins in Docker
docker run -d -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --name jenkins jenkins/jenkins:lts
```

### GitOps with ArgoCD

- **Auto-sync:** Every 3 minutes
- **Self-healing:** Reverts manual changes automatically
- **Source of Truth:** Git repository
- **Prune:** Removes deleted resources

## 📊 Monitoring & Observability

### Prometheus (Metrics Collection)
- **Scrape interval:** 30 seconds
- **Retention:** 15 days
- **Storage:** 10Gi persistent volume
- **Auto-discovery:** Kubernetes pods with metrics annotations

### Grafana (Visualization)
- **Access:** Port-forward or Ingress
- **Credentials:** admin / admin (default)
- **Datasource:** Prometheus (pre-configured)
- **Dashboards:** Application monitoring (12 panels)

### Application Metrics
```
# Exposed at /metrics endpoint
http_requests_total                   # Request counter by route
http_request_duration_seconds         # Response time histogram
nodejs_heap_size_used_bytes          # Memory usage
nodejs_eventloop_lag_seconds         # Event loop performance
```

### Access Monitoring

```bash
# Prometheus
kubectl port-forward -n monitoring svc/prometheus 9090:9090

# Grafana
kubectl port-forward -n monitoring svc/grafana 3000:3000
```

## 🎯 Key Features

### Auto-Scaling (HPA)
- **Min replicas:** 2
- **Max replicas:** 10
- **CPU target:** 60%
- **Memory target:** 70%
- **Scale up:** CPU/Memory > target for 30s
- **Scale down:** CPU/Memory < target for 5min

Test scaling:
```bash
./scripts/load-test.sh
kubectl get hpa -n production -w
```

### High Availability
- ✅ 3 replicas by default
- ✅ Multi-AZ deployment (AWS)
- ✅ Rolling updates (zero downtime)
- ✅ Health checks (liveness + readiness)
- ✅ Pod anti-affinity (spread across nodes)

### Security
- ✅ Non-root containers (user: appuser)
- ✅ Kubernetes Secrets for credentials
- ✅ RBAC enabled
- ✅ AWS Security Groups
- ✅ Private subnets for database

## 🧪 Testing

```bash
# Health check
curl http://localhost:3000/health

# Database connectivity
curl http://localhost:3000/db-test

# Prometheus metrics
curl http://localhost:3000/metrics

# Load test (trigger HPA)
./scripts/load-test.sh

# Watch auto-scaling
kubectl get hpa -n production -w
```

## 🧹 Cleanup

### Local (Minikube)
```bash
helm uninstall my-node-app -n production
kubectl delete namespace production monitoring argocd
minikube delete
```

### AWS (IMPORTANT!)
```bash
# Delete application
helm uninstall my-node-app -n production

# Destroy infrastructure
cd terraform/
terraform destroy -var-file="terraform-free-tier.tfvars"

# Verify deletion
aws eks list-clusters --region eu-central-1
aws rds describe-db-instances --region eu-central-1
```

## 🎓 Skills Demonstrated

| Category | Technologies & Skills |
|----------|----------------------|
| **Containers** | Docker multi-stage builds, Alpine Linux, security best practices |
| **Orchestration** | Kubernetes deployments, services, ConfigMaps, Secrets, Ingress |
| **Package Management** | Helm charts with 100+ configurable parameters |
| **GitOps** | ArgoCD auto-sync, self-healing, declarative deployments |
| **IaC** | Terraform for AWS VPC, EKS, RDS provisioning |
| **CI/CD** | GitHub Actions workflows, Jenkins pipelines, automated testing |
| **Monitoring** | Prometheus metrics, Grafana dashboards, ServiceMonitor |
| **Auto-scaling** | HPA configuration, load testing, performance optimization |
| **Networking** | VPC design, subnet segmentation, NAT gateways, security groups |
| **Security** | RBAC, Secrets management, non-root containers, least privilege |
| **Cloud** | AWS EKS, RDS, EC2, IAM, networking architecture |
| **Databases** | PostgreSQL connection pooling, RDS multi-AZ |

## 📖 Documentation

- **Helm Chart:** [devops-lab-chart/README.md](devops-lab-chart/README.md)
- **Terraform Guide:** [terraform/README.md](terraform/README.md)
- **ArgoCD Setup:** [argocd/README.md](argocd/README.md)
- **Monitoring Alerts:** [docs/ALERTING.md](docs/ALERTING.md)

## 📝 License

MIT License - see [LICENSE](LICENSE)

## 👤 Author

**Deyvid Voynov**
- GitHub: [@voynovscloud](https://github.com/voynovscloud)
- Project: [devops-lab](https://github.com/voynovscloud/devops-lab)

---

<div align="center">

**⭐ If this project helped you learn DevOps, please star it!**

</div>
