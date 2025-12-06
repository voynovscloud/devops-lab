# DevOps Lab

Complete Kubernetes-based DevOps environment with CI/CD, monitoring, and observability.

## 🎯 Overview

A simplified, production-ready setup featuring:
- **Node.js Application** with health checks and Prometheus metrics
- **Jenkins CI/CD** with automated build, test, scan, and deploy pipeline
- **Prometheus** for metrics collection and monitoring
- **Grafana** for visualization and dashboards
- **Kubernetes** deployment with proper resource management

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
│   ├── grafana/              # Grafana visualization
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── pvc.yaml          # 5Gi persistent storage
│   │   ├── configmap.yaml    # Prometheus datasource
│   │   └── secret.yaml       # Admin credentials
│   └── jenkins/              # Jenkins CI/CD
│       ├── namespace.yaml
│       ├── deployment.yaml   # With Docker socket
│       ├── service.yaml
│       ├── pvc.yaml          # 20Gi persistent storage
│       └── rbac.yaml         # Kubernetes API access
├── Jenkinsfile               # CI/CD pipeline definition
├── deploy-k8s.sh             # Automated deployment script
├── check-status.sh           # Quick status checker
├── fix-nodeapp.sh            # Rebuild and deploy node app
└── DEPLOYMENT_SUMMARY.md     # Detailed deployment guide

```

---

## 🚀 Quick Start

### Prerequisites

- **Minikube** or **K3s** installed
- **Docker** installed
- **kubectl** available (or use `minikube kubectl --`)

### Deploy Everything

```bash
# Clone the repository
git clone https://github.com/voynovscloud/devops-lab.git
cd devops-lab

# Run the deployment script
./deploy-k8s.sh
```

The script will:
1. Detect/start Minikube or K3s
2. Apply all Kubernetes manifests
3. Fix Grafana permissions
4. Wait for all pods to be ready
5. Display access instructions

---

## 🌐 Access Services

### Port Forward to Local Machine

```bash
# Node.js App
kubectl port-forward -n devops-lab svc/node-app 8080:80
# Access at: http://localhost:8080

# Jenkins
kubectl port-forward -n jenkins svc/jenkins 8081:8080
# Access at: http://localhost:8081

# Grafana (admin/admin)
kubectl port-forward -n monitoring svc/grafana 3000:3000
# Access at: http://localhost:3000

# Prometheus
kubectl port-forward -n monitoring svc/prometheus 9090:9090
# Access at: http://localhost:9090
```

### Get Jenkins Admin Password

```bash
kubectl exec -n jenkins deployment/jenkins -- cat /var/jenkins_home/secrets/initialAdminPassword
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

# Jenkins
kubectl logs -f deployment/jenkins -n jenkins

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
kubectl rollout restart deployment/jenkins -n jenkins
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

- **[DEPLOYMENT_SUMMARY.md](DEPLOYMENT_SUMMARY.md)** - Detailed deployment guide with troubleshooting
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
