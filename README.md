# DevOps Lab

> **A complete DevOps portfolio project showcasing modern cloud-native practices**

[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=flat&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![ArgoCD](https://img.shields.io/badge/ArgoCD-EF7B4D?style=flat&logo=argo&logoColor=white)](https://argo-cd.readthedocs.io/)
[![Helm](https://img.shields.io/badge/Helm-0F1689?style=flat&logo=helm&logoColor=white)](https://helm.sh/)
[![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=flat&logo=prometheus&logoColor=white)](https://prometheus.io/)
[![Grafana](https://img.shields.io/badge/Grafana-F46800?style=flat&logo=grafana&logoColor=white)](https://grafana.com/)
[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=flat&logo=terraform&logoColor=white)](https://terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-FF9900?style=flat&logo=amazonaws&logoColor=white)](https://aws.amazon.com/)

---

## 📋 What Is This Project?

This is a **real-world DevOps project** that demonstrates how modern applications are deployed and managed in production. It includes:

- **A Node.js application** with PostgreSQL database
- **Automated CI/CD pipelines** (GitHub Actions + Jenkins)
- **GitOps deployment** with ArgoCD
- **Infrastructure as Code** with Terraform (AWS)
- **Monitoring & Observability** with Prometheus and Grafana
- **Auto-scaling** based on CPU and memory usage

## 🎯 What I Learned

- How to containerize applications with Docker
- Setting up Kubernetes clusters locally and on AWS
- Implementing GitOps workflows with ArgoCD
- Building CI/CD pipelines with GitHub Actions
- Managing infrastructure as code with Terraform
- Setting up monitoring and alerting systems
- Configuring auto-scaling for production workloads

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         GitHub                              │
│                   (Source of Truth)                         │
└────────────┬────────────────────────────────────────────────┘
             │
             │ Git Push
             ▼
┌────────────────────────────────────────────────────────────┐
│                    CI/CD Pipeline                           │
│  ┌──────────────┐         ┌─────────────┐                  │
│  │ GitHub       │         │  Jenkins    │                  │
│  │ Actions      │────────▶│  Pipeline   │                  │
│  │ (Build/Test) │         │  (Deploy)   │                  │
│  └──────────────┘         └─────────────┘                  │
└────────────┬───────────────────────────────────────────────┘
             │
             │ Auto Deploy
             ▼
┌────────────────────────────────────────────────────────────┐
│                   Kubernetes Cluster                        │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  ArgoCD (GitOps Engine)                              │  │
│  │  Automatically syncs Git → Kubernetes                │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────────┐  │
│  │ Node.js App │  │ PostgreSQL   │  │ Monitoring      │  │
│  │ (3 replicas)│◀─│ Database     │  │ (Prometheus +   │  │
│  │ Auto-scales │  │ (RDS on AWS) │  │  Grafana)       │  │
│  └─────────────┘  └──────────────┘  └─────────────────┘  │
└────────────────────────────────────────────────────────────┘
```

---

## 🚀 Quick Start (Local Development)

### Prerequisites

You need these installed:
- **Docker** - For containerization
- **Minikube** - Local Kubernetes cluster  
- **kubectl** - Kubernetes command-line tool
- **Helm** - Kubernetes package manager

### Step 1: Clone the Repository

```bash
git clone https://github.com/voynovscloud/devops-lab.git
cd devops-lab
```

### Step 2: Start Minikube

```bash
# Start Minikube with enough resources
minikube start --cpus=4 --memory=8192 --disk-size=20g

# Enable required addons
minikube addons enable ingress
minikube addons enable metrics-server
```

### Step 3: Deploy with One Command

```bash
# This script does everything:
# - Builds Docker image
# - Creates namespace
# - Deploys app with Helm
# - Sets up monitoring
./deploy-k8s.sh
```

### Step 4: Install ArgoCD (GitOps)

```bash
# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Configure for HTTP access (simpler for local dev)
kubectl patch configmap argocd-cmd-params-cm -n argocd --type merge -p '{"data":{"server.insecure":"true"}}'
kubectl rollout restart deployment argocd-server -n argocd

# Apply Ingress for easy access
kubectl apply -f k8s/argocd-ingress.yaml

# Deploy app via ArgoCD
kubectl apply -f argocd/application.yaml
```

### Step 5: Add Hostnames

```bash
# Get Minikube IP
minikube ip

# Add to /etc/hosts (replace <MINIKUBE-IP> with actual IP)
sudo bash -c "cat >> /etc/hosts << EOF
<MINIKUBE-IP> app.local
<MINIKUBE-IP> grafana.local
<MINIKUBE-IP> prometheus.local
<MINIKUBE-IP> argocd.local
EOF"
```

---

## 🌐 Access Your Services

Once everything is running, you can access:

| Service | URL | Login |
|---------|-----|-------|
| **Your App** | http://app.local | No login needed |
| **ArgoCD** | http://argocd.local | `admin` / See below |
| **Grafana** | http://grafana.local | `admin` / `admin` |
| **Prometheus** | http://prometheus.local | No login needed |
| **Jenkins** | http://localhost:8081 | See below |

### Get Passwords

```bash
# ArgoCD password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo  # Just adds a new line

# Jenkins password (if running Jenkins)
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

---

## 🔄 How GitOps Works

**GitOps means: Git is your single source of truth**

1. **You make changes** in Git (like editing `values.yaml`)
2. **Push to GitHub**
3. **ArgoCD notices the change** (checks every 3 minutes)
4. **Automatically updates Kubernetes** to match Git

### Example: Change the number of replicas

```bash
# Edit the Helm values file
vim devops-lab-chart/values.yaml
# Change: replicaCount: 3  →  replicaCount: 5

# Commit and push
git add devops-lab-chart/values.yaml
git commit -m "Scale app to 5 replicas"
git push origin main

# Wait 1-3 minutes, then check:
kubectl get pods -n devops-lab
# You'll see 5 pods running!
```

**Why is this powerful?**
- ✅ All changes are tracked in Git (audit trail)
- ✅ Easy rollback (just revert the Git commit)
- ✅ No manual kubectl commands needed
- ✅ Team collaboration through pull requests

---

## 📦 Technology Stack

### Application
- **Node.js** - Backend runtime
- **Express** - Web framework
- **PostgreSQL** - Database (RDS on AWS)
- **Prometheus Client** - Metrics collection

### DevOps Tools
- **Docker** - Containerization
- **Kubernetes** - Container orchestration
- **Helm** - Kubernetes package manager
- **ArgoCD** - GitOps continuous delivery
- **Terraform** - Infrastructure as code

### CI/CD
- **GitHub Actions** - Automated testing and builds
- **Jenkins** - Deployment pipeline (optional)

### Monitoring
- **Prometheus** - Metrics collection and storage
- **Grafana** - Metrics visualization and dashboards

---

## 🔧 Project Components Explained

### 1. Node.js Application (`my-node-app/`)
A simple Express server with:
- Health check endpoint (`/health`)
- Database connectivity test (`/db-test`)
- Prometheus metrics (`/metrics`)

### 2. Helm Chart (`devops-lab-chart/`)
Packages everything needed to run the app in Kubernetes:
- Deployment (how many replicas)
- Service (networking)
- Ingress (external access)
- ConfigMaps (configuration)

### 3. Kubernetes Manifests (`k8s/`)
Raw Kubernetes YAML files for:
- Prometheus monitoring setup
- Grafana dashboards
- HPA (auto-scaling rules)

### 4. Terraform (`terraform/`)
Defines AWS infrastructure:
- VPC with public/private subnets
- EKS cluster (managed Kubernetes)
- RDS PostgreSQL database

### 5. ArgoCD (`argocd/`)
GitOps configuration that:
- Watches Git repository
- Automatically deploys changes
- Keeps Kubernetes in sync with Git

---

## 📊 Monitoring & Observability

The project includes full monitoring with Prometheus and Grafana.

### What Gets Monitored?
- **Application metrics** (requests, response times, errors)
- **Database connections** (health, pool size)
- **Kubernetes metrics** (CPU, memory, pod count)
- **Auto-scaling events** (when pods scale up/down)

### Access Dashboards

```bash
# Local development
# After running ./deploy-k8s.sh:
# - Prometheus: http://prometheus.local
# - Grafana: http://grafana.local (admin/admin)

# Production (AWS)
# Port-forward to access from your machine:
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
# Then open: http://localhost:3000
```

---

## ⚡ Auto-Scaling

The application automatically scales based on load:

| Setting | Value |
|---------|-------|
| **Minimum Pods** | 2 |
| **Maximum Pods** | 10 |
| **Scale Up When** | CPU > 60% or Memory > 70% |
| **Scale Down When** | CPU < 60% and Memory < 70% (after 5 min) |

```bash
# Watch auto-scaling in action
kubectl get hpa -n devops-lab -w

# Generate load to trigger scaling
kubectl run -it load-generator --rm --image=busybox --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://app-service.devops-lab.svc.cluster.local; done"
```

---

## 🚀 CI/CD Pipeline

### GitHub Actions (Automated)

Every time you push code, GitHub Actions automatically:

1. **Builds** the Docker image
2. **Runs tests** to ensure everything works
3. **Scans for vulnerabilities** 
4. **Pushes image** to GitHub Container Registry
5. **Updates Helm chart** version

No manual work needed! Just push your code.

### View Pipeline Status

Check `.github/workflows/` folder or visit:
`https://github.com/YOUR-USERNAME/devops-lab/actions`

---

## ☁️ Deploy to AWS (Production)

Want to deploy to real AWS infrastructure?

```bash
cd terraform

# 1. Configure AWS credentials
aws configure

# 2. Set database password
export TF_VAR_db_password="YourSecurePassword123!"

# 3. Review what will be created
terraform plan

# 4. Create infrastructure (takes ~30 minutes)
terraform apply

# 5. Configure kubectl to use new cluster
aws eks update-kubeconfig --region eu-central-1 --name devops-lab

# 6. Deploy application
cd ..
helm install devops-lab ./devops-lab-chart
```

**Costs:** Approximately $180-240/month for:
- EKS cluster
- RDS PostgreSQL database
- NAT Gateway
- Load balancers

See [`terraform/README.md`](terraform/README.md) for detailed instructions.

---



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
