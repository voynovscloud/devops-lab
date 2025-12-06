# DevOps Lab

Complete Kubernetes-based DevOps environment with CI/CD, monitoring, and observability.

## 🎯 Overview

Production-ready Kubernetes deployment featuring:
- **Node.js Application** - 3 replicas with health checks and Prometheus metrics
- **Prometheus** - Metrics collection and monitoring (10Gi storage)
- **Grafana** - Visualization dashboards (5Gi storage)
- **Jenkins CI/CD** - Runs in Docker for simplified management
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
├── k8s/                      # Kubernetes manifests
│   ├── node-app/             # Node app deployment
│   │   ├── namespace.yaml
│   │   ├── configmap.yaml
│   │   ├── deployment.yaml   # 3 replicas with health probes
│   │   ├── service.yaml
│   │   └── ingress.yaml
│   ├── prometheus/           # Prometheus monitoring
│   │   ├── namespace.yaml
│   │   ├── configmap.yaml    # Auto-discovery config
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── pvc.yaml          # 10Gi persistent storage
│   │   └── rbac.yaml         # Service discovery permissions
│   └── grafana/              # Grafana visualization
│       ├── deployment.yaml
│       ├── service.yaml
│       ├── pvc.yaml          # 5Gi persistent storage
│       ├── configmap.yaml    # Prometheus datasource
│       └── secret.yaml       # Admin credentials
├── Jenkinsfile               # CI/CD pipeline definition
├── run-jenkins.sh            # Start Jenkins in Docker
├── deploy-k8s.sh             # Automated deployment script
├── check-status.sh           # Quick status checker
├── fix-nodeapp.sh            # Rebuild and deploy node app
└── DEPLOYMENT_SUMMARY.md     # Detailed deployment guide

```

---

## 🚀 Quick Start

### Prerequisites

- Minikube or K3s
- Docker
- kubectl

### Deploy Everything

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

### Option 1: Ingress (Recommended)

Ingress is configured for direct access without port-forwarding:

1. **Add hosts entries** (one-time setup):
```bash
sudo bash -c "cat >> /etc/hosts << HOSTS
$(minikube ip) app.local
$(minikube ip) grafana.local
$(minikube ip) prometheus.local
HOSTS"
```

2. **Access services**:
- Node App: http://app.local
- Grafana: http://grafana.local (admin/admin)
- Prometheus: http://prometheus.local
- Jenkins: http://localhost:8081 (runs in Docker)

See [INGRESS_ACCESS.md](INGRESS_ACCESS.md) for detailed instructions.

### Option 2: Port Forward (Alternative)

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

✅ **Complete CI/CD** - Jenkins pipeline with all stages  
✅ **Monitoring Stack** - Prometheus + Grafana pre-configured  
✅ **Kubernetes Native** - Proper manifests with health checks  
✅ **Persistent Storage** - All stateful services use PVCs  
✅ **Auto-Discovery** - Prometheus auto-discovers services  
✅ **Security Scanning** - Trivy integration in pipeline  
✅ **Production Ready** - Resource limits, health probes, RBAC  
✅ **Easy Deployment** - One script deploys everything  

---

**Ready to deploy? Run `./deploy-k8s.sh` and you're live! 🚀**
