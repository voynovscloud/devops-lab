# DevOps Lab

Production-ready Kubernetes-based DevOps environment with GitOps, CI/CD, monitoring, and observability.

## 🎯 Overview

Enterprise-grade Kubernetes deployment featuring:
- **Node.js Application** - 3 replicas with health checks and Prometheus metrics
- **Helm Chart** - Package management and templating
- **ArgoCD** - GitOps continuous delivery
- **Jenkins CI/CD** - Automated build and test pipeline (Docker)
- **Prometheus** - Metrics collection and monitoring (10Gi storage)
- **Grafana** - Visualization dashboards (5Gi storage)
- **Nginx Ingress** - Direct service access without port-forwarding

---

## 📁 Repository Structure

```
devops-lab/
├── my-node-app/              # Node.js application source
│   ├── server.js             # Express server with /health and /metrics
│   ├── metrics.js            # Prometheus metrics implementation
│   ├── test.js               # Application tests
│   ├── Dockerfile            # Multi-stage Docker build
│   └── package.json          # Dependencies
├── devops-lab-chart/         # Helm chart for GitOps deployment
│   ├── Chart.yaml            # Chart metadata
│   ├── values.yaml           # Default configuration values
│   ├── README.md             # Chart documentation
│   └── templates/            # Kubernetes resource templates
│       ├── deployment.yaml
│       ├── service.yaml
│       ├── ingress.yaml
│       ├── configmap.yaml
│       ├── namespace.yaml
│       ├── hpa.yaml          # Horizontal Pod Autoscaler
│       ├── _helpers.tpl      # Template helpers
│       └── NOTES.txt         # Post-install notes
├── argocd/                   # ArgoCD GitOps configuration
│   ├── application.yaml      # ArgoCD Application manifest
│   └── README.md             # GitOps setup guide
├── k8s/                      # Kubernetes manifests (legacy)
│   ├── node-app/             # Node app deployment
│   ├── prometheus/           # Prometheus monitoring
│   ├── grafana/              # Grafana visualization
│   ├── argocd-nodeport.yaml  # ArgoCD UI access
│   └── ingress-all.yaml      # Combined ingress
├── Jenkinsfile               # CI/CD pipeline definition
├── run-jenkins.sh            # Start Jenkins in Docker
├── deploy-k8s.sh             # Automated deployment script
├── check-status.sh           # Quick status checker
└── fix-nodeapp.sh            # Rebuild and deploy node app
```

---

## 🚀 Quick Start

### Prerequisites

- Minikube or K3s
- Docker
- kubectl
- Helm 3 (for Helm deployments)

### Deployment Options

#### Option 1: GitOps with ArgoCD (Recommended for Production)

```bash
# 1. Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 2. Access ArgoCD UI
kubectl apply -f k8s/argocd-nodeport.yaml
# Access at: https://$(minikube ip):30443
# Username: admin
# Password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# 3. Deploy application with GitOps
kubectl apply -f argocd/application.yaml

# ArgoCD will automatically sync from Git and deploy!
```

#### Option 2: Helm Chart Deployment

```bash
# Install with default values
helm install devops-lab ./devops-lab-chart

# Install with custom values
helm install devops-lab ./devops-lab-chart \
  --set replicaCount=5 \
  --set resources.limits.memory=512Mi

# Upgrade existing deployment
helm upgrade devops-lab ./devops-lab-chart

# Rollback to previous version
helm rollback devops-lab
```

#### Option 3: Traditional Kubernetes Manifests

```bash
# Clone repository
git clone https://github.com/voynovscloud/devops-lab.git
cd devops-lab

# Deploy Kubernetes services
./deploy-k8s.sh

# Setup Ingress
./setup-ingress.sh

# Start Jenkins in Docker
./run-jenkins.sh
```

The deployment script will:
1. Start Minikube (if not running)
2. Build and load Docker images
3. Apply all Kubernetes manifests
4. Configure Ingress for direct access
5. Wait for all pods to be ready

---

## 🌐 Access Services

### Ingress Access (Recommended)

Add hosts entries (one-time setup):
```bash
sudo bash -c "cat >> /etc/hosts << HOSTS
$(minikube ip) app.local
$(minikube ip) grafana.local
$(minikube ip) prometheus.local
HOSTS"
```

Access services:
- **Node App**: http://app.local
- **Grafana**: http://grafana.local (admin/admin)
- **Prometheus**: http://prometheus.local
- **ArgoCD**: https://$(minikube ip):30443 (admin/password from secret)
- **Jenkins**: http://localhost:8081 (runs in Docker)

See [INGRESS_ACCESS.md](INGRESS_ACCESS.md) for detailed instructions.

### ArgoCD Access

```bash
# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Access via NodePort
https://$(minikube ip):30443

# Or port-forward
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Then: https://localhost:8080
```

### Port Forward (Alternative)

```bash
# Node.js App
kubectl port-forward -n devops-lab svc/node-app 8080:80

# Grafana (admin/admin)
kubectl port-forward -n monitoring svc/grafana 3000:3000

# Prometheus
kubectl port-forward -n monitoring svc/prometheus 9090:9090
```

### Get Jenkins Admin Password

```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

---

## 🔧 Application Endpoints

### Node.js App

- **Root**: `http://localhost:8080/` - Welcome message
- **Health**: `http://localhost:8080/health` - Health check endpoint
- **Metrics**: `http://localhost:8080/metrics` - Prometheus metrics

### Test the App

```bash
curl http://localhost:8080/health
curl http://localhost:8080/metrics
```

---

## 📦 Helm Chart Deployment

The `devops-lab-chart` provides a production-ready Helm chart with 100+ configurable parameters.

### Quick Start

```bash
# Install with defaults (3 replicas)
helm install devops-lab ./devops-lab-chart

# Install with custom configuration
helm install devops-lab ./devops-lab-chart \
  --set replicaCount=5 \
  --set image.tag=v1.2.0 \
  --set resources.limits.memory=512Mi \
  --set autoscaling.enabled=true

# Install in specific namespace
helm install devops-lab ./devops-lab-chart --namespace production --create-namespace
```

### Common Operations

```bash
# List releases
helm list

# Get release status
helm status devops-lab

# Get values
helm get values devops-lab

# Upgrade deployment
helm upgrade devops-lab ./devops-lab-chart --set replicaCount=5

# Rollback to previous version
helm rollback devops-lab

# Uninstall
helm uninstall devops-lab
```

### Key Features

- **100+ Configuration Options**: Replicas, resources, autoscaling, ingress, etc.
- **Production Ready**: Resource limits, health probes, security contexts
- **Autoscaling**: HPA with CPU/memory targets
- **Ingress Support**: Configurable with annotations
- **ConfigMap Management**: Environment variables via values.yaml
- **Template Helpers**: Reusable labels and selectors

### Example Configurations

**High Availability:**
```bash
helm install devops-lab ./devops-lab-chart \
  --set replicaCount=5 \
  --set autoscaling.enabled=true \
  --set autoscaling.minReplicas=3 \
  --set autoscaling.maxReplicas=10
```

**Development:**
```bash
helm install devops-lab-dev ./devops-lab-chart \
  --set replicaCount=1 \
  --set resources.limits.memory=256Mi \
  --set ingress.enabled=false
```

**Production:**
```bash
helm install devops-lab-prod ./devops-lab-chart \
  --set image.tag=v1.0.0 \
  --set resources.limits.memory=1Gi \
  --set resources.limits.cpu=1000m \
  --set autoscaling.enabled=true \
  --set ingress.enabled=true \
  --set ingress.host=app.production.com
```

See `devops-lab-chart/README.md` for complete documentation.

---

## 🔄 GitOps with ArgoCD

ArgoCD enables automated, Git-based continuous delivery with self-healing and rollback capabilities.

### Architecture

```
Git Repository → ArgoCD Monitors → Auto-Sync → Kubernetes Cluster
     ↑                                              ↓
Developer Push                            Application Running
```

### Installation

```bash
# 1. Create namespace
kubectl create namespace argocd

# 2. Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 3. Expose ArgoCD UI
kubectl apply -f k8s/argocd-nodeport.yaml

# 4. Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Deploy Application

```bash
# Deploy with GitOps
kubectl apply -f argocd/application.yaml

# Check status
kubectl get application devops-lab-app -n argocd

# Watch sync progress
kubectl get application devops-lab-app -n argocd -w
```

### GitOps Workflow

1. **Developer** makes changes to Helm chart or values.yaml
2. **Push** changes to Git (main branch)
3. **ArgoCD** detects changes (within 3 minutes)
4. **Auto-sync** applies changes to cluster
5. **Self-healing** reverts manual cluster changes
6. **Notification** sent on sync completion

### Key Features

- **Automated Sync**: Changes in Git automatically deployed
- **Self-Healing**: Reverts manual cluster modifications
- **Rollback**: Easy rollback to any Git commit
- **Drift Detection**: Shows differences between Git and cluster
- **Health Monitoring**: Tracks resource health status
- **Multi-Environment**: Support for dev/staging/prod

### Common Operations

```bash
# View application status
argocd app get devops-lab-app

# Manual sync (if needed)
argocd app sync devops-lab-app

# Rollback to previous version
argocd app rollback devops-lab-app

# View sync history
argocd app history devops-lab-app
```

### Update Application

Simply update Git and ArgoCD handles the rest:

```bash
# Update Helm values
vim devops-lab-chart/values.yaml

# Commit and push
git add devops-lab-chart/values.yaml
git commit -m "Increase replicas to 5"
git push

# ArgoCD auto-syncs within 3 minutes!
```

See `argocd/README.md` for complete GitOps guide.

---

## 🔄 CI/CD Pipeline

The Jenkins pipeline (`Jenkinsfile`) performs:

1. **Checkout** - Pull code from Git
2. **Build** - Build Docker image with tags
3. **Test** - Run application tests with health checks
4. **Security Scan** - Trivy vulnerability scanning
5. **Push** - Push to GitHub Container Registry (optional)
6. **Deploy** - Deploy to Kubernetes (optional)

### Pipeline Features

- Dynamic port allocation for testing
- Parallel stage execution
- Security scanning with Trivy
- Graceful credential handling
- Build summary reporting

---

## 📊 Monitoring Setup

### Prometheus

- **Auto-discovers** pods in `devops-lab` namespace
- **Scrapes metrics** from pods with annotations:
  ```yaml
  prometheus.io/scrape: "true"
  prometheus.io/port: "3000"
  prometheus.io/path: "/metrics"
  ```
- **Persistent storage** via 10Gi PVC

### Grafana

- **Pre-configured** Prometheus datasource
- **Default credentials**: admin / admin
- **Persistent dashboards** via 5Gi PVC

---

## 🛠️ Useful Commands

### Check Status

```bash
# Run status check script
./check-status.sh

# Or manually
kubectl get pods -A
kubectl get svc -A
kubectl get pvc -A
```

### View Logs

```bash
# Node app
kubectl logs -f deployment/node-app -n devops-lab

# Jenkins (Docker)
docker logs -f jenkins

# Grafana
kubectl logs -f deployment/grafana -n monitoring

# Prometheus
kubectl logs -f deployment/prometheus -n monitoring
```

### Scale Application

```bash
# Scale node app to 5 replicas
kubectl scale deployment/node-app -n devops-lab --replicas=5

# Check status
kubectl get pods -n devops-lab
```

### Restart Services

```bash
kubectl rollout restart deployment/node-app -n devops-lab
docker restart jenkins  # Jenkins runs in Docker
kubectl rollout restart deployment/grafana -n monitoring
kubectl rollout restart deployment/prometheus -n monitoring
```

### Rebuild Node App

```bash
# Use the helper script
./fix-nodeapp.sh

# Or manually
docker build -t devops-lab-nodeapp:latest ./my-node-app/
minikube image load devops-lab-nodeapp:latest
kubectl rollout restart deployment/node-app -n devops-lab
```

---

## 🔐 Security

- **Non-root containers** where possible
- **Read-only root filesystem** for node app
- **Security scanning** with Trivy in CI/CD
- **RBAC configured** for service accounts
- **Network policies** ready (add as needed)

---

## 📝 Configuration

### Node App Configuration

Edit `k8s/node-app/configmap.yaml`:
```yaml
NODE_ENV: production
PORT: "3000"
```

### Prometheus Targets

Edit `k8s/prometheus/configmap.yaml` to add more scrape targets.

### Grafana Datasources

Pre-configured in `k8s/grafana/configmap.yaml` with Prometheus endpoint.

---

## 🐛 Troubleshooting

### Minikube Not Starting

```bash
minikube delete
minikube start --cpus=4 --memory=8192 --disk-size=20g
```

### Pods Not Running

```bash
# Check pod status
kubectl describe pod <pod-name> -n <namespace>

# Check logs
kubectl logs <pod-name> -n <namespace>
```

### Image Pull Errors

For local development, the node app uses `imagePullPolicy: Never` and loads images into Minikube:
```bash
./fix-nodeapp.sh
```

For production, update `k8s/node-app/deployment.yaml`:
- Change image to GHCR: `ghcr.io/voynovscloud/devops-lab-nodeapp:latest`
- Change `imagePullPolicy: Never` to `imagePullPolicy: Always`

---

## 📚 Additional Resources

- **[INGRESS_ACCESS.md](INGRESS_ACCESS.md)** - Ingress setup and configuration guide
- **[LICENSE](LICENSE)** - MIT License

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details

---

## ✨ Features Highlight

✅ **GitOps with ArgoCD** - Automated deployments from Git  
✅ **Helm Charts** - Professional package management  
✅ **Complete CI/CD** - Jenkins pipeline with all stages  
✅ **Monitoring Stack** - Prometheus + Grafana pre-configured  
✅ **Kubernetes Native** - Production-ready manifests  
✅ **Persistent Storage** - All stateful services use PVCs  
✅ **Auto-Discovery** - Prometheus auto-discovers services  
✅ **Security Scanning** - Trivy integration in pipeline  
✅ **Autoscaling** - HPA with CPU/memory targets  
✅ **Self-Healing** - ArgoCD auto-corrects drift  

---

## 🎓 Learning Path

This project demonstrates:

1. **Container Orchestration**: Kubernetes deployments, services, ingress
2. **GitOps**: Declarative, Git-based continuous delivery with ArgoCD
3. **Package Management**: Helm charts with templating and values
4. **CI/CD**: Automated build, test, security scan, and deploy pipelines
5. **Monitoring**: Prometheus metrics collection and Grafana visualization
6. **Infrastructure as Code**: All configuration in version control
7. **DevOps Best Practices**: Health checks, resource limits, RBAC, autoscaling

**Ideal for**: DevOps Engineer portfolios, cloud engineering interviews, learning Kubernetes

---

**Ready to deploy?**

- **Quick Start**: `./deploy-k8s.sh`
- **GitOps**: `kubectl apply -f argocd/application.yaml`
- **Helm**: `helm install devops-lab ./devops-lab-chart`

🚀 **Choose your deployment method and go live!**
