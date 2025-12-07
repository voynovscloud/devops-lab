# DevOps Lab - Production-Ready Kubernetes Platform

> Complete DevOps pipeline with Kubernetes, GitOps, IaC, and automated CI/CD

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

## 🎯 What This Project Demonstrates

**Complete production DevOps pipeline** featuring:
- Node.js REST API with PostgreSQL database
- Docker containerization with multi-stage builds
- Kubernetes orchestration with Helm charts
- GitOps continuous deployment with ArgoCD
- Infrastructure as Code with Terraform (AWS EKS + RDS)
- Monitoring with Prometheus & Grafana
- Auto-scaling with HPA (Horizontal Pod Autoscaler)
- CI/CD with GitHub Actions & Jenkins

## 🛠️ Tech Stack

| Component | Technology |
|-----------|-----------|
| **Application** | Node.js 18, Express, PostgreSQL 15 |
| **Containers** | Docker, Kubernetes 1.28, Helm 3 |
| **GitOps** | ArgoCD (auto-sync, self-healing) |
| **CI/CD** | GitHub Actions, Jenkins |
| **Infrastructure** | Terraform, AWS (VPC, EKS, RDS) |
| **Monitoring** | Prometheus, Grafana, ServiceMonitor |
| **Auto-scaling** | HPA (CPU/Memory based) |

## 🏗️ Architecture

```
GitHub Repository (Source of Truth)
    ↓
┌───────────────────────┬──────────────────────┐
│   GitHub Actions      │     Jenkins          │
│   ├─ Build & Test     │   ├─ Build & Test    │
│   ├─ Docker → ghcr.io │   ├─ Docker Build    │
│   └─ Helm Bump        │   └─ Local Deploy    │
└───────────┬───────────┴──────────────────────┘
            ↓
ArgoCD (GitOps - Auto-sync every 3min)
    ↓
Kubernetes Cluster (AWS EKS / Minikube)
    ├─ Node App (3 replicas + HPA 2-10 pods)
    ├─ Prometheus (metrics collection, 30s scrape)
    ├─ Grafana (dashboards & visualization)
    └─ PostgreSQL (RDS Multi-AZ / Local)
         ↓
AWS Infrastructure (Terraform IaC)
    ├─ VPC (10.0.0.0/16, 2 AZs)
    ├─ EKS Cluster (t3.micro, 1-2 nodes)
    └─ RDS PostgreSQL 15.7 (db.t3.micro)
```

## 📂 Project Structure

```
devops-lab/
├── my-node-app/              # Node.js application
│   ├── server.js             # Express API (/health, /metrics, /db-test)
│   ├── database.js           # PostgreSQL connection pool
│   ├── metrics.js            # Prometheus metrics
│   └── Dockerfile            # Multi-stage Docker build
│
├── devops-lab-chart/         # Helm chart
│   ├── values.yaml           # Configuration (100+ params)
│   └── templates/            # K8s manifests
│       ├── deployment.yaml   # 3 replicas, rolling updates
│       ├── service.yaml      # ClusterIP
│       ├── hpa.yaml          # Auto-scaling (2-10 pods)
│       └── secret.yaml       # Database credentials
│
├── terraform/                # AWS Infrastructure
│   ├── vpc.tf               # VPC, subnets, NAT
│   ├── eks.tf               # Kubernetes cluster
│   ├── rds.tf               # PostgreSQL database
│   └── terraform-free-tier.tfvars  # Cost-optimized config
│
├── argocd/                   # GitOps deployment
│   └── application.yaml     # ArgoCD app definition
│
├── k8s/                      # Kubernetes manifests
│   ├── prometheus/          # Monitoring stack
│   └── grafana/             # Dashboards
│
├── .github/workflows/        # CI/CD pipelines
│   ├── build.yaml           # Test on every push
│   ├── push.yaml            # Build & push Docker image
│   └── helm-update.yaml     # Auto-bump chart version
│
└── scripts/
    └── load-test.sh         # HPA testing
```

## 🚀 Quick Start

### Prerequisites

```bash
# Required tools
docker --version        # 20.10+
kubectl version        # 1.28+
helm version          # 3.12+
minikube version      # 1.31+ (for local)
terraform --version   # 1.5+ (for AWS)
```

### Local Development (Minikube)

```bash
# 1. Start Minikube
minikube start --cpus=4 --memory=8192 --driver=docker
minikube addons enable ingress

# 2. Deploy monitoring
kubectl create namespace monitoring
kubectl apply -f k8s/prometheus/
kubectl apply -f k8s/grafana/

# 3. Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Get ArgoCD password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo

# 4. Deploy application
helm install my-node-app ./devops-lab-chart \
  --namespace production \
  --create-namespace

# 5. Access services
kubectl port-forward -n production svc/my-node-app 3000:80

# Test endpoints
curl http://localhost:3000/health
curl http://localhost:3000/metrics
```

### AWS Production Deployment

```bash
# 1. Configure AWS
aws configure
export TF_VAR_db_password="SecurePassword123!"

# 2. Deploy infrastructure
cd terraform/
terraform init
terraform apply -var-file="terraform-free-tier.tfvars"

# 3. Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name devops-lab

# 4. Deploy monitoring + app
kubectl create namespace monitoring
kubectl apply -f k8s/prometheus/
kubectl apply -f k8s/grafana/

# Get RDS endpoint
RDS_HOST=$(cd terraform && terraform output -raw rds_endpoint)

# Deploy with Helm
helm install my-node-app ./devops-lab-chart \
  --namespace production \
  --create-namespace \
  --set database.enabled=true \
  --set database.host=$RDS_HOST \
# 5. Verify deployment
kubectl get all -n production
kubectl get hpa -n production
```

> **💰 AWS Cost Estimate:** This deployment costs approximately **$107-120/month** (EKS Control Plane: $75, NAT Gateway: $32, EC2: minimal with Free Tier).  
> **Recommended:** Deploy for 2-3 days (~$7-10 total) to gather screenshots and experience, then run `terraform destroy` to avoid ongoing charges.

**⚠️ Cost Warning:** AWS deployment costs ~$107-120/month (EKS $75 + NAT $32). Deploy for 2-3 days only (~$7-10) for demo purposes.

## 🧪 Testing & Validation

```bash
# Health check
curl http://localhost:3000/health
# Response: {"status":"healthy"}

# Database test
curl http://localhost:3000/db-test

# Prometheus metrics
curl http://localhost:3000/metrics

# Load test (trigger auto-scaling)
./scripts/load-test.sh

# Watch HPA scale pods
kubectl get hpa -n production -w
```

## 📊 Monitoring

### Prometheus
- **Access:** `kubectl port-forward -n monitoring svc/prometheus 9090:9090`
- **Scrape interval:** 30s, **Retention:** 15 days
- **Auto-discovers** all pods with metrics endpoints

### Grafana
- **Access:** `kubectl port-forward -n monitoring svc/grafana 3000:3000`
- **Credentials:** admin / admin
- **Datasource:** Prometheus (pre-configured)
- **Dashboard:** Application monitoring (12 panels)

### Application Metrics
- `http_requests_total` - Request counter
- `http_request_duration_seconds` - Response time
- `nodejs_heap_size_used_bytes` - Memory usage
## 🔄 CI/CD Pipeline

### GitHub Actions Workflows

**Production Pipeline:**
1. **Build & Test** (`.github/workflows/build.yaml`) - Run tests on every push
2. **Docker Build & Push** (`.github/workflows/push.yaml`) - Build image → Push to `ghcr.io/voynovscloud/devops-lab-nodeapp`
3. **Helm Version Bump** (`.github/workflows/helm-update.yaml`) - Auto-increment chart version → ArgoCD auto-deploys

### Jenkins Pipeline (Local Development)

**Development Pipeline** (`Jenkinsfile`):
1. **Checkout** - Clone repository & get commit SHA
2. **Build** - Create Docker image with multi-stage build
3. **Test** - Run health checks & endpoint validation
4. **Deploy to Minikube** - Apply K8s manifests locally
5. **Verify** - Check deployment status & pod health

**Jenkins Setup:**
```bash
# Run Jenkins in Docker
docker run -d -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --name jenkins jenkins/jenkins:lts

# Get initial admin password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

### GitOps with ArgoCD
- **Auto-sync:** Every 3 minutes (polls Git repository)
- **Self-healing:** Automatically reverts manual changes
- **Source:** Git repository (single source of truth)
- **Prune:** Removes deleted resources automatically
- **Source:** Git repository (single source of truth)

## 🎯 Key Features

### Auto-Scaling (HPA)
- Min: 2 pods, Max: 10 pods
- CPU target: 60%, Memory target: 70%
- Scale up when target exceeded for 30s
- Scale down when under target for 5min

### High Availability
- 3 replicas by default
- Multi-AZ deployment (AWS)
- Rolling updates (zero downtime)
- Health checks (liveness + readiness probes)

### Security
- Non-root containers
- Kubernetes Secrets for credentials
- RBAC enabled
- AWS Security Groups

## 🧹 Cleanup

### Local (Minikube)
```bash
helm uninstall my-node-app -n production
kubectl delete namespace production monitoring argocd
minikube delete
```

### AWS
```bash
helm uninstall my-node-app -n production
cd terraform/
terraform destroy -var-file="terraform-free-tier.tfvars"
```

## 🎓 What I Learned

- **Kubernetes:** Deployments, Services, ConfigMaps, Secrets, HPA, Ingress
- **GitOps:** ArgoCD auto-sync, self-healing, declarative deployments
- **IaC:** Terraform for AWS VPC, EKS, RDS provisioning
- **CI/CD:** GitHub Actions workflows, Docker image automation
- **Monitoring:** Prometheus metrics collection, Grafana dashboards
- **Containerization:** Multi-stage Docker builds, security best practices
- **Cloud:** AWS networking, EKS cluster management

## 📖 Documentation

- **Helm Chart:** [devops-lab-chart/README.md](devops-lab-chart/README.md)
- **Terraform Guide:** [terraform/README.md](terraform/README.md)
- **ArgoCD Setup:** [argocd/README.md](argocd/README.md)

## 📝 License

MIT License - see [LICENSE](LICENSE)

## 👤 Author

**Deyvid Voynov**
- GitHub: [@voynovscloud](https://github.com/voynovscloud)

---

**⭐ If this project helped you learn DevOps, please star it!**
