# DevOps Lab - Deployment Summary

## ✅ Successfully Deployed on Minikube

**Date:** December 6, 2025  
**Cluster:** Minikube (4 CPUs, 8GB RAM, 20GB disk)

---

## 📊 Current Status

### Pods (All Running ✅)
```
NAMESPACE     POD                      READY   STATUS
devops-lab    node-app-85ccf55454-*    3/3     Running
jenkins       jenkins-684cb56d4-*      1/1     Running
monitoring    grafana-65cf9c68fd-*     1/1     Running
monitoring    prometheus-6889695b7f-*  1/1     Running
```

### Services
```
NAMESPACE     SERVICE      PORT(S)
devops-lab    node-app     80
jenkins       jenkins      8080, 50000
monitoring    grafana      3000
monitoring    prometheus   9090
```

### Persistent Storage
```
NAMESPACE    PVC                  SIZE    STATUS
jenkins      jenkins-home         20Gi    Bound
monitoring   grafana-storage      5Gi     Bound
monitoring   prometheus-storage   10Gi    Bound
```

---

## 🌐 Access Your Services

### 1. Node.js Application
```bash
kubectl port-forward -n devops-lab svc/node-app 8080:80
```
Access at: http://localhost:8080

### 2. Jenkins CI/CD
```bash
kubectl port-forward -n jenkins svc/jenkins 8081:8080
```
Access at: http://localhost:8081

**Get admin password:**
```bash
kubectl exec -n jenkins deployment/jenkins -- cat /var/jenkins_home/secrets/initialAdminPassword
```

### 3. Grafana
```bash
kubectl port-forward -n monitoring svc/grafana 3000:3000
```
Access at: http://localhost:3000  
**Credentials:** admin / admin

### 4. Prometheus
```bash
kubectl port-forward -n monitoring svc/prometheus 9090:9090
```
Access at: http://localhost:9090

---

## 🔧 Useful Commands

### Check Pod Status
```bash
# All pods
minikube kubectl -- get pods -A

# Specific namespace
minikube kubectl -- get pods -n devops-lab
minikube kubectl -- get pods -n jenkins
minikube kubectl -- get pods -n monitoring
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

### Check Overall Status
```bash
# Run the status check script
./check-status.sh
```

### Restart Services
```bash
# Restart specific deployment
kubectl rollout restart deployment/node-app -n devops-lab
kubectl rollout restart deployment/jenkins -n jenkins
kubectl rollout restart deployment/grafana -n monitoring
kubectl rollout restart deployment/prometheus -n monitoring
```

### Scale Node App
```bash
# Scale to 5 replicas
kubectl scale deployment/node-app -n devops-lab --replicas=5

# Check status
kubectl get pods -n devops-lab
```

---

## 📝 Important Notes

1. **Node App Image:** Currently using local image (`devops-lab-nodeapp:latest`) with `imagePullPolicy: Never`
   - Image is built locally and loaded into Minikube
   - To update: rebuild image, load into Minikube, restart deployment

2. **Grafana Configuration:**
   - Pre-configured with Prometheus datasource
   - Runs with elevated permissions for PVC access
   - Data persists in grafana-storage PVC

3. **Prometheus Configuration:**
   - Auto-discovers pods in `devops-lab` namespace
   - Scrapes metrics from pods with proper annotations
   - Data persists in prometheus-storage PVC

4. **Jenkins Configuration:**
   - Has full Kubernetes API access (ClusterRole)
   - Docker socket mounted for building images
   - Jenkins home persists in jenkins-home PVC

---

## 🚀 Next Steps

### 1. Push Image to GHCR (Optional)
To use the container registry instead of local images:

```bash
# Build and tag
docker build -t ghcr.io/voynovscloud/devops-lab-nodeapp:latest ./my-node-app/

# Login to GHCR
echo $GITHUB_TOKEN | docker login ghcr.io -u voynovscloud --password-stdin

# Push
docker push ghcr.io/voynovscloud/devops-lab-nodeapp:latest

# Update deployment to use GHCR image
# Change imagePullPolicy back to Always in k8s/node-app/deployment.yaml
```

### 2. Configure Jenkins GHCR Credentials
1. Get GitHub Personal Access Token with `write:packages` scope
2. Add credentials in Jenkins:
   - Go to: Manage Jenkins → Credentials
   - Add new Secret Text
   - ID: `ghcr-credentials`
   - Secret: Your GitHub token

### 3. Set Up GitHub Webhook (Optional)
For automatic builds on git push:
1. Expose Jenkins publicly or use ngrok
2. Add webhook in GitHub repo settings
3. URL: `http://YOUR_JENKINS_URL/github-webhook/`

### 4. Configure Grafana Dashboards
1. Access Grafana at http://localhost:3000
2. Login with admin/admin
3. Prometheus datasource already configured
4. Import dashboards for:
   - Node.js application metrics
   - Kubernetes cluster metrics
   - Jenkins build metrics

---

## 🛠️ Troubleshooting

### Minikube Not Starting
```bash
minikube delete
minikube start --cpus=4 --memory=8192 --disk-size=20g
```

### Pods in CrashLoopBackOff
```bash
# Check logs
kubectl logs <pod-name> -n <namespace>

# Describe pod for events
kubectl describe pod <pod-name> -n <namespace>
```

### PVC Issues
```bash
# Check PVC status
kubectl get pvc -A

# Check PV
kubectl get pv
```

### Image Pull Issues
If switching back to GHCR and images fail to pull:
```bash
# Make sure image exists
docker pull ghcr.io/voynovscloud/devops-lab-nodeapp:latest

# Check if repo is public or add imagePullSecrets
```

---

## 📊 Scripts Reference

### `deploy-k8s.sh`
Full deployment script that:
- Detects and starts Minikube/K3s
- Applies all manifests
- Fixes Grafana permissions
- Waits for all pods to be ready
- Provides comprehensive status report

### `check-status.sh`
Quick status check showing:
- Cluster status
- All pods
- All services
- All PVCs
- All deployments

### `fix-nodeapp.sh`
Rebuilds and deploys node app:
- Builds Docker image
- Loads into Minikube
- Applies deployment
- Checks pod status

---

## ✨ Success Summary

Your DevOps lab is now fully operational with:
- ✅ Multi-replica Node.js application
- ✅ Jenkins CI/CD server with K8s integration
- ✅ Prometheus metrics collection
- ✅ Grafana visualization
- ✅ Persistent storage for all services
- ✅ All pods running healthy
- ✅ Professional repository structure
- ✅ Ready for GitHub presentation

**Great work!** 🎉
