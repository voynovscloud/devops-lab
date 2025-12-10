# 📦 DevOps Lab Helm Chart

## 📋 What Is Helm?

Helm is like a "package manager" for Kubernetes - similar to how apt/yum installs software on Linux. Instead of writing multiple YAML files and running kubectl commands one by one, Helm lets you:

1. **Package** your entire application into a "chart"
2. **Customize** it with variables (no need to edit YAML directly)
3. **Deploy** everything with a single command
4. **Upgrade** or **rollback** easily

**Example:** Instead of running 10 kubectl commands, you run: `helm install myapp`

## 🎯 Why Use Helm Charts?

| Benefit | What It Means |
|---------|---------------|
| **Reusability** | Same chart for dev, staging, and production - just change values |
| **Easy Upgrades** | Update app version with one command |
| **Simple Rollbacks** | Undo mistakes with `helm rollback` |
| **Templating** | One YAML template generates different configs per environment |
| **Versioning** | Track chart versions like app versions |

## ✨ What This Chart Includes

This Helm chart deploys a production-ready Node.js application with:

- ✅ **High Availability** - Multiple replicas with automatic failover
- ✅ **Auto-scaling** - Automatically scales based on CPU/memory usage
- ✅ **Health Checks** - Kubernetes restarts unhealthy pods
- ✅ **Monitoring** - Prometheus metrics built-in
- ✅ **Database Support** - PostgreSQL integration ready
- ✅ **Ingress** - External access via HTTP/HTTPS
- ✅ **Security** - Non-root containers, security policies
- ✅ **Resource Limits** - Prevents pods from consuming too many resources

---

## 🚀 Quick Start

### Prerequisites

- Kubernetes cluster (Minikube, kind, or cloud provider)
- Helm 3 installed: `brew install helm` or `snap install helm`
- kubectl configured to your cluster

### Install the Chart

```bash
# Basic installation (uses default values)
helm install devops-lab ./devops-lab-chart

# Install in specific namespace
helm install devops-lab ./devops-lab-chart \
  --namespace devops-lab \
  --create-namespace

# Install with custom values
helm install devops-lab ./devops-lab-chart \
  --set replicaCount=5 \
  --set image.tag=v1.2.3
```

### Check Installation

```bash
# List installed charts
helm list

# Check deployment status
kubectl get pods -n devops-lab

# View release details
helm status devops-lab
```

### Preview Before Installing (Dry Run)

```bash
# See what will be deployed without actually deploying
helm install devops-lab ./devops-lab-chart --dry-run --debug
```

---

## ⚙️ Common Customizations

### Change Number of Replicas

```bash
# Deploy 5 copies of your app
helm install devops-lab ./devops-lab-chart --set replicaCount=5
```

### Use Different Docker Image

```bash
# Use specific version from GitHub Container Registry
helm install devops-lab ./devops-lab-chart \
  --set image.repository=ghcr.io/voynovscloud/devops-lab-nodeapp \
  --set image.tag=v1.2.3 \
  --set image.pullPolicy=Always
```

### Enable Auto-Scaling

```bash
# Automatically scale between 3-20 replicas based on CPU usage
helm install devops-lab ./devops-lab-chart \
  --set autoscaling.enabled=true \
  --set autoscaling.minReplicas=3 \
  --set autoscaling.maxReplicas=20 \
  --set autoscaling.targetCPUUtilizationPercentage=70
```

### Custom Domain Name

```bash
# Access app at myapp.example.com
helm install devops-lab ./devops-lab-chart \
  --set ingress.hosts[0].host=myapp.example.com
```

### Deploy with PostgreSQL Database

```bash
# Connect to external PostgreSQL database
helm install devops-lab ./devops-lab-chart \
  --set database.enabled=true \
  --set database.host=postgres.example.com \
  --set database.name=myapp \
  --set database.user=appuser \
  --set database.password=SecurePass123
```

### Different Environment (Dev/Staging/Prod)

```bash
# Development environment with debug logging
helm install devops-lab ./devops-lab-chart \
  --set config.nodeEnv=development \
  --set config.logLevel=debug \
  --set replicaCount=1

# Production environment
helm install devops-lab ./devops-lab-chart \
  --set config.nodeEnv=production \
  --set config.logLevel=info \
  --set replicaCount=3
```

---

## 🔄 Managing Your Deployment

### Upgrade (Update Configuration)

```bash
# Upgrade with new values
helm upgrade devops-lab ./devops-lab-chart \
  --set replicaCount=10

# Upgrade using values file
helm upgrade devops-lab ./devops-lab-chart \
  -f production-values.yaml

# Reuse existing values and only change what you specify
helm upgrade devops-lab ./devops-lab-chart \
  --reuse-values \
  --set image.tag=v2.0.0
```

### Rollback (Undo Mistakes)

```bash
# View deployment history
helm history devops-lab

# Rollback to previous version
helm rollback devops-lab

# Rollback to specific version
helm rollback devops-lab 3
```

### Uninstall (Remove Everything)

```bash
# Remove the deployment
helm uninstall devops-lab

# Remove from specific namespace
helm uninstall devops-lab --namespace devops-lab
```

---

## 🧪 Testing Your Deployment

### Access the Application

```bash
# Port forward to test locally
kubectl port-forward svc/devops-lab -n devops-lab 3000:80

# Test in browser or curl
curl http://localhost:3000
```

### View Prometheus Metrics

```bash
# Same port forward as above, then:
curl http://localhost:3000/metrics
```

### Check Health Status

```bash
# Liveness and readiness endpoint
curl http://localhost:3000/health
```

---

## 🚨 Troubleshooting

### Pods Won't Start

```bash
# Check pod status
kubectl get pods -n devops-lab

# View logs to see errors
kubectl logs -n devops-lab -l app.kubernetes.io/name=devops-lab-chart --tail=100 -f

# Describe pod for detailed info
kubectl describe pod <pod-name> -n devops-lab
```

### Common Issues

| Problem | Solution |
|---------|----------|
| **ImagePullBackOff** | Check `image.repository` and `image.tag` are correct. For local images, use `imagePullPolicy: Never` |
| **Pods Not Ready** | Check logs with `kubectl logs`. Health endpoint might be failing. |
| **Ingress Not Working** | Verify Nginx Ingress Controller is installed: `kubectl get pods -n ingress-nginx` |
| **Out of Resources** | Increase resource limits or add more nodes to cluster |

### Check Auto-Scaling Status

```bash
# View HPA (Horizontal Pod Autoscaler)
kubectl get hpa -n devops-lab

# Detailed HPA info
kubectl describe hpa -n devops-lab
```

### Verify Generated Manifests

```bash
# See exactly what Helm will deploy
helm template devops-lab ./devops-lab-chart --debug
```

---

## 📊 Configuration Reference

### Key Parameters

| Parameter | What It Does | Default | When to Change |
|-----------|--------------|---------|----------------|
| `replicaCount` | Number of app copies | `3` | More users = more replicas |
| `image.tag` | Docker image version | `latest` | Deploy specific version |
| `autoscaling.enabled` | Enable auto-scaling | `false` | Enable for production |
| `resources.limits.cpu` | Max CPU per pod | `500m` | App uses more CPU |
| `resources.limits.memory` | Max memory per pod | `256Mi` | App uses more memory |
| `ingress.hosts[0].host` | Domain name | `app.local` | Your actual domain |
| `database.enabled` | Connect to database | `false` | Enable if using PostgreSQL |

**See `values.yaml` for all 100+ configurable parameters.**

---

## 🎓 Interview Tips

**Q: What is Helm?**  
A: Helm is a package manager for Kubernetes. It lets you define, install, and upgrade Kubernetes applications using "charts" (packaged configurations). Instead of managing dozens of YAML files, you have one chart with customizable values.

**Q: What's the difference between Helm and kubectl?**  
A: kubectl is low-level - you apply individual YAML files. Helm is high-level - you install entire applications with one command. Helm also handles upgrades, rollbacks, and versioning.

**Q: Why use Helm charts instead of plain YAML?**  
A: 
- **Reusability**: Same chart for multiple environments
- **Templating**: Generate configs dynamically based on values
- **Versioning**: Track changes like application versions
- **Easy rollbacks**: `helm rollback` undoes mistakes
- **Dependency management**: Charts can depend on other charts

**Q: How do you upgrade an application deployed with Helm?**  
A: Use `helm upgrade <release-name> <chart> --set key=value`. Helm will only update what changed, keeping existing values.

---

## 📚 Learn More

- **Helm Documentation**: https://helm.sh/docs/
- **Chart Best Practices**: https://helm.sh/docs/chart_best_practices/
- **This Chart's Values**: See `values.yaml` for all configuration options
