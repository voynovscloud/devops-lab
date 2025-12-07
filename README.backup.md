# DevOps Lab

> Complete production-grade DevOps platform demonstrating cloud-native deployment, GitOps, Infrastructure as Code, CI/CD automation, and observability

[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=flat&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![ArgoCD](https://img.shields.io/badge/ArgoCD-EF7B4D?style=flat&logo=argo&logoColor=white)](https://argo-cd.readthedocs.io/)
[![Helm](https://img.shields.io/badge/Helm-0F1689?style=flat&logo=helm&logoColor=white)](https://helm.sh/)
[![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=flat&logo=prometheus&logoColor=white)](https://prometheus.io/)
[![Grafana](https://img.shields.io/badge/Grafana-F46800?style=flat&logo=grafana&logoColor=white)](https://grafana.com/)
[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=flat&logo=terraform&logoColor=white)](https://terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-FF9900?style=flat&logo=amazonaws&logoColor=white)](https://aws.amazon.com/)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)](https://docker.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=flat&logo=postgresql&logoColor=white)](https://postgresql.org/)

---

## 📋 Project Overview

This is a **complete end-to-end DevOps platform** showcasing production-ready practices for modern cloud-native applications. The project demonstrates the full software delivery lifecycle from code commit to automated deployment on AWS infrastructure.

### What This Project Demonstrates

- **Application Development**: Node.js REST API with PostgreSQL database integration
- **Containerization**: Multi-stage Docker builds with optimization and security best practices
- **Container Orchestration**: Kubernetes deployment with Helm package management
- **GitOps**: Declarative infrastructure management with ArgoCD for continuous deployment
- **CI/CD Automation**: GitHub Actions workflows for testing, building, and version management
- **Infrastructure as Code**: Terraform modules for AWS VPC, EKS cluster, and RDS database
- **Observability**: Prometheus metrics collection and Grafana visualization dashboards
- **Auto-scaling**: Horizontal Pod Autoscaler (HPA) for dynamic resource management
- **High Availability**: Multi-replica deployments across availability zones
- **Security**: Network isolation with private subnets, non-root containers, resource limits

### Technology Stack

**Application Layer:**
- **Node.js 18** - JavaScript runtime for backend application
- **Express 4.22** - Web application framework
- **PostgreSQL 15** - Relational database (RDS on AWS)
- **prom-client** - Prometheus metrics client library

**Container & Orchestration:**
- **Docker** - Application containerization with multi-stage builds
- **Kubernetes 1.28** - Container orchestration platform
- **Helm 3** - Kubernetes package manager with 100+ configurable parameters
- **Minikube** - Local Kubernetes development environment

**GitOps & Deployment:**
- **ArgoCD** - GitOps continuous delivery tool with auto-sync and self-healing
- **GitHub Actions** - CI/CD automation (build, test, push, version bump)
- **Jenkins** - Traditional CI/CD pipeline (optional alternative)

**Infrastructure:**
- **Terraform** - Infrastructure as Code for AWS provisioning
- **AWS VPC** - Isolated network with public/private subnets across 2 AZs
- **AWS EKS** - Managed Kubernetes service
- **AWS RDS** - Managed PostgreSQL database with automated backups
- **AWS NAT Gateway** - Secure outbound internet access for private subnets

**Monitoring & Observability:**
- **Prometheus** - Metrics collection and time-series database
- **Grafana** - Metrics visualization and alerting dashboards
- **ServiceMonitor** - Automatic Prometheus target discovery
- **HPA (Horizontal Pod Autoscaler)** - CPU/memory-based auto-scaling

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     GitHub Repository                        │
│              (Single Source of Truth)                        │
└────────────┬────────────────────────────────────────────────┘
             │
             │ git push
             ▼
┌─────────────────────────────────────────────────────────────┐
│                   CI/CD Pipeline                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │  GitHub Actions Workflows:                           │   │
│  │  1. Build & Test (npm install, npm test)            │   │
│  │  2. Docker Build & Push (ghcr.io)                   │   │
│  │  3. Helm Chart Version Bump                         │   │
│  └──────────────────────────────────────────────────────┘   │
└────────────┬────────────────────────────────────────────────┘
             │
             │ Image pushed to registry
             ▼
┌─────────────────────────────────────────────────────────────┐
│                    ArgoCD (GitOps)                           │
│  - Polls Git repo every 3 minutes                           │
│  - Detects changes in Helm chart                           │
│  - Auto-syncs Kubernetes cluster state                     │
│  - Self-healing: reverts manual changes                    │
└────────────┬────────────────────────────────────────────────┘
             │
             │ Deploys to cluster
             ▼
┌─────────────────────────────────────────────────────────────┐
│              Kubernetes Cluster (EKS/Minikube)              │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Node.js Application Pods (Auto-scaling 2-10)       │  │
│  │  - Express REST API                                  │  │
│  │  - Health checks (/health, /db-test)               │  │
│  │  - Prometheus metrics (/metrics)                    │  │
│  │  - Connection pooling to PostgreSQL                 │  │
│  └────────────┬─────────────────────────────────────────┘  │
│               │                                             │
│               │ Connects to                                 │
│               ▼                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  PostgreSQL Database (RDS/StatefulSet)              │  │
│  │  - Persistent storage                                │  │
│  │  - Automated backups                                 │  │
│  │  - Private subnet (AWS)                             │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Monitoring Stack                                    │  │
│  │  - Prometheus: Scrapes /metrics every 30s          │  │
│  │  - Grafana: Visualizes metrics dashboards          │  │
│  │  - ServiceMonitor: Auto-discovers targets          │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  HPA (Horizontal Pod Autoscaler)                    │  │
│  │  - Monitors CPU & Memory usage                      │  │
│  │  - Scales pods up when > 60% CPU or 70% Memory     │  │
│  │  - Scales pods down when usage drops                │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Infrastructure Layers

**AWS Production Environment:**
```
┌─────────────────── VPC (10.0.0.0/16) ───────────────────┐
│                                                          │
│  ┌─── AZ1 ────────────────┐  ┌─── AZ2 ────────────────┐│
│  │ Public Subnet          │  │ Public Subnet          ││
│  │ - NAT Gateway         │  │ - NAT Gateway         ││
│  │ - Load Balancer       │  │ - Load Balancer       ││
│  └───────────┬────────────┘  └───────────┬────────────┘│
│              │                            │             │
│  ┌───────────▼────────────┐  ┌───────────▼────────────┐│
│  │ Private Subnet         │  │ Private Subnet         ││
│  │ - EKS Worker Nodes    │  │ - EKS Worker Nodes    ││
│  │ - RDS PostgreSQL      │  │ - RDS Standby         ││
│  │ (t3.medium)           │  │ (Multi-AZ)            ││
│  └────────────────────────┘  └────────────────────────┘│
└──────────────────────────────────────────────────────────┘
```

---

## 🎯 Key Features & Technologies

### 1. **Application Development**

**Node.js REST API** (`my-node-app/`)
- Built with **Express.js** framework for HTTP request handling
- **PostgreSQL integration** using `pg` library with connection pooling
- **Health check endpoints** for Kubernetes liveness/readiness probes
- **Prometheus metrics** exposed at `/metrics` endpoint
- **Environment-based configuration** (PORT, DB credentials)

**Endpoints:**
- `GET /` - Root endpoint
- `GET /health` - Health status with database connectivity check
- `GET /db-test` - Direct database connection test
- `GET /metrics` - Prometheus metrics (requests, errors, DB connections)

### 2. **Containerization with Docker**

**Multi-stage Dockerfile:**
- **Stage 1 (builder)**: Install dependencies, run tests
- **Stage 2 (production)**: Copy only production dependencies and app code
- **Security**: Runs as non-root user, minimal attack surface
- **Optimization**: Smaller image size, faster builds

**Docker Best Practices:**
- `.dockerignore` to exclude unnecessary files
- Layer caching for faster builds
- Health check configured in container

### 3. **Kubernetes Orchestration**

**Deployment Strategy:**
- **3 replicas** by default for high availability
- **Rolling updates** for zero-downtime deployments
- **Resource limits**: CPU (500m) and Memory (256Mi) per pod
- **Liveness & Readiness probes** for automatic pod restarts
- **Pod Disruption Budget** to maintain availability during updates

**Services:**
- **ClusterIP** service for internal communication
- **Ingress** with nginx for external HTTP access
- **Service type** configurable via Helm values

### 4. **Helm Package Management**

**Production-Ready Helm Chart** (`devops-lab-chart/`)
- **100+ configurable parameters** in `values.yaml`
- **Templated manifests** for Deployment, Service, Ingress, ConfigMap, HPA
- **Version management**: Chart version auto-bumped by CI/CD
- **Environment support**: Different values files for dev/staging/prod
- **Reusable**: Same chart for local Minikube and AWS EKS

**Key Configurations:**
- Replica count, image tag, resource limits
- Database connection settings
- Ingress hostnames and TLS
- Auto-scaling thresholds
- Monitoring annotations

### 5. **GitOps with ArgoCD**

**ArgoCD Configuration** (`argocd/`)
- **Declarative deployment**: Git defines desired state
- **Automated sync**: Polls repository every 3 minutes
- **Self-healing**: Reverts manual kubectl changes back to Git state
- **Pruning**: Deletes resources removed from Git
- **Namespace creation**: Auto-creates namespaces if missing

**ArgoCD Application Manifest:**
```yaml
syncPolicy:
  automated:
    prune: true      # Delete resources not in Git
    selfHeal: true   # Revert manual changes
  syncOptions:
    - CreateNamespace=true
```

**Benefits:**
- Git as single source of truth
- Full audit trail of all changes
- Easy rollbacks (revert Git commit)
- No direct kubectl access needed
- Team collaboration via pull requests

### 6. **CI/CD with GitHub Actions**

**Three Automated Workflows** (`.github/workflows/`)

**A. Build & Test Workflow** (`build.yaml`)
- Triggers on every push
- Runs `npm install` to install dependencies
- Executes `npm test` to validate code
- Validates package.json and required files
- Fails build if tests don't pass

**B. Docker Push Workflow** (`push.yaml`)
- Triggers on push to main branch
- Builds Docker image with multi-stage build
- Tags image with semantic versioning
- Pushes to GitHub Container Registry (ghcr.io)
- Uses Docker layer caching for speed

**C. Helm Version Bump Workflow** (`helm-update.yaml`)
- Triggers after successful builds
- Auto-increments Helm chart version (patch bump)
- Updates `Chart.yaml` with new version
- Commits back to repository
- Triggers ArgoCD sync via Git change

**CI/CD Flow:**
```
Code Push → GitHub Actions → Tests Pass → Docker Build → 
Push to Registry → Helm Version Bump → Git Commit → 
ArgoCD Detects Change → Deploy to Kubernetes
```

### 7. **Infrastructure as Code with Terraform**

**AWS Infrastructure** (`terraform/`)

**VPC Configuration** (`vpc.tf`)
- Custom VPC with CIDR block 10.0.0.0/16
- 2 Public subnets across different Availability Zones
- 2 Private subnets for EKS nodes and RDS
- Internet Gateway for public subnet internet access
- NAT Gateways in each AZ for private subnet outbound traffic
- Route tables for traffic management

**EKS Cluster** (`eks.tf`)
- Kubernetes 1.28 cluster
- Managed node groups with t3.medium instances
- Auto-scaling group (2-4 nodes)
- IAM roles and policies for cluster and nodes
- VPC CNI addon for pod networking
- CoreDNS and kube-proxy addons

**RDS PostgreSQL** (`rds.tf`)
- PostgreSQL 15.4 engine
- db.t3.micro instance class
- Multi-AZ deployment for high availability
- Automated backups (7-day retention)
- Private subnet placement
- Security group allowing access only from EKS nodes

**Cost Estimation** (~$180-240/month):
- EKS control plane: ~$72/month
- EC2 nodes (2x t3.medium): ~$60/month
- RDS db.t3.micro: ~$15/month
- NAT Gateway: ~$32-45/month
- Load Balancers: ~$18/month

### 8. **Monitoring & Observability**

**Prometheus** (Metrics Collection)
- **ServiceMonitor** custom resource for automatic target discovery
- Scrapes `/metrics` endpoint every 30 seconds
- Collects: Request count, response time, error rate, CPU, memory, DB connections
- 10Gi persistent volume for metrics storage
- Alerting rules for critical conditions

**Grafana** (Visualization)
- Pre-configured Prometheus data source
- Dashboards for application and infrastructure metrics
- Real-time monitoring of pod health
- Historical data analysis
- 5Gi persistent volume for dashboard configurations

**Application Metrics** (prom-client)
- HTTP request counter by route and status code
- Database connection pool gauge
- Custom business metrics
- Default Node.js metrics (event loop, GC, memory)

### 9. **Auto-Scaling**

**Horizontal Pod Autoscaler (HPA)**
- **Minimum replicas**: 2 (high availability)
- **Maximum replicas**: 10 (cost control)
- **Scale-up trigger**: CPU > 60% OR Memory > 70%
- **Scale-down trigger**: Usage < thresholds for 5 minutes
- **Metrics source**: Kubernetes Metrics Server

**Scaling Behavior:**
```
Low Load:   2 pods running
Medium:     4-6 pods (CPU at 60-70%)
High Load:  8-10 pods (traffic spike)
Recovery:   Gradual scale-down after 5min cooldown
```

### 10. **Security Best Practices**

**Network Security:**
- Private subnets for application and database (no direct internet access)
- NAT Gateway for controlled outbound traffic
- Security groups restricting traffic between layers
- Ingress controller for external access (only HTTP/HTTPS ports open)

**Container Security:**
- Non-root user in Docker containers
- Read-only root filesystem
- Resource limits prevent resource exhaustion attacks
- Regular security scans with Trivy (optional)
- Secrets managed via Kubernetes Secrets (or AWS Secrets Manager)

**Access Control:**
- GitOps eliminates need for direct kubectl access
- ArgoCD RBAC for team-based permissions
- IAM roles for AWS resource access
- Kubernetes RBAC for service accounts

---

## 🚀 Getting Started

### Prerequisites

**Required Tools:**
- **Docker** (20.10+) - Container runtime
- **Minikube** (1.30+) - Local Kubernetes cluster
- **kubectl** (1.28+) - Kubernetes CLI
- **Helm** (3.0+) - Kubernetes package manager
- **Git** - Version control
- **Node.js** (18+) - For local app development
- **AWS CLI** - For AWS deployment (optional)
- **Terraform** (1.5+) - For infrastructure provisioning (optional)

**Installation Commands:**
```bash
# macOS
brew install docker minikube kubectl helm

# Ubuntu/Debian
sudo apt-get install docker.io
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

### Local Development Setup

#### Step 1: Clone Repository
```bash
git clone https://github.com/voynovscloud/devops-lab.git
cd devops-lab
```

#### Step 2: Start Minikube Cluster
```bash
# Start with sufficient resources
minikube start --cpus=4 --memory=8192 --disk-size=20g --driver=docker

# Enable required addons
minikube addons enable ingress          # For HTTP routing
minikube addons enable metrics-server   # For HPA auto-scaling
```

#### Step 3: Deploy Application
```bash
# Option A: Quick deployment (builds image locally)
./deploy-k8s.sh

# Option B: Manual deployment
docker build -t devops-lab-nodeapp:latest ./my-node-app
minikube image load devops-lab-nodeapp:latest
helm install devops-lab ./devops-lab-chart
```

#### Step 4: Install ArgoCD (GitOps)
```bash
# Create ArgoCD namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD pods to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

# Configure ArgoCD for HTTP (easier for local dev)
kubectl patch configmap argocd-cmd-params-cm -n argocd --type merge \
  -p '{"data":{"server.insecure":"true"}}'
kubectl rollout restart deployment argocd-server -n argocd

# Create Ingress for ArgoCD UI
kubectl apply -f k8s/argocd-ingress.yaml

# Deploy application via ArgoCD
kubectl apply -f argocd/application.yaml
```

#### Step 5: Configure Local DNS
```bash
# Get Minikube IP
MINIKUBE_IP=$(minikube ip)

# Add entries to /etc/hosts
echo "$MINIKUBE_IP app.local" | sudo tee -a /etc/hosts
echo "$MINIKUBE_IP argocd.local" | sudo tee -a /etc/hosts
echo "$MINIKUBE_IP grafana.local" | sudo tee -a /etc/hosts
echo "$MINIKUBE_IP prometheus.local" | sudo tee -a /etc/hosts
```

#### Step 6: Access Services

| Service | URL | Credentials | Purpose |
|---------|-----|-------------|---------|
| **Node.js App** | http://app.local | - | Main application |
| **ArgoCD UI** | http://argocd.local | admin / `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" \| base64 -d` | GitOps management |
| **Grafana** | http://grafana.local | admin / admin | Metrics dashboards |
| **Prometheus** | http://prometheus.local | - | Metrics database |

**Verify Deployment:**
```bash
# Check all pods are running
kubectl get pods -n devops-lab
kubectl get pods -n argocd
kubectl get pods -n monitoring

# Check services
kubectl get svc -n devops-lab

# Check ArgoCD application status
kubectl get application -n argocd

# View logs
kubectl logs -f deployment/node-app -n devops-lab
```

### AWS Production Deployment

#### Step 1: Configure AWS Credentials
```bash
# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure credentials
aws configure
# Enter: AWS Access Key ID
# Enter: AWS Secret Access Key
# Enter: Default region (eu-central-1)
# Enter: Default output format (json)
```

#### Step 2: Deploy Infrastructure with Terraform
```bash
cd terraform

# Initialize Terraform
terraform init

# Create terraform.tfvars (don't commit this file!)
cat > terraform.tfvars << EOF
db_password = "YourSecurePassword123!"
region = "eu-central-1"
cluster_name = "devops-lab"
EOF

# Preview infrastructure changes
terraform plan

# Create infrastructure (~30 minutes)
terraform apply -auto-approve
```

**What Terraform Creates:**
- VPC with 2 public + 2 private subnets
- Internet Gateway + 2 NAT Gateways
- EKS cluster with managed node groups
- RDS PostgreSQL instance
- Security groups and IAM roles
- All networking and routing

#### Step 3: Configure kubectl for EKS
```bash
# Update kubeconfig to use EKS cluster
aws eks update-kubeconfig --region eu-central-1 --name devops-lab

# Verify connection
kubectl get nodes
```

#### Step 4: Deploy Application to EKS
```bash
cd ..

# Get RDS endpoint from Terraform output
export RDS_ENDPOINT=$(cd terraform && terraform output -raw rds_endpoint)
export DB_NAME=$(cd terraform && terraform output -raw rds_database_name)

# Install application with database configuration
helm install devops-lab ./devops-lab-chart \
  --set database.enabled=true \
  --set database.host="${RDS_ENDPOINT%%:*}" \
  --set database.name="${DB_NAME}" \
  --set database.user="dbadmin" \
  --set database.password="YourSecurePassword123!" \
  --set image.repository="ghcr.io/voynovscloud/devops-lab-nodeapp" \
  --set image.pullPolicy="Always"

# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Deploy via ArgoCD
kubectl apply -f argocd/application.yaml
```

#### Step 5: Access Production Services
```bash
# Get LoadBalancer URL
kubectl get svc -n devops-lab

# Or port-forward for testing
kubectl port-forward svc/node-app -n devops-lab 8080:80
```

### Cleanup

**Local (Minikube):**
```bash
minikube delete
```

**AWS (Important - to avoid charges):**
```bash
cd terraform

# Delete all AWS resources
terraform destroy -auto-approve

# Verify everything is deleted in AWS Console
```

---

## 📂 Project Structure

```
devops-lab/
├── .github/workflows/              # GitHub Actions CI/CD pipelines
│   ├── build.yaml                 # Build & test workflow
│   ├── push.yaml                  # Docker build and push to registry
│   └── helm-update.yaml           # Auto-bump Helm chart version
│
├── my-node-app/                    # Node.js application source code
│   ├── server.js                  # Express app with REST endpoints
│   ├── database.js                # PostgreSQL connection pooling
│   ├── metrics.js                 # Prometheus metrics configuration
│   ├── test.js                    # Unit tests for CI pipeline
│   ├── package.json               # Dependencies (express, pg, prom-client)
│   ├── package-lock.json          # Locked dependency versions
│   └── Dockerfile                 # Multi-stage container build
│
├── devops-lab-chart/               # Helm chart for Kubernetes deployment
│   ├── Chart.yaml                 # Chart metadata and version
│   ├── values.yaml                # Default configuration (100+ parameters)
│   ├── templates/                 # Kubernetes manifest templates
│   │   ├── deployment.yaml       # Pod deployment configuration
│   │   ├── service.yaml          # Service (ClusterIP) definition
│   │   ├── ingress.yaml          # HTTP routing rules
│   │   ├── configmap.yaml        # Environment variables
│   │   ├── hpa.yaml              # Horizontal Pod Autoscaler
│   │   ├── namespace.yaml        # Namespace creation
│   │   └── _helpers.tpl          # Helm template helpers
│   └── README.md                  # Helm chart documentation
│
├── argocd/                         # GitOps configuration
│   ├── application.yaml           # ArgoCD Application manifest
│   ├── project.yaml               # ArgoCD Project definition
│   └── README.md                  # ArgoCD setup guide
│
├── terraform/                      # Infrastructure as Code for AWS
│   ├── main.tf                    # Main Terraform configuration
│   ├── provider.tf                # AWS provider setup
│   ├── variables.tf               # Input variables
│   ├── outputs.tf                 # Output values (endpoints, IDs)
│   ├── vpc.tf                     # VPC, subnets, gateways
│   ├── eks.tf                     # EKS cluster configuration
│   ├── rds.tf                     # PostgreSQL database setup
│   ├── terraform.tfvars.example   # Example configuration
│   └── README.md                  # Terraform usage guide
│
├── k8s/                            # Raw Kubernetes manifests
│   ├── node-app/                  # Application manifests
│   │   ├── deployment.yaml       # Alternative to Helm
│   │   ├── service.yaml          # Service definition
│   │   ├── hpa.yaml              # Auto-scaling config
│   │   ├── servicemonitor.yaml   # Prometheus scraping config
│   │   ├── configmap.yaml        # Configuration
│   │   └── namespace.yaml        # Namespace
│   ├── prometheus/                # Monitoring stack
│   │   ├── namespace.yaml        # Monitoring namespace
│   │   ├── configmap.yaml        # Prometheus configuration
│   │   ├── deployment.yaml       # Prometheus deployment
│   │   ├── service.yaml          # Prometheus service
│   │   ├── rbac.yaml             # RBAC permissions
│   │   └── pvc.yaml              # Persistent storage
│   ├── grafana/                   # Visualization
│   │   ├── deployment.yaml       # Grafana deployment
│   │   ├── service.yaml          # Grafana service
│   │   ├── configmap.yaml        # Datasource configuration
│   │   ├── secret.yaml           # Admin credentials
│   │   └── pvc.yaml              # Dashboard storage
│   ├── argocd-ingress.yaml       # ArgoCD HTTP access
│   └── ingress-all.yaml          # Combined ingress rules
│
├── deploy-k8s.sh                   # Automated deployment script
├── check-status.sh                 # Health check script
├── fix-nodeapp.sh                  # Rebuild and redeploy app
├── run-jenkins.sh                  # Start Jenkins container
├── setup-ingress.sh                # Configure ingress controller
├── Jenkinsfile                     # Jenkins pipeline definition
├── LICENSE                         # MIT License
└── README.md                       # This file
```

---

## 🚀 Quick Start Guide

### Prerequisites

Before you begin, ensure you have the following installed:

```bash
# Verify installations
docker --version          # Docker 20.10+
kubectl version --client  # Kubernetes CLI 1.28+
minikube version         # Minikube 1.31+
helm version             # Helm 3.12+
terraform --version      # Terraform 1.5+
node --version           # Node.js 18+
npm --version            # npm 9+
```

**Installation (if needed):**

```bash
# macOS
brew install docker kubectl minikube helm terraform node

# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y docker.io
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

---

### Option 1: Local Deployment (Minikube)

**Step 1: Start Minikube Cluster**

```bash
# Start Minikube with sufficient resources
minikube start --cpus=4 --memory=8192 --disk-size=20g --driver=docker

# Enable Ingress addon for HTTP routing
minikube addons enable ingress

# Verify cluster is running
kubectl cluster-info
```

**What this does:** Creates a local Kubernetes cluster with 4 CPU cores, 8GB RAM, and 20GB storage. The ingress addon allows you to access services via HTTP URLs instead of port-forwarding.

**Step 2: Install Prometheus Monitoring**

```bash
# Create monitoring namespace
kubectl create namespace monitoring

# Deploy Prometheus
kubectl apply -f k8s/prometheus/namespace.yaml
kubectl apply -f k8s/prometheus/rbac.yaml
kubectl apply -f k8s/prometheus/configmap.yaml
kubectl apply -f k8s/prometheus/pvc.yaml
kubectl apply -f k8s/prometheus/deployment.yaml
kubectl apply -f k8s/prometheus/service.yaml

# Wait for Prometheus to be ready
kubectl wait --for=condition=ready pod -l app=prometheus -n monitoring --timeout=300s
```

**What this does:** Installs Prometheus for metrics collection. The RBAC file grants permissions to scrape metrics from all pods, the ConfigMap defines which endpoints to scrape, and the PVC provides 10GB of persistent storage for metrics data.

**Step 3: Install Grafana Visualization**

```bash
# Deploy Grafana
kubectl apply -f k8s/grafana/configmap.yaml
kubectl apply -f k8s/grafana/secret.yaml
kubectl apply -f k8s/grafana/pvc.yaml
kubectl apply -f k8s/grafana/deployment.yaml
kubectl apply -f k8s/grafana/service.yaml

# Wait for Grafana to be ready
kubectl wait --for=condition=ready pod -l app=grafana -n monitoring --timeout=300s
```

**What this does:** Installs Grafana with Prometheus as a preconfigured datasource. Default credentials are admin/admin (defined in secret.yaml). Grafana will be accessible at `http://grafana.local` after ingress setup.

**Step 4: Install ArgoCD GitOps**

```bash
# Create ArgoCD namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD pods to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

# Configure ArgoCD for HTTP (no TLS for local development)
kubectl patch configmap argocd-cmd-params-cm -n argocd --type merge \
  -p '{"data":{"server.insecure":"true"}}'
kubectl rollout restart deployment argocd-server -n argocd

# Create Ingress for ArgoCD UI
kubectl apply -f k8s/argocd-ingress.yaml

# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

**What this does:** Installs ArgoCD for GitOps-based continuous deployment. The insecure mode disables TLS for easier local access. ArgoCD will monitor this Git repository and automatically deploy changes to Kubernetes.

**Step 5: Deploy Application with Helm**

```bash
# Add Helm repository (if using remote chart)
helm repo add devops-lab https://your-chart-repo.com
helm repo update

# Or install from local chart
helm install my-node-app ./devops-lab-chart \
  --namespace production \
  --create-namespace \
  --values ./devops-lab-chart/values.yaml \
  --set image.tag=latest

# Verify deployment
kubectl get pods -n production
kubectl get svc -n production
kubectl get hpa -n production
```

**What this does:** Deploys the Node.js application using Helm with all configurations from `values.yaml`. Creates a production namespace with 3 replica pods, a ClusterIP service, and HPA for auto-scaling. The application will automatically connect to PostgreSQL if database credentials are provided.

**Step 6: Configure Local DNS and Access Services**

```bash
# Get Minikube IP
minikube ip

# Add to /etc/hosts (replace <MINIKUBE_IP> with actual IP)
echo "<MINIKUBE_IP> argocd.local grafana.local prometheus.local app.local" | sudo tee -a /etc/hosts

# Apply ingress rules
kubectl apply -f k8s/ingress-all.yaml

# Access services in browser
# ArgoCD:     http://argocd.local
# Grafana:    http://grafana.local (admin/admin)
# Prometheus: http://prometheus.local
# Application: http://app.local/health
```

**What this does:** Configures your local machine to resolve service hostnames. Minikube's IP is mapped to friendly URLs so you can access dashboards and the application via browser instead of using `kubectl port-forward`.

**Step 7: Deploy Application via ArgoCD (GitOps Method)**

```bash
# Create ArgoCD Application from manifest
kubectl apply -f argocd/application.yaml

# Watch ArgoCD sync the application
kubectl get applications -n argocd

# Check application status
argocd app get my-node-app --port-forward
```

**What this does:** Creates an ArgoCD Application resource that monitors this Git repository. ArgoCD will automatically sync changes from Git to Kubernetes every 3 minutes. Any updates you push to Git will be automatically deployed.

---

### Option 2: AWS Deployment (Production)

**Step 1: Configure AWS Credentials**

```bash
# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure credentials
aws configure
# Enter: AWS Access Key ID, Secret Access Key, Region (us-east-1), Output format (json)

# Verify access
aws sts get-caller-identity
```

**Step 2: Deploy Infrastructure with Terraform**

```bash
# Navigate to Terraform directory
cd terraform/

# Copy example variables and customize
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values:
# - region, vpc_cidr, cluster_name, db_username, db_password, etc.

# Initialize Terraform
terraform init

# Review infrastructure plan
terraform plan

# Apply infrastructure (creates VPC, EKS, RDS)
terraform apply
# Review resources and type 'yes' to confirm
# This takes 15-20 minutes to create EKS cluster

# Save outputs
terraform output > outputs.txt
```

**What this does:** Creates complete AWS infrastructure including:
- VPC with public/private subnets across 2 AZs
- NAT Gateways for private subnet internet access
- EKS Kubernetes cluster (1.28) with 2-4 worker nodes
- RDS PostgreSQL 15.4 database in private subnet
- Security groups with proper ingress/egress rules
- IAM roles and policies for EKS

**Expected Cost:** ~$180-240/month

**Step 3: Configure kubectl for EKS**

```bash
# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name devops-lab-cluster

# Verify connection
kubectl get nodes

# Should see EKS worker nodes
```

**What this does:** Adds EKS cluster credentials to your `~/.kube/config` file, allowing kubectl to communicate with the AWS-managed Kubernetes cluster.

**Step 4: Deploy Application to EKS**

```bash
# Install monitoring stack (same commands as local)
kubectl apply -f k8s/prometheus/
kubectl apply -f k8s/grafana/

# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Deploy application with Helm (using RDS credentials)
helm install my-node-app ./devops-lab-chart \
  --namespace production \
  --create-namespace \
  --set database.enabled=true \
  --set database.host=$(terraform output -raw rds_endpoint) \
  --set database.username=postgres \
  --set database.password=<your-password> \
  --set database.name=appdb

# Verify deployment
kubectl get all -n production
```

**What this does:** Deploys the full stack to AWS EKS with RDS database integration. The application pods will connect to the managed PostgreSQL database using credentials from Terraform outputs.

**Step 5: Set Up Load Balancer (Optional)**

```bash
# Install AWS Load Balancer Controller
helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=devops-lab-cluster

# Apply ingress with ALB annotations
kubectl apply -f k8s/ingress-all.yaml

# Get Load Balancer URL
kubectl get ingress -n production
```

**What this does:** Creates an AWS Application Load Balancer to expose services publicly. The ALB will route traffic to your Kubernetes services based on hostname/path rules.

---

### Verification Steps

**Check Application Health:**

```bash
# Local (Minikube)
curl http://app.local/health

# AWS (replace with your ALB URL)
curl http://<load-balancer-url>/health

# Expected response:
# {"status":"healthy","timestamp":"2024-12-07T..."}
```

**Check Database Connection:**

```bash
curl http://app.local/db-test
# Expected: {"message":"Database connection successful","timestamp":"..."}
```

**Check Prometheus Metrics:**

```bash
curl http://app.local/metrics
# Should see metrics like:
# http_requests_total{method="GET",route="/health",status="200"} 42
# nodejs_heap_size_used_bytes 12345678
```

**Check Auto-Scaling:**

```bash
# View HPA status
kubectl get hpa -n production

# Generate load to trigger scaling
while true; do curl http://app.local/health; done

# Watch pods scale up
kubectl get pods -n production -w
```

**Check ArgoCD Sync:**

```bash
# Get ArgoCD password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Login via CLI
argocd login argocd.local --username admin --password <password>

# Check application sync status
argocd app list
argocd app get my-node-app
```

---

### Cleanup

**Local (Minikube):**

```bash
# Delete all resources
kubectl delete -f argocd/application.yaml
helm uninstall my-node-app -n production
kubectl delete namespace production monitoring argocd

# Stop Minikube
minikube stop

# Delete cluster (WARNING: destroys all data)
minikube delete
```

**AWS (Terraform):**

```bash
# Delete Kubernetes resources first
helm uninstall my-node-app -n production
kubectl delete namespace production monitoring argocd

# Destroy AWS infrastructure
cd terraform/
terraform destroy
# Review resources and type 'yes' to confirm
# This takes 10-15 minutes
```

**IMPORTANT:** Always run `terraform destroy` to avoid ongoing AWS charges. Forgetting to destroy resources can cost $200+/month.

---

## 🔧 Common Operations

### Deployment Commands

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

## 📚 What I Learned Building This Project

### Application Development
- **Node.js & Express**: Building RESTful APIs with proper routing, middleware, and error handling
- **PostgreSQL Integration**: Database connection pooling, query execution, and connection management
- **Health Checks**: Implementing liveness and readiness probes for Kubernetes
- **Prometheus Metrics**: Exposing custom metrics (HTTP requests, response times, errors)
- **Asynchronous Programming**: Using promises and async/await for database and HTTP operations
- **Environment Variables**: Managing configuration across development and production
- **Testing**: Writing unit tests for CI/CD pipelines

### Containerization & Orchestration
- **Docker Multi-Stage Builds**: Reducing image size from 1GB to 200MB
- **Container Security**: Running as non-root user, minimal base images (Alpine)
- **Docker Best Practices**: Layer caching, .dockerignore, proper ENTRYPOINT/CMD usage
- **Kubernetes Deployments**: Configuring replicas, rolling updates, resource limits
- **Services**: Understanding ClusterIP, NodePort, LoadBalancer service types
- **ConfigMaps & Secrets**: Separating configuration from code
- **Namespaces**: Isolating workloads and resources
- **Ingress Controllers**: HTTP routing and host-based routing
- **Probes**: Liveness, readiness, and startup probes for zero-downtime deployments

### Helm & Package Management
- **Chart Structure**: Understanding templates, values, helpers, and dependencies
- **Templating with Go**: Using conditionals, loops, and functions in manifests
- **Values Hierarchy**: Default values, environment-specific values, CLI overrides
- **Release Management**: Upgrades, rollbacks, and release history
- **Chart Versioning**: Semantic versioning and chart metadata
- **Parameterization**: Creating reusable charts with 100+ configurable parameters

### GitOps with ArgoCD
- **Declarative Configuration**: Managing infrastructure as code in Git
- **Auto-Sync**: Automatic deployment when Git repository changes
- **Self-Healing**: Automatic reconciliation if manual changes are made
- **Pruning**: Automatic removal of deleted resources
- **Sync Waves**: Controlling deployment order with annotations
- **Application Health**: Understanding health status and sync status
- **Multi-Environment Management**: Using different Git branches/paths for environments

### CI/CD with GitHub Actions
- **Workflow Triggers**: Understanding push, pull_request, workflow_dispatch events
- **Multi-Stage Pipelines**: Build → Test → Push → Deploy flow
- **Docker Build & Push**: Using GitHub Container Registry (ghcr.io)
- **Semantic Versioning**: Automating version bumps in Helm charts
- **Secrets Management**: Using GitHub Secrets for credentials
- **Matrix Builds**: Testing across multiple versions/configurations
- **Workflow Dependencies**: Using workflow_run to chain workflows

### Infrastructure as Code (Terraform)
- **AWS VPC Design**: Public/private subnets, NAT gateways, Internet gateway
- **Multi-AZ Architecture**: High availability across availability zones
- **EKS Cluster**: Managed Kubernetes, node groups, IAM roles
- **RDS Database**: Managed PostgreSQL, backup configuration, security groups
- **Security Groups**: Ingress/egress rules, least privilege access
- **Terraform State**: Remote state management, state locking
- **Modules**: Organizing infrastructure code into reusable modules
- **Outputs**: Exposing values for other tools to consume
- **Variables**: Parameterizing infrastructure for different environments
- **Cost Estimation**: Understanding AWS pricing and resource costs ($180-240/month)

### Monitoring & Observability
- **Prometheus Architecture**: Time-series database, scrape-based metrics collection
- **ServiceMonitor CRD**: Automatic target discovery with Prometheus Operator
- **Metrics Types**: Counters, gauges, histograms, summaries
- **PromQL**: Querying and aggregating metrics
- **Grafana Dashboards**: Creating visualizations with panels and queries
- **Alerting**: Setting up alert rules and notifications
- **Retention Policies**: Managing metrics storage and disk usage

### Auto-Scaling & Performance
- **Horizontal Pod Autoscaler (HPA)**: CPU and memory-based scaling
- **Metrics Server**: Collecting resource metrics from Kubernetes
- **Scaling Policies**: Scale-up and scale-down behavior configuration
- **Load Testing**: Generating traffic to test auto-scaling
- **Resource Requests & Limits**: CPU/memory allocation and throttling

### Security & Best Practices
- **Network Policies**: Controlling pod-to-pod communication
- **RBAC**: Role-based access control for Kubernetes
- **IAM Roles**: AWS permissions for EKS and services
- **Secrets Management**: Encrypting sensitive data
- **Container Security**: Non-root users, read-only filesystems
- **Image Scanning**: Identifying vulnerabilities in container images
- **Least Privilege**: Granting minimum necessary permissions

### DevOps Methodologies
- **12-Factor App Principles**: Configuration, dependencies, logs, etc.
- **Infrastructure as Code**: Version-controlled infrastructure
- **GitOps**: Git as single source of truth
- **Continuous Integration**: Automated testing on every commit
- **Continuous Deployment**: Automated deployment to production
- **Observability**: Metrics, logs, and traces for debugging
- **High Availability**: Multi-replica, multi-AZ deployments

---

## 🎯 Skills Demonstrated for Interviews

**For DevOps Engineer Positions:**
- End-to-end CI/CD pipeline creation
- Container orchestration with Kubernetes
- Infrastructure automation with Terraform
- GitOps implementation with ArgoCD
- Monitoring and observability setup
- Cloud infrastructure design (AWS)
- Security best practices

**For Cloud Engineer Positions:**
- AWS architecture (VPC, EKS, RDS)
- Multi-AZ high availability design
- Cost optimization strategies
- Infrastructure as Code expertise
- Kubernetes on AWS (EKS)

**For Site Reliability Engineer (SRE) Positions:**
- Monitoring and metrics collection
- Auto-scaling configuration
- Incident response preparation (health checks, logs)
- Performance optimization
- Disaster recovery (backups, multi-AZ)

---

## 🔗 Additional Resources

- **ArgoCD Documentation**: See [argocd/README.md](argocd/README.md)
- **Helm Chart Documentation**: See [devops-lab-chart/README.md](devops-lab-chart/README.md)
- **Terraform Guide**: See [terraform/README.md](terraform/README.md)
- **Monitoring Setup**: See [k8s/prometheus/HELM_INSTALL.md](k8s/prometheus/HELM_INSTALL.md)

---

## 📝 License

MIT License - see [LICENSE](LICENSE) file for details

---

## 👤 Author

**Sergei Voynov**

- GitHub: [@voynovscloud](https://github.com/voynovscloud)
- Project: [devops-lab](https://github.com/voynovscloud/devops-lab)

---

**⭐ If you found this project helpful, please consider giving it a star!**
