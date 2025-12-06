# DevOps Lab 🚀

**Production-ready Kubernetes environment with GitOps, CI/CD, and observability**

[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=flat&logo=kubernetes&logoColor=white)](https://kubernetes.io/)
[![ArgoCD](https://img.shields.io/badge/ArgoCD-EF7B4D?style=flat&logo=argo&logoColor=white)](https://argo-cd.readthedocs.io/)
[![Helm](https://img.shields.io/badge/Helm-0F1689?style=flat&logo=helm&logoColor=white)](https://helm.sh/)
[![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=flat&logo=prometheus&logoColor=white)](https://prometheus.io/)

Enterprise-grade DevOps environment demonstrating GitOps continuous delivery, infrastructure as code, monitoring, and CI/CD best practices.

---

## 📊 Architecture

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

**Tech Stack:** Kubernetes • ArgoCD • Helm • Jenkins • Prometheus • Grafana • Node.js

---

## 🚀 Quick Start

### Prerequisites
- Minikube or K3s cluster
- kubectl configured
- Helm 3 installed

### 1️⃣ Deploy Infrastructure

```bash
# Clone repository
git clone https://github.com/voynovscloud/devops-lab.git
cd devops-lab

# Deploy core services
./deploy-k8s.sh
```

### 2️⃣ Install ArgoCD

```bash
# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Configure insecure mode for HTTP access
kubectl patch configmap argocd-cmd-params-cm -n argocd --type merge -p '{"data":{"server.insecure":"true"}}'
kubectl rollout restart deployment argocd-server -n argocd

# Apply ArgoCD Ingress
kubectl apply -f k8s/argocd-ingress.yaml
```

### 3️⃣ Setup Ingress Access

```bash
# Add to /etc/hosts
sudo bash -c "cat >> /etc/hosts << HOSTS
$(minikube ip) app.local
$(minikube ip) grafana.local
$(minikube ip) prometheus.local
$(minikube ip) argocd.local
HOSTS"
```

### 4️⃣ Deploy with GitOps

```bash
# Deploy application via ArgoCD
kubectl apply -f argocd/application.yaml

# ✅ Done! ArgoCD now manages your deployment from Git
```

---

## 🌐 Access Services

| Service | URL | Credentials |
|---------|-----|-------------|
| **Node App** | http://app.local | - |
| **ArgoCD** | http://argocd.local | admin / (see below) |
| **Grafana** | http://grafana.local | admin / admin |
| **Prometheus** | http://prometheus.local | - |
| **Jenkins** | http://localhost:8081 | (Docker) |

### Get Passwords

```bash
# ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo

# Jenkins admin password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

---

## 🔄 GitOps Workflow

### How It Works

1. **Edit** Helm values or application code
2. **Commit & Push** to GitHub
3. **ArgoCD detects** changes automatically (within 3 minutes)
4. **Auto-sync** deploys to Kubernetes
5. **Self-healing** reverts manual cluster changes

### Example: Scale Application

```bash
# Edit values
vim devops-lab-chart/values.yaml
# Change: replicaCount: 5

# Commit and push
git add devops-lab-chart/values.yaml
git commit -m "Scale to 5 replicas"
git push origin main

# ✅ ArgoCD auto-deploys in ~3 minutes!
```

---

## 📦 Helm Chart

### Install/Upgrade

```bash
# Install
helm install devops-lab ./devops-lab-chart

# Upgrade with custom values
helm upgrade devops-lab ./devops-lab-chart --set replicaCount=5

# Rollback
helm rollback devops-lab
```

### Key Features
- 100+ configuration parameters
- Horizontal Pod Autoscaling (HPA)
- Production-ready templates
- ConfigMap management
- Resource limits and requests

See [`devops-lab-chart/README.md`](devops-lab-chart/README.md) for full documentation.

---

## 🔧 CI/CD Pipeline

**Jenkins Pipeline Stages:**
1. **Checkout** - Clone from Git
2. **Build** - Build Docker image
3. **Test** - Health checks and unit tests
4. **Security Scan** - Trivy vulnerability scanning
5. **Deploy** - Deploy to Kubernetes (optional)

### Start Jenkins

```bash
./run-jenkins.sh
# Access: http://localhost:8081
```

---

## 📊 Monitoring

### Prometheus
- **Metrics collection** from all pods
- **Auto-discovery** via annotations
- **10Gi persistent storage**
- Access: http://prometheus.local

### Grafana
- **Pre-configured** Prometheus datasource
- **Dashboard visualization**
- **5Gi persistent storage**
- Access: http://grafana.local

---

## 📁 Project Structure

```
devops-lab/
├── my-node-app/                # Node.js Express application
├── devops-lab-chart/           # Helm chart (GitOps deployment)
├── argocd/                     # ArgoCD configuration
├── k8s/                        # Kubernetes manifests (reference)
├── Jenkinsfile                 # CI/CD pipeline
├── deploy-k8s.sh               # Deployment automation
├── run-jenkins.sh              # Jenkins setup
└── Documentation/
    ├── PROJECT_SUMMARY.md      # Detailed project summary
    ├── ARGOCD_QUICKSTART.md    # ArgoCD guide
    └── INGRESS_ACCESS.md       # Ingress setup
```

---

## 🛠️ Useful Commands

### Check Status
```bash
./check-status.sh

# Or manually
kubectl get pods -A
kubectl get ingress -A
kubectl get applications -n argocd
```

### View Logs
```bash
# Node app
kubectl logs -f deployment/node-app -n devops-lab

# ArgoCD
kubectl logs -f -n argocd -l app.kubernetes.io/name=argocd-server
```

### Rebuild Node App
```bash
./fix-nodeapp.sh
```

### Scale Application
```bash
# Via kubectl
kubectl scale deployment/node-app -n devops-lab --replicas=5

# Via Helm
helm upgrade devops-lab ./devops-lab-chart --set replicaCount=5

# Via GitOps (recommended)
# Edit values.yaml, commit, push → ArgoCD auto-syncs!
```

---

## 🎓 Skills Demonstrated

### DevOps Engineering
✅ Kubernetes orchestration  
✅ GitOps continuous delivery (ArgoCD)  
✅ Helm chart development  
✅ CI/CD pipeline design (Jenkins)  
✅ Infrastructure as Code  
✅ Container security scanning (Trivy)  

### Site Reliability Engineering
✅ Monitoring with Prometheus/Grafana  
✅ Health checks and readiness probes  
✅ Horizontal pod autoscaling  
✅ Self-healing applications  
✅ Resource management  

### Cloud Native
✅ Microservices architecture  
✅ Service mesh ready  
✅ Ingress and routing  
✅ Persistent storage  
✅ Secret management  

---

## 🎯 Next Steps

### Phase 2: Cloud Migration
- [ ] Deploy to AWS EKS / GCP GKE / Azure AKS
- [ ] Implement Terraform for IaC
- [ ] Add external database (RDS/CloudSQL)
- [ ] Set up cloud load balancer
- [ ] Implement cloud logging

### Phase 3: Advanced Observability
- [ ] Add ELK/Loki stack for logging
- [ ] Implement distributed tracing (Jaeger)
- [ ] Set up alerting (Alertmanager + Slack)
- [ ] Create SLO/SLI dashboards

### Phase 4: Security & Compliance
- [ ] Sealed Secrets for Git encryption
- [ ] Pod Security Policies
- [ ] Network Policies
- [ ] RBAC fine-tuning
- [ ] Automated vulnerability patching

### Phase 5: Production Readiness
- [ ] Multi-cluster setup (dev/staging/prod)
- [ ] Disaster recovery procedures
- [ ] Performance/load testing
- [ ] Comprehensive runbooks
- [ ] Cost optimization

---

## 💼 Career Readiness

**Current Level:** Junior DevOps Engineer ✅

**Job Ready For:**
- Junior DevOps Engineer ($60k-$80k)
- Cloud Engineer (entry-level)
- Platform Engineer (entry-level)

**Recommended Certifications:**
- CKA (Certified Kubernetes Administrator)
- AWS Solutions Architect Associate
- HashiCorp Terraform Associate

---

## 📚 Documentation

- **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** - Comprehensive project overview
- **[ARGOCD_QUICKSTART.md](ARGOCD_QUICKSTART.md)** - ArgoCD quick start guide
- **[devops-lab-chart/README.md](devops-lab-chart/README.md)** - Helm chart documentation
- **[INGRESS_ACCESS.md](INGRESS_ACCESS.md)** - Ingress configuration guide

---

## 🏆 Features

✅ **GitOps Automation** - Push to Git → Auto-deploy  
✅ **Self-Healing** - ArgoCD corrects drift  
✅ **Helm Packaging** - Production-ready chart  
✅ **CI/CD Pipeline** - Build, test, scan, deploy  
✅ **Monitoring Stack** - Prometheus + Grafana  
✅ **Autoscaling** - HPA with CPU/memory targets  
✅ **Security Scanning** - Trivy vulnerability checks  
✅ **High Availability** - Multi-replica deployments  

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

## 📄 License

MIT License - see [LICENSE](LICENSE) file

---

## 🌟 Star This Project

If you find this project useful for learning or your portfolio, please ⭐ star it!

**Repository:** https://github.com/voynovscloud/devops-lab  
**Author:** voynovscloud

---

**🚀 Deploy with GitOps: `kubectl apply -f argocd/application.yaml`**
