# 🔄 ArgoCD - GitOps Made Simple

## 📋 What Is ArgoCD?

ArgoCD is a tool that automatically keeps your Kubernetes cluster in sync with your Git repository. Think of it as a robot that:
1. **Watches** your GitHub repository for changes
2. **Automatically applies** those changes to your Kubernetes cluster
3. **Makes sure** everything stays exactly as you defined it in Git

**In simple terms:** You push code to GitHub → ArgoCD automatically deploys it to Kubernetes. No manual commands needed!

## 🎯 Why Use GitOps?

| Benefit | What It Means |
|---------|---------------|
| **Git as Source of Truth** | Everything is defined in Git - easy to track and review changes |
| **Automatic Deployment** | Push to Git, and it deploys automatically (no manual kubectl commands) |
| **Easy Rollbacks** | Messed up? Just revert the Git commit and ArgoCD undoes it |
| **Full History** | Every change is tracked in Git with who, what, and when |
| **Better Security** | No need to give everyone access to production - they just push to Git |

## 📁 What's in This Directory?

- **`application.yaml`** - Tells ArgoCD where your code is and how to deploy it
- **`project.yaml`** - Groups multiple applications together (optional)

---

## 🚀 Quick Start

### 1. Install ArgoCD

```bash
# Create ArgoCD namespace
kubectl create namespace argocd

# Install ArgoCD (takes ~2 minutes)
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for it to be ready
kubectl wait --for=condition=available --timeout=300s deployment --all -n argocd
```

### 2. Access ArgoCD UI

```bash
# Create Ingress to access UI at argocd.local
kubectl apply -f ../k8s/argocd-ingress.yaml

# Add to /etc/hosts (Linux/Mac)
echo "127.0.0.1 argocd.local" | sudo tee -a /etc/hosts

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d; echo
```

### 3. Login

Open browser: **http://argocd.local**

- **Username**: `admin`
- **Password**: (from command above)

### 4. Deploy Your Application

```bash
# Tell ArgoCD to manage your app
kubectl apply -f application.yaml

# Watch it deploy automatically
kubectl get application devops-lab-app -n argocd -w
```

That's it! ArgoCD will now automatically deploy any changes you push to Git.

---

## 🔄 How GitOps Works (Step-by-Step Example)

Let's say you want to scale your app from 2 to 5 replicas:

### ❌ Traditional Way (Manual):
```bash
kubectl scale deployment/node-app --replicas=5 -n devops-lab
```
**Problems:** No history, no review, someone might undo it manually

### ✅ GitOps Way (With ArgoCD):
```bash
# 1. Edit the Helm chart
vim ../devops-lab-chart/values.yaml
# Change: replicaCount: 5

# 2. Commit and push to Git
git add values.yaml
git commit -m "Scale to 5 replicas for increased traffic"
git push

# 3. ArgoCD automatically detects change and applies it
# ✅ Done! No kubectl needed
```

**Why is this better?**
- ✅ Change is reviewed in Git (Pull Request)
- ✅ Full history of who changed what and why
- ✅ Easy to rollback (just revert the Git commit)
- ✅ Change is applied consistently across environments

---

## 🌐 Accessing ArgoCD

### Option 1: Via Ingress (Recommended)

```bash
# Already set up in k8s/argocd-ingress.yaml
kubectl apply -f ../k8s/argocd-ingress.yaml

# Add to /etc/hosts
echo "127.0.0.1 argocd.local" | sudo tee -a /etc/hosts

# Visit: http://argocd.local
```

### Option 2: Via Port Forward

```bash
# Forward ArgoCD to localhost:8080
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Visit: https://localhost:8080
```

---

## 📊 Managing Your Application

### View Application Status

```bash
# In the web UI (easiest)
# Visit: http://argocd.local

# Or via command line
kubectl get application devops-lab-app -n argocd
```

### Manually Trigger Sync

ArgoCD syncs automatically every 3 minutes, but you can force it:

```bash
# Force immediate sync
kubectl patch application devops-lab-app -n argocd --type merge \
  -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{}}}'
```

### Update Your Application

1. **Edit Helm values:**
   ```bash
   vim ../devops-lab-chart/values.yaml
   ```

2. **Commit and push:**
   ```bash
   git add devops-lab-chart/values.yaml
   git commit -m "Update configuration"
   git push
   ```

3. **ArgoCD auto-syncs within 3 minutes** (or force sync immediately)

### Rollback to Previous Version

```bash
# Just revert the Git commit
git revert <commit-hash>
git push

# ArgoCD will automatically deploy the previous state
```

---

## 🔒 Application Configuration Explained

The `application.yaml` file tells ArgoCD:

```yaml
# Where is your code?
source:
  repoURL: https://github.com/voynovscloud/devops-lab  # Your GitHub repo
  path: devops-lab-chart                                # Where the Helm chart is
  targetRevision: main                                  # Which branch to watch

# Where to deploy it?
destination:
  server: https://kubernetes.default.svc               # Your cluster
  namespace: devops-lab                                # Which namespace

# How to deploy it?
syncPolicy:
  automated:
    prune: true        # Delete resources if removed from Git
    selfHeal: true     # Undo manual changes people make
  syncOptions:
    - CreateNamespace=true  # Create namespace if it doesn't exist
```

**Key Settings:**
- **`automated`** - Changes deploy automatically (no manual sync needed)
- **`selfHeal`** - If someone manually edits resources, ArgoCD reverts to Git state
- **`prune`** - If you delete something from Git, ArgoCD deletes it from Kubernetes

---

## 🛠️ Using ArgoCD CLI (Optional)

Install the CLI for advanced management:

```bash
# Install ArgoCD CLI
curl -sSL -o /usr/local/bin/argocd \
  https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x /usr/local/bin/argocd

# Login
argocd login argocd.local --username admin

# List applications
argocd app list

# Get application details
argocd app get devops-lab-app

# Manually sync
argocd app sync devops-lab-app

# View logs
argocd app logs devops-lab-app
```

---

## 🚨 Troubleshooting

### Application Won't Sync

```bash
# Check application status
kubectl describe application devops-lab-app -n argocd

# Check ArgoCD logs
kubectl logs -n argocd deployment/argocd-application-controller
```

### Sync Failed

Common issues:
- **Invalid Helm values** - Check your `values.yaml` syntax
- **Missing namespace** - Ensure `CreateNamespace=true` is set
- **Resource conflicts** - Delete manually created resources

### Manual Changes Keep Getting Reverted

This is by design! ArgoCD's `selfHeal` feature reverts manual changes to match Git.

**To make changes permanent:**
1. Update values in Git
2. Commit and push
3. ArgoCD will apply the change

### Reset Admin Password

```bash
# Delete the initial secret
kubectl -n argocd delete secret argocd-initial-admin-secret

# Get new password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

---

## 📊 Application Health & Sync Status

### Health Status

| Status | Meaning |
|--------|---------|
| **Healthy** | All resources deployed and healthy |
| **Progressing** | Sync in progress |
| **Degraded** | Some resources unhealthy |
| **Missing** | Resources not found in cluster |

### Sync Status

| Status | Meaning |
|--------|---------|
| **Synced** | Git matches cluster state |
| **OutOfSync** | Git differs from cluster |
| **Unknown** | Sync status cannot be determined |

---

## 📚 Learn More

- **ArgoCD Documentation**: https://argo-cd.readthedocs.io/
- **GitOps Principles**: https://www.gitops.tech/
- **Helm Charts**: https://helm.sh/docs/

---

## 🎓 Interview Tips

**Q: What is GitOps?**  
A: GitOps is a way of managing infrastructure where Git is the single source of truth. Instead of manually applying changes with kubectl, you push to Git and a tool like ArgoCD automatically deploys the changes. This gives you version control, audit trails, and easy rollbacks.

**Q: Why use ArgoCD instead of kubectl?**  
A: ArgoCD provides:
- Automatic synchronization (no manual deployments)
- Self-healing (undoes manual mistakes)
- Full audit trail in Git
- Easy rollbacks (just revert a commit)
- Better security (no direct cluster access needed)

**Q: How does ArgoCD detect changes?**  
A: ArgoCD polls your Git repository every 3 minutes (configurable). When it detects a difference between Git and the cluster, it automatically syncs the changes if automated sync is enabled.

**Q: What happens if someone manually changes a resource in Kubernetes?**  
A: If `selfHeal` is enabled (which it is in this project), ArgoCD will automatically revert the manual change back to match what's defined in Git. This ensures Git is always the source of truth.
