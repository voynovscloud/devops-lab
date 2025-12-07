# DevOps Lab

> Production-ready DevOps platform with Kubernetes, GitOps, Infrastructure as Code, and CI/CD automation

[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=flat&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![ArgoCD](https://img.shields.io/badge/ArgoCD-EF7B4D?style=flat&logo=argo&logoColor=white)](https://argo-cd.readthedocs.io/)
[![Helm](https://img.shields.io/badge/Helm-0F1689?style=flat&logo=helm&logoColor=white)](https://helm.sh/)
[![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=flat&logo=prometheus&logoColor=white)](https://prometheus.io/)
[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=flat&logo=terraform&logoColor=white)](https://terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-FF9900?style=flat&logo=amazonaws&logoColor=white)](https://aws.amazon.com/)
[![Jenkins](https://img.shields.io/badge/Jenkins-D24939?style=flat&logo=jenkins&logoColor=white)](https://jenkins.io/)

---

## 📋 Overview

This project demonstrates a complete end-to-end DevOps pipeline showcasing modern cloud-native practices. It includes everything from application development to production deployment on AWS, with multiple CI/CD options, comprehensive monitoring, and infrastructure automation.

### What This Project Includes

- **Node.js REST API** with PostgreSQL database integration
- **Multi-stage Docker** containerization with security best practices
- **Kubernetes** orchestration with Helm package management
- **GitOps** continuous deployment with ArgoCD
- **Dual CI/CD Options**: GitHub Actions and Jenkins pipelines
- **Infrastructure as Code** with Terraform (AWS VPC, EKS, RDS)
- **Comprehensive Monitoring** with Prometheus & Grafana
- **Auto-scaling** with Horizontal Pod Autoscaler (HPA)
- **High Availability** with multi-replica, multi-AZ deployments

---

## 🛠️ Technology Stack

| Category | Technologies | Purpose |
|----------|-------------|---------|
| **Application** | Node.js 18, Express 4.22, PostgreSQL 15 | Backend API with database |
| **Containers** | Docker, Kubernetes 1.28, Helm 3, Minikube | Containerization & orchestration |
| **GitOps** | ArgoCD | Declarative continuous deployment |
| **CI/CD** | GitHub Actions, Jenkins | Automated testing & delivery |
| **Infrastructure** | Terraform, AWS (VPC, EKS, RDS, NAT) | Cloud infrastructure automation |
| **Monitoring** | Prometheus, Grafana, ServiceMonitor, HPA | Observability & auto-scaling |
| **Security** | RBAC, Security Groups, Non-root containers | Access control & hardening |

---

## 🏗️ Architecture

### High-Level Overview

```
┌─────────────────────────────────────────────────────────────┐
│                   Git Repository (GitHub)                   │
│              Single Source of Truth for IaC                 │
└────────────┬───────────────────────────────┬────────────────┘
             │                               │
             │ git push                      │ git push
             ▼                               ▼
┌────────────────────────────┐  ┌───────────────────────────┐
│    GitHub Actions CI/CD    │  │   Jenkins CI/CD (Docker)  │
│  • Build & Test (npm test) │  │  • Build Docker Image     │
│  • Docker Build & Push     │  │  • Run Tests              │
│  • Helm Version Bump       │  │  • Deploy to Minikube     │
└────────────┬───────────────┘  └───────────┬───────────────┘
             │                               │
             │ Push to ghcr.io               │ Local deployment
             ▼                               ▼
┌─────────────────────────────────────────────────────────────┐
│                      ArgoCD (GitOps)                        │
│  • Auto-sync (3-minute polling)                             │
│  • Self-healing (reverts manual changes)                   │
│  • Declarative deployment from Git                         │
└────────────┬────────────────────────────────────────────────┘
             │
             │ Deploys to
             ▼
┌─────────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Node App   │  │  Prometheus  │  │   Grafana    │     │
│  │ (3 replicas) │  │  (Metrics)   │  │ (Dashboard)  │     │
│  │  + HPA       │  │   30s scrape │  │   Visualize  │     │
│  └──────┬───────┘  └──────┬───────┘  └──────────────┘     │
│         │                 │                                 │
│         │ metrics         │ scrapes                         │
│         └─────────────────┘                                 │
│  ┌──────────────────────────────────────────────────┐      │
│  │          PostgreSQL (RDS or Local)               │      │
│  │          Connection Pool (pg library)            │      │
│  └──────────────────────────────────────────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│              AWS Infrastructure (Terraform)                 │
│  ┌───────────────────────────────────────────────────┐     │
│  │  VPC (10.0.0.0/16) - 2 Availability Zones        │     │
│  │  ├─ Public Subnets (10.0.1.0/24, 10.0.2.0/24)   │     │
│  │  │  └─ NAT Gateways for outbound traffic         │     │
│  │  ├─ Private Subnets (10.0.3.0/24, 10.0.4.0/24)  │     │
│  │  │  └─ EKS Worker Nodes (t3.medium)              │     │
│  │  └─ Private Subnets (10.0.5.0/24, 10.0.6.0/24)  │     │
│  │     └─ RDS PostgreSQL 15.4 (Multi-AZ)            │     │
│  └───────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

### CI/CD Flow Comparison

**GitHub Actions Flow:**
```
Code Push → Build Job → Test Job → Push Docker Image → 
Bump Helm Version → Commit to Git → ArgoCD Detects Change → 
Kubernetes Deployment
```

**Jenkins Flow:**
```
Webhook/Manual Trigger → Build Docker Image → Run Tests → 
Deploy to Minikube → Health Check Verification
```

---

## 🚀 Quick Start

### Prerequisites

Install the following tools before starting:

```bash
# Verify installations
docker --version          # Docker 20.10+ for containerization
kubectl version --client  # Kubernetes CLI 1.28+ for cluster management
minikube version         # Minikube 1.31+ for local Kubernetes
helm version             # Helm 3.12+ for package management
terraform --version      # Terraform 1.5+ for infrastructure provisioning
node --version           # Node.js 18+ for local development
npm --version            # npm 9+ for dependency management
```

**Installation guides:**

```bash
# macOS (using Homebrew)
brew install docker kubectl minikube helm terraform node

# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y docker.io curl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

---

### Option 1: Local Development with Minikube

**Step 1: Start Minikube Cluster**

```bash
# Start Minikube with sufficient resources
minikube start --cpus=4 --memory=8192 --disk-size=20g --driver=docker

# Enable Ingress addon for HTTP routing
minikube addons enable ingress

# Verify cluster is running
kubectl cluster-info
kubectl get nodes
```

**Step 2: Deploy Monitoring Stack**

```bash
# Create monitoring namespace
kubectl create namespace monitoring

# Deploy Prometheus for metrics collection
kubectl apply -f k8s/prometheus/namespace.yaml
kubectl apply -f k8s/prometheus/rbac.yaml
kubectl apply -f k8s/prometheus/configmap.yaml
kubectl apply -f k8s/prometheus/pvc.yaml
kubectl apply -f k8s/prometheus/deployment.yaml
kubectl apply -f k8s/prometheus/service.yaml

# Wait for Prometheus to be ready
kubectl wait --for=condition=ready pod -l app=prometheus -n monitoring --timeout=300s

# Deploy Grafana for visualization
kubectl apply -f k8s/grafana/configmap.yaml
kubectl apply -f k8s/grafana/secret.yaml
kubectl apply -f k8s/grafana/pvc.yaml
kubectl apply -f k8s/grafana/deployment.yaml
kubectl apply -f k8s/grafana/service.yaml

# Wait for Grafana to be ready
kubectl wait --for=condition=ready pod -l app=grafana -n monitoring --timeout=300s
```

**Step 3: Install ArgoCD for GitOps**

```bash
# Create ArgoCD namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD server to be ready (takes 2-3 minutes)
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

# Configure ArgoCD for HTTP access (no TLS locally)
kubectl patch configmap argocd-cmd-params-cm -n argocd --type merge \
  -p '{"data":{"server.insecure":"true"}}'
kubectl rollout restart deployment argocd-server -n argocd

# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo
```

**Step 4: Deploy Application with Helm**

```bash
# Install application using Helm chart
helm install my-node-app ./devops-lab-chart \
  --namespace production \
  --create-namespace \
  --values ./devops-lab-chart/values.yaml

# Verify deployment
kubectl get pods -n production
kubectl get svc -n production
kubectl get hpa -n production

# Check application logs
kubectl logs -f deployment/my-node-app -n production
```

**Step 5: Configure Local DNS and Access Services**

```bash
# Get Minikube IP address
MINIKUBE_IP=$(minikube ip)
echo "Minikube IP: $MINIKUBE_IP"

# Add entries to /etc/hosts for local DNS
echo "$MINIKUBE_IP argocd.local grafana.local prometheus.local app.local" | sudo tee -a /etc/hosts

# Apply Ingress rules
kubectl apply -f k8s/argocd-ingress.yaml
kubectl apply -f k8s/ingress-all.yaml

# Access services in browser:
# - ArgoCD:     http://argocd.local (username: admin)
# - Grafana:    http://grafana.local (username: admin, password: admin)
# - Prometheus: http://prometheus.local
# - Application: http://app.local/health
```

**Step 6: Set Up GitOps with ArgoCD (Optional)**

```bash
# Create ArgoCD Application from manifest
kubectl apply -f argocd/application.yaml

# Check application sync status
kubectl get applications -n argocd

# View sync details
kubectl describe application my-node-app -n argocd

# ArgoCD will now automatically sync changes from Git repository every 3 minutes
```

---

### Option 2: AWS Production Deployment

**Step 1: Configure AWS Credentials**

```bash
# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure AWS credentials
aws configure
# Enter: AWS Access Key ID
# Enter: AWS Secret Access Key
# Enter: Default region (e.g., us-east-1)
# Enter: Default output format (json)

# Verify access
aws sts get-caller-identity
```

**Step 2: Provision Infrastructure with Terraform**

```bash
# Navigate to Terraform directory
cd terraform/

# Copy example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values:
# - region = "us-east-1"
# - vpc_cidr = "10.0.0.0/16"
# - cluster_name = "devops-lab-cluster"
# - db_username = "postgres"
# - db_password = "<secure-password>"
# - db_name = "appdb"

# Initialize Terraform
terraform init

# Preview infrastructure changes
terraform plan

# Create infrastructure (takes 15-20 minutes for EKS)
terraform apply
# Review the plan and type 'yes' to confirm

# Save important outputs
terraform output > outputs.txt
terraform output -raw rds_endpoint
```

**Infrastructure created:**
- VPC with 2 public and 4 private subnets across 2 AZs
- Internet Gateway and 2 NAT Gateways
- EKS Kubernetes cluster (v1.28) with managed node group
- RDS PostgreSQL 15.4 database (Multi-AZ)
- Security groups and IAM roles
- Estimated cost: **$180-240/month**

**Step 3: Configure kubectl for EKS**

```bash
# Update kubeconfig to connect to EKS
aws eks update-kubeconfig --region us-east-1 --name devops-lab-cluster

# Verify connection
kubectl get nodes
# Should show 2-4 worker nodes

# Check cluster information
kubectl cluster-info
```

**Step 4: Deploy Application to EKS**

```bash
# Deploy monitoring stack
kubectl create namespace monitoring
kubectl apply -f k8s/prometheus/
kubectl apply -f k8s/grafana/

# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Get RDS endpoint from Terraform
RDS_ENDPOINT=$(cd terraform && terraform output -raw rds_endpoint)

# Deploy application with database configuration
helm install my-node-app ./devops-lab-chart \
  --namespace production \
  --create-namespace \
  --set image.tag=latest \
  --set database.enabled=true \
  --set database.host=$RDS_ENDPOINT \
  --set database.port=5432 \
  --set database.username=postgres \
  --set database.password=<your-secure-password> \
  --set database.name=appdb

# Verify deployment
kubectl get all -n production
kubectl get hpa -n production
```

**Step 5: Access Services (Optional ALB Setup)**

```bash
# Install AWS Load Balancer Controller
helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=devops-lab-cluster

# Apply Ingress with ALB annotations
kubectl apply -f k8s/ingress-all.yaml

# Get Load Balancer URL (takes 2-3 minutes to provision)
kubectl get ingress -n production
# Access application via ALB DNS name
```

---

## 📂 Project Structure

```
devops-lab/
├── .github/
│   └── workflows/              # GitHub Actions CI/CD pipelines
│       ├── build.yaml         # Run tests on every push
│       ├── push.yaml          # Build & push Docker image to ghcr.io
│       └── helm-update.yaml   # Auto-increment Helm chart version
│
├── my-node-app/               # Node.js application source
│   ├── server.js             # Express REST API with /health, /db-test, /metrics
│   ├── database.js           # PostgreSQL connection pooling with pg library
│   ├── metrics.js            # Prometheus metrics configuration (prom-client)
│   ├── test.js               # Unit tests for CI pipeline
│   ├── package.json          # Dependencies: express, pg, prom-client
│   ├── package-lock.json     # Locked dependency versions
│   └── Dockerfile            # Multi-stage build (node:18-alpine base)
│
├── devops-lab-chart/          # Helm chart for Kubernetes deployment
│   ├── Chart.yaml            # Chart metadata (version 1.0.x)
│   ├── values.yaml           # Default values (100+ parameters)
│   ├── README.md             # Chart documentation
│   └── templates/            # Kubernetes manifest templates
│       ├── deployment.yaml   # Pod deployment with 3 replicas
│       ├── service.yaml      # ClusterIP service on port 80
│       ├── ingress.yaml      # HTTP routing configuration
│       ├── configmap.yaml    # Environment variables
│       ├── hpa.yaml          # Horizontal Pod Autoscaler (2-10 replicas)
│       ├── namespace.yaml    # Namespace creation
│       └── _helpers.tpl      # Helm template helper functions
│
├── argocd/                    # GitOps deployment configuration
│   ├── application.yaml      # ArgoCD Application manifest
│   ├── project.yaml          # ArgoCD Project definition
│   └── README.md             # ArgoCD setup and usage guide
│
├── terraform/                 # Infrastructure as Code for AWS
│   ├── main.tf               # Main Terraform configuration
│   ├── provider.tf           # AWS provider setup (us-east-1)
│   ├── variables.tf          # Input variables definitions
│   ├── outputs.tf            # Output values (RDS endpoint, EKS name)
│   ├── vpc.tf                # VPC, subnets, NAT gateways, route tables
│   ├── eks.tf                # EKS cluster, node groups, IAM roles
│   ├── rds.tf                # RDS PostgreSQL 15.4, security groups
│   ├── terraform.tfvars.example  # Example configuration values
│   └── README.md             # Terraform deployment guide
│
├── k8s/                       # Raw Kubernetes manifests (alternative to Helm)
│   ├── node-app/             # Application manifests
│   │   ├── namespace.yaml
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── configmap.yaml
│   │   ├── hpa.yaml
│   │   └── servicemonitor.yaml  # Prometheus scraping configuration
│   ├── prometheus/           # Monitoring stack
│   │   ├── namespace.yaml
│   │   ├── configmap.yaml    # Scrape configuration
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── rbac.yaml         # ServiceAccount, ClusterRole, Binding
│   │   ├── pvc.yaml          # 10Gi persistent volume for metrics
│   │   └── HELM_INSTALL.md   # Alternative Helm installation
│   ├── grafana/              # Visualization dashboard
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── configmap.yaml    # Prometheus datasource configuration
│   │   ├── secret.yaml       # Admin credentials (admin/admin)
│   │   └── pvc.yaml          # 5Gi persistent volume
│   ├── argocd-ingress.yaml   # ArgoCD UI HTTP access
│   └── ingress-all.yaml      # Combined Ingress for all services
│
├── scripts/                   # Utility automation scripts
│   ├── deploy-k8s.sh         # Full deployment automation
│   ├── check-status.sh       # Health check for all services
│   ├── fix-nodeapp.sh        # Rebuild and redeploy application
│   ├── run-jenkins.sh        # Start Jenkins Docker container
│   └── setup-ingress.sh      # Configure Ingress controller
│
├── Jenkinsfile               # Jenkins pipeline definition (Docker-based CI/CD)
├── LICENSE                   # MIT License
└── README.md                 # This file
```

---

## 🔧 Key Features Explained

### 1. **Application Development**

**Node.js REST API** (`my-node-app/server.js`)
- Express framework for HTTP server
- Three main endpoints:
  - `GET /health` - Health check (returns `{"status":"healthy"}`)
  - `GET /db-test` - PostgreSQL connection test
  - `GET /metrics` - Prometheus metrics exposure
- Graceful shutdown handling for Kubernetes
- Environment-based configuration

**Database Integration** (`my-node-app/database.js`)
- PostgreSQL connection pooling using `pg` library
- Connection pool configuration (max 20 connections)
- Automatic reconnection on failure
- Query execution with error handling

**Prometheus Metrics** (`my-node-app/metrics.js`)
- Custom metrics: HTTP request counter, response time histogram
- Default Node.js metrics: memory usage, CPU, event loop lag
- Metrics exposed at `/metrics` endpoint in Prometheus format

### 2. **Containerization with Docker**

**Multi-Stage Dockerfile:**
```dockerfile
# Stage 1: Build (node:18-alpine)
# - Install dependencies
# - Copy application code

# Stage 2: Production (node:18-alpine)
# - Copy only necessary files
# - Run as non-root user (node:node)
# - Expose port 3000
# - Final image size: ~200MB (vs 1GB+ single-stage)
```

**Security best practices:**
- Alpine Linux base image (minimal attack surface)
- Non-root user execution
- No unnecessary packages
- Layer caching for faster builds
- `.dockerignore` to exclude dev files

### 3. **Kubernetes Orchestration**

**Deployment Configuration:**
- **Replicas**: 3 pods for high availability
- **Rolling updates**: MaxSurge 1, MaxUnavailable 1 (zero-downtime)
- **Resource limits**: 
  - CPU: 200m request, 500m limit
  - Memory: 256Mi request, 512Mi limit
- **Liveness probe**: Checks `/health` every 10s
- **Readiness probe**: Checks `/health` before routing traffic
- **Image pull policy**: Always (ensures latest version)

**Service Configuration:**
- Type: ClusterIP (internal cluster communication)
- Port: 80 (external) → 3000 (container)
- Selector: Routes traffic to pods with matching labels

**Namespace Isolation:**
- Production namespace for application
- Monitoring namespace for Prometheus/Grafana
- ArgoCD namespace for GitOps tools

### 4. **Helm Package Management**

**Chart Features** (`devops-lab-chart/`)
- **100+ configurable parameters** in `values.yaml`
- **Template functions**: Resource naming, labels, selectors
- **Conditionals**: Enable/disable features (database, ingress, HPA)
- **Environment-specific values**: dev, staging, production
- **Version management**: Semantic versioning (1.0.x)

**Key parameters:**
- `replicaCount`: Number of pod replicas (default: 3)
- `image.repository`: Docker image location
- `image.tag`: Image version (default: latest)
- `database.enabled`: Enable PostgreSQL connection
- `database.host`: Database hostname/endpoint
- `ingress.enabled`: Enable HTTP routing
- `autoscaling.enabled`: Enable HPA

### 5. **GitOps with ArgoCD**

**ArgoCD Configuration** (`argocd/application.yaml`)
- **Source**: Git repository (this repo)
- **Path**: `devops-lab-chart/` (Helm chart)
- **Destination**: Kubernetes cluster, production namespace
- **Sync Policy**:
  - Auto-sync: Enabled (polls every 3 minutes)
  - Self-healing: Enabled (reverts manual changes)
  - Prune: Enabled (removes deleted resources)

**Benefits:**
- Declarative deployments (Git as single source of truth)
- Automatic rollback on failure
- Audit trail (Git history)
- No manual kubectl commands needed
- Multi-cluster deployment support

### 6. **CI/CD with GitHub Actions**

**Workflow 1: Build & Test** (`.github/workflows/build.yaml`)
```yaml
Trigger: Every push to any branch
Steps:
  1. Checkout code
  2. Setup Node.js 18
  3. npm install (install dependencies)
  4. npm test (run unit tests)
  Result: Validates code quality
```

**Workflow 2: Docker Push** (`.github/workflows/push.yaml`)
```yaml
Trigger: Push to main branch
Steps:
  1. Checkout code
  2. Login to ghcr.io (GitHub Container Registry)
  3. Build Docker image with multi-stage Dockerfile
  4. Tag image: latest, SHA, version
  5. Push to ghcr.io/voynovscloud/devops-lab-nodeapp
  Result: New image available for deployment
```

**Workflow 3: Helm Version Bump** (`.github/workflows/helm-update.yaml`)
```yaml
Trigger: After successful push to main
Steps:
  1. Read current version from Chart.yaml
  2. Increment patch version (1.0.1 → 1.0.2)
  3. Update Chart.yaml and appVersion
  4. Commit changes with [skip ci] tag
  5. Push to repository
  Result: ArgoCD detects new version and deploys
```

### 7. **CI/CD with Jenkins (Alternative)**

**Jenkins Setup** (`Jenkinsfile`, `scripts/run-jenkins.sh`)

**Docker-Based Jenkins:**
```bash
# Run Jenkins in Docker container
docker run -d --name jenkins \
  -p 8080:8080 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts
```

**Pipeline Stages:**

1. **Checkout**: Clone Git repository
2. **Build**: Create Docker image from Dockerfile
3. **Test**: Run unit tests in container
4. **Deploy to Minikube**: 
   - Check if Minikube is running
   - Apply Kubernetes manifests
   - Verify deployment
5. **Health Check**: Test `/health` endpoint
6. **Cleanup**: Remove test containers

**Pipeline Parameters:**
- `ENVIRONMENT`: Target environment (dev/staging/prod)
- `SKIP_TESTS`: Skip test execution (default: false)
- `DEPLOY_TO_MINIKUBE`: Deploy locally (default: true)

**Use Cases:**
- Local development with Minikube
- Manual deployment triggers
- Custom deployment logic
- Integration with on-premise systems

**Comparison: GitHub Actions vs Jenkins**

| Feature | GitHub Actions | Jenkins |
|---------|---------------|---------|
| **Hosting** | Cloud (GitHub) | Self-hosted (Docker) |
| **Setup** | Zero configuration | Requires installation |
| **Triggers** | Git push, PR | Webhook, manual, scheduled |
| **Target** | Production (ghcr.io + ArgoCD) | Local (Minikube) |
| **Best for** | Automated deployments | Development & testing |

### 8. **Infrastructure as Code with Terraform**

**AWS Resources Created** (`terraform/`)

**VPC Network** (`vpc.tf`)
- CIDR: 10.0.0.0/16
- 2 Availability Zones (us-east-1a, us-east-1b)
- **Public Subnets**: 10.0.1.0/24, 10.0.2.0/24
  - Internet Gateway for inbound/outbound traffic
  - NAT Gateways for private subnet access
- **Private Subnets (EKS)**: 10.0.3.0/24, 10.0.4.0/24
  - EKS worker nodes
  - Outbound via NAT Gateway
- **Private Subnets (RDS)**: 10.0.5.0/24, 10.0.6.0/24
  - PostgreSQL database
  - No internet access

**EKS Cluster** (`eks.tf`)
- Kubernetes version: 1.28
- Node group: t3.medium instances
- Scaling: 2-4 nodes (auto-scaling enabled)
- IAM roles: Cluster role, node role
- Addons: VPC-CNI, CoreDNS, kube-proxy

**RDS Database** (`rds.tf`)
- Engine: PostgreSQL 15.4
- Instance class: db.t3.micro
- Multi-AZ: Enabled (high availability)
- Storage: 20GB, auto-scaling to 100GB
- Backup retention: 7 days
- Security group: Port 5432 from EKS nodes only

**Cost Breakdown (Monthly):**
- EKS cluster control plane: $75
- EC2 t3.medium x2-4: $60-120
- NAT Gateways x2: $65
- RDS db.t3.micro: $15-25
- **Total**: ~$180-240/month

### 9. **Monitoring & Observability**

**Prometheus** (`k8s/prometheus/`)
- **Scrape interval**: 30 seconds
- **Retention**: 15 days
- **Storage**: 10Gi persistent volume
- **Service discovery**: Kubernetes API integration
- **Targets**: All pods with metrics endpoint
- **RBAC**: ClusterRole to discover all namespaces

**Prometheus Configuration** (scrape targets):
```yaml
- job_name: 'kubernetes-pods'
  kubernetes_sd_configs:
    - role: pod
  relabel_configs:
    - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
      action: keep
      regex: true
```

**Grafana** (`k8s/grafana/`)
- **Datasource**: Prometheus (pre-configured)
- **Storage**: 5Gi persistent volume for dashboards
- **Default credentials**: admin / admin
- **Access**: http://grafana.local

**ServiceMonitor** (Prometheus Operator CRD)
- Automatic target discovery
- No manual Prometheus configuration
- Namespace and label selectors

**Application Metrics Exposed:**
- `http_requests_total` - Total HTTP requests by method, route, status
- `http_request_duration_seconds` - Response time histogram
- `nodejs_heap_size_used_bytes` - Memory usage
- `nodejs_eventloop_lag_seconds` - Event loop performance

### 10. **Auto-Scaling with HPA**

**Horizontal Pod Autoscaler Configuration** (`devops-lab-chart/templates/hpa.yaml`)

```yaml
minReplicas: 2          # Minimum pods running
maxReplicas: 10         # Maximum pods allowed
targetCPUUtilization: 60%     # Scale up if CPU > 60%
targetMemoryUtilization: 70%  # Scale up if memory > 70%
```

**Scaling Behavior:**

**Scale Up:**
- Trigger: CPU > 60% or Memory > 70% for 30 seconds
- Action: Add pods (max +100% current replicas per 60s)
- Example: 2 pods → 4 pods → 8 pods → 10 pods

**Scale Down:**
- Trigger: CPU < 60% and Memory < 70% for 5 minutes
- Action: Remove pods (max -1 pod per 60s)
- Example: 10 pods → 9 pods → ... → 2 pods

**Metrics Server:**
- Required for HPA to function
- Collects CPU/memory metrics from kubelet
- Installation: `kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml`

**Testing Auto-Scaling:**
```bash
# Generate load to trigger scaling
while true; do curl http://app.local/health; done

# Watch HPA in real-time
kubectl get hpa -n production -w

# Watch pods being created
kubectl get pods -n production -w
```

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

**Deyvid Voynov**
- GitHub: [@voynovscloud](https://github.com/voynovscloud)
- Repository: [devops-lab](https://github.com/voynovscloud/devops-lab)
