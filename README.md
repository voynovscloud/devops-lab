# DevOps Lab

> Production-ready DevOps platform with Kubernetes, GitOps, IaC, and CI/CD automation

[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=flat&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![ArgoCD](https://img.shields.io/badge/ArgoCD-EF7B4D?style=flat&logo=argo&logoColor=white)](https://argo-cd.readthedocs.io/)
[![Helm](https://img.shields.io/badge/Helm-0F1689?style=flat&logo=helm&logoColor=white)](https://helm.sh/)
[![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=flat&logo=prometheus&logoColor=white)](https://prometheus.io/)
[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=flat&logo=terraform&logoColor=white)](https://terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-FF9900?style=flat&logo=amazonaws&logoColor=white)](https://aws.amazon.com/)

---

## 📋 Overview

Complete DevOps pipeline demonstrating:
- **Node.js REST API** with PostgreSQL database
- **Docker** multi-stage containerization
- **Kubernetes** orchestration with Helm charts
- **GitOps** deployment with ArgoCD
- **CI/CD** automation using GitHub Actions
- **Infrastructure as Code** with Terraform (AWS VPC, EKS, RDS)
- **Monitoring** with Prometheus & Grafana
- **Auto-scaling** with HPA

---

## 🛠️ Tech Stack

| Category | Technologies |
|----------|-------------|
| **Application** | Node.js 18, Express 4.22, PostgreSQL 15 |
| **Containers** | Docker, Kubernetes 1.28, Helm 3 |
| **GitOps** | ArgoCD, GitHub Actions |
| **Infrastructure** | Terraform, AWS (VPC, EKS, RDS) |
| **Monitoring** | Prometheus, Grafana, HPA |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      CI/CD Pipeline                         │
│  GitHub → Actions → Docker Build → Push → ArgoCD → K8s     │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Node App   │  │  Prometheus  │  │   Grafana    │     │
│  │  (3 Pods)    │  │  (Metrics)   │  │ (Dashboard)  │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│          ↓                ↑                                 │
│  ┌──────────────┐        │                                 │
│  │ PostgreSQL   │←───────┘                                 │
│  │ (RDS/Local)  │                                          │
│  └──────────────┘                                          │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                  AWS Infrastructure                         │
│  ┌─────────────────────────────────────────────────┐       │
│  │  VPC (10.0.0.0/16) - 2 Availability Zones      │       │
│  │  ├─ Public Subnets (NAT Gateway)               │       │
│  │  ├─ Private Subnets (EKS Nodes)                │       │
│  │  └─ Private Subnets (RDS PostgreSQL)           │       │
│  └─────────────────────────────────────────────────┘       │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 Quick Start

### Prerequisites

```bash
# Required tools
docker --version
kubectl version --client
minikube version
helm version
terraform --version
```

### Local Deployment

```bash
# 1. Start Minikube
minikube start --cpus=4 --memory=8192 --disk-size=20g
minikube addons enable ingress

# 2. Deploy infrastructure
kubectl apply -f k8s/prometheus/
kubectl apply -f k8s/grafana/
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 3. Deploy application
helm install my-node-app ./devops-lab-chart -n production --create-namespace

# 4. Access services (add to /etc/hosts)
echo "$(minikube ip) argocd.local grafana.local app.local" | sudo tee -a /etc/hosts
kubectl apply -f k8s/ingress-all.yaml

# URLs: http://argocd.local, http://grafana.local, http://app.local/health
```

### AWS Deployment

```bash
# 1. Configure AWS
aws configure

# 2. Deploy infrastructure (~20 min)
cd terraform/
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform apply

# 3. Connect to EKS
aws eks update-kubeconfig --region us-east-1 --name devops-lab-cluster

# 4. Deploy application
helm install my-node-app ./devops-lab-chart -n production --create-namespace \
  --set database.host=$(terraform output -raw rds_endpoint) \
  --set database.password=<your-password>
```

---

## 📂 Project Structure

```
devops-lab/
├── .github/workflows/       # CI/CD pipelines
│   ├── build.yaml          # Test & validate
│   ├── push.yaml           # Build & push Docker
│   └── helm-update.yaml    # Auto-version bump
├── my-node-app/            # Node.js application
│   ├── server.js           # Express REST API
│   ├── database.js         # PostgreSQL client
│   ├── metrics.js          # Prometheus metrics
│   └── Dockerfile          # Multi-stage build
├── devops-lab-chart/       # Helm chart (100+ params)
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/          # K8s manifests
├── argocd/                 # GitOps configuration
│   ├── application.yaml
│   └── project.yaml
├── terraform/              # AWS infrastructure
│   ├── vpc.tf              # Network layer
│   ├── eks.tf              # Kubernetes cluster
│   └── rds.tf              # PostgreSQL database
├── k8s/                    # Raw manifests
│   ├── node-app/
│   ├── prometheus/
│   └── grafana/
└── scripts/                # Utility scripts
    ├── deploy-k8s.sh
    ├── check-status.sh
    └── run-jenkins.sh
```

---

## 🔧 Key Features

### 1. **Containerization**
- Multi-stage Docker builds (image size: ~200MB)
- Non-root user, Alpine-based images
- Layer caching optimization

### 2. **Kubernetes Orchestration**
- 3 replicas with rolling updates
- Health checks (liveness/readiness probes)
- Resource limits and requests
- Namespace isolation

### 3. **Helm Package Management**
- 100+ configurable parameters
- Environment-specific values
- Template helpers and conditionals

### 4. **GitOps with ArgoCD**
- Auto-sync (3-minute intervals)
- Self-healing and pruning
- Declarative Git-based deployments

### 5. **CI/CD Pipeline**
- **Build workflow**: npm test on every push
- **Push workflow**: Docker build & push to registry
- **Helm workflow**: Auto-increment chart version

### 6. **Infrastructure as Code**
- **VPC**: 10.0.0.0/16, 2 AZs, public/private subnets
- **EKS**: Kubernetes 1.28, t3.medium nodes (2-4)
- **RDS**: PostgreSQL 15.4, Multi-AZ deployment
- **Cost**: ~$180-240/month

### 7. **Monitoring**
- Prometheus metrics scraping (30s intervals)
- Grafana dashboards with datasource
- ServiceMonitor for auto-discovery
- Custom application metrics (HTTP requests, latency)

### 8. **Auto-Scaling**
- HPA: 2-10 replicas
- CPU threshold: 60%
- Memory threshold: 70%

---

## 🎯 Commands Reference

| Task | Command |
|------|---------|
| **Deploy all** | `./scripts/deploy-k8s.sh` |
| **Check status** | `./scripts/check-status.sh` |
| **View logs** | `kubectl logs -f deployment/node-app -n production` |
| **Scale pods** | `kubectl scale deployment/node-app --replicas=5 -n production` |
| **Port forward** | `kubectl port-forward svc/node-app 3000:80 -n production` |
| **ArgoCD sync** | `kubectl patch app my-node-app -n argocd --type merge -p '{"operation":{"sync":{}}}'` |
| **Helm upgrade** | `helm upgrade my-node-app ./devops-lab-chart` |
| **Get pods** | `kubectl get pods -A` |
| **Describe HPA** | `kubectl describe hpa -n production` |

---

## 🧪 Testing & Validation

```bash
# Health check
curl http://app.local/health

# Database test
curl http://app.local/db-test

# Prometheus metrics
curl http://app.local/metrics

# Load test (trigger HPA)
while true; do curl http://app.local/health; done
```

---

## 🧹 Cleanup

### Local
```bash
helm uninstall my-node-app -n production
kubectl delete namespace production monitoring argocd
minikube delete
```

### AWS
```bash
helm uninstall my-node-app -n production
cd terraform/
terraform destroy  # ⚠️ Important to avoid charges
```

---

## 📚 Additional Documentation

- **ArgoCD Setup**: [argocd/README.md](argocd/README.md)
- **Helm Chart**: [devops-lab-chart/README.md](devops-lab-chart/README.md)
- **Terraform Guide**: [terraform/README.md](terraform/README.md)
- **Monitoring**: [k8s/prometheus/HELM_INSTALL.md](k8s/prometheus/HELM_INSTALL.md)

---

## 📝 License

MIT License - see [LICENSE](LICENSE) file

---

## 👤 Author

**Sergei Voynov**
- GitHub: [@voynovscloud](https://github.com/voynovscloud)
- Repository: [devops-lab](https://github.com/voynovscloud/devops-lab)
