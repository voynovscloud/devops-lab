# ArgoCD Quick Start Guide

## 🚀 Installation Complete!

ArgoCD has been successfully installed and configured for GitOps deployment.

## 📍 Access ArgoCD UI

### Method 1: NodePort (Recommended)

```bash
# Get access URL
echo "ArgoCD UI: https://$(minikube ip):30443"

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

**Login Credentials:**
- Username: `admin`
- Password: (from command above)

### Method 2: Port Forward

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Access at: https://localhost:8080
```

## 🎯 Deploy Your Application

### Option 1: Using kubectl

```bash
# Deploy the Application
kubectl apply -f argocd/application.yaml

# Check status
kubectl get application devops-lab-app -n argocd

# Watch sync progress
kubectl get application devops-lab-app -n argocd -w
```

### Option 2: Using ArgoCD UI

1. **Login** to ArgoCD UI
2. Click **"+ NEW APP"**
3. Fill in details:
   - **Application Name**: devops-lab-app
   - **Project**: default
   - **Sync Policy**: Automatic
   - **Repository URL**: https://github.com/voynovscloud/devops-lab.git
   - **Path**: devops-lab-chart
   - **Cluster**: https://kubernetes.default.svc
   - **Namespace**: devops-lab
4. Click **"CREATE"**

### Option 3: Using ArgoCD CLI

```bash
# Install ArgoCD CLI
curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x /usr/local/bin/argocd

# Login
argocd login $(minikube ip):30443

# Create application
argocd app create devops-lab-app \
  --repo https://github.com/voynovscloud/devops-lab.git \
  --path devops-lab-chart \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace devops-lab \
  --sync-policy automated \
  --auto-prune \
  --self-heal

# Sync application
argocd app sync devops-lab-app
```

## 🔄 GitOps Workflow

### Make Changes

```bash
# Edit Helm values
vim devops-lab-chart/values.yaml

# For example, change replicas:
# replicaCount: 5

# Commit and push
git add devops-lab-chart/values.yaml
git commit -m "Scale to 5 replicas"
git push origin main
```

### ArgoCD Auto-Syncs!

- **Detection**: ArgoCD checks Git every 3 minutes
- **Sync**: Automatically applies changes to cluster
- **Notification**: Shows sync status in UI
- **Self-Heal**: Reverts manual cluster changes

## 📊 Monitor Application

### Check Application Status

```bash
# Via kubectl
kubectl get application devops-lab-app -n argocd

# Via ArgoCD CLI
argocd app get devops-lab-app

# Check pods
kubectl get pods -n devops-lab
```

### View in UI

1. Open ArgoCD UI
2. Click on **"devops-lab-app"**
3. See visual representation of all resources
4. Check sync status and health

## 🛠️ Common Commands

### Application Management

```bash
# Get app details
argocd app get devops-lab-app

# Sync manually
argocd app sync devops-lab-app

# View sync history
argocd app history devops-lab-app

# Rollback to previous version
argocd app rollback devops-lab-app

# Delete application
argocd app delete devops-lab-app
```

### Troubleshooting

```bash
# Check ArgoCD pods
kubectl get pods -n argocd

# View application events
kubectl describe application devops-lab-app -n argocd

# Check ArgoCD logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller

# Restart ArgoCD server
kubectl rollout restart deployment argocd-server -n argocd
```

## 🎓 What You've Achieved

✅ **GitOps Ready**: Automated deployments from Git  
✅ **Continuous Delivery**: Changes automatically synced  
✅ **Self-Healing**: Cluster state matches Git  
✅ **Rollback Capable**: Easy revert to any commit  
✅ **Drift Detection**: Visual representation of changes  
✅ **Production Grade**: Enterprise-level deployment workflow  

## 📚 Next Steps

1. **Access ArgoCD UI** and explore the interface
2. **Deploy the application** using one of the methods above
3. **Make a change** to `values.yaml` and watch auto-sync
4. **Try manual sync** and rollback operations
5. **Set up notifications** (Slack, email) for sync events
6. **Add more applications** (Prometheus, Grafana) to ArgoCD

## 🔗 Resources

- **ArgoCD Docs**: https://argo-cd.readthedocs.io/
- **ArgoCD README**: See `argocd/README.md` for detailed guide
- **Helm Chart**: See `devops-lab-chart/README.md` for configuration options

---

**You now have a complete GitOps pipeline! 🎉**

Push to Git → ArgoCD Syncs → Application Updated → Profit! 🚀
