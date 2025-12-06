# ArgoCD GitOps Setup

This directory contains ArgoCD Application manifests for GitOps-based deployment.

## What is ArgoCD?

ArgoCD is a declarative, GitOps continuous delivery tool for Kubernetes. It monitors your Git repository and automatically syncs the desired state (Git) with the actual state (Kubernetes cluster).

## Files

- `application.yaml` - Main ArgoCD Application manifest
- `values-dev.yaml` - Development environment overrides (optional)
- `values-prod.yaml` - Production environment overrides (optional)

## Quick Start

### 1. Install ArgoCD

```bash
# Create namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for pods to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s
```

### 2. Access ArgoCD UI

```bash
# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port forward to access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Or use NodePort (if configured)
# Access at: https://<minikube-ip>:30443
```

Login: `admin` / `<password-from-above>`

### 3. Deploy Application with ArgoCD

```bash
# Apply the Application manifest
kubectl apply -f argocd/application.yaml

# Check application status
kubectl get applications -n argocd

# Watch sync status
kubectl get application devops-lab-app -n argocd -w
```

### 4. Access ArgoCD CLI (Optional)

```bash
# Install ArgoCD CLI
curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x /usr/local/bin/argocd

# Login
argocd login <argocd-server>

# List applications
argocd app list

# Get application details
argocd app get devops-lab-app

# Sync manually (if not auto-sync)
argocd app sync devops-lab-app
```

## How It Works

1. **Git as Source of Truth**: All Kubernetes manifests are stored in Git
2. **Continuous Monitoring**: ArgoCD watches the Git repository for changes
3. **Auto-Sync**: When changes are detected, ArgoCD automatically applies them to the cluster
4. **Self-Healing**: If someone manually changes the cluster, ArgoCD reverts it back to Git state
5. **Rollback**: Easy rollback to any previous Git commit

## Workflow

```
Developer → Git Push → ArgoCD Detects Change → Auto-Sync to K8s → Application Updated
```

## Application Configuration

The `application.yaml` includes:

- **Automated Sync**: Changes in Git automatically deployed
- **Self-Healing**: Manual cluster changes reverted
- **Pruning**: Resources deleted when removed from Git
- **Retry Logic**: Automatic retry on failure
- **Namespace Creation**: Auto-creates namespace if not exists

## Managing the Application

### View Application Status

```bash
# Web UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Visit: https://localhost:8080

# CLI
argocd app get devops-lab-app

# Kubectl
kubectl get application devops-lab-app -n argocd -o yaml
```

### Sync Application

```bash
# Auto-sync is enabled, but you can manually trigger:
argocd app sync devops-lab-app

# Or via kubectl
kubectl patch application devops-lab-app -n argocd --type merge -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{}}}'
```

### Rollback

```bash
# Rollback to previous Git commit
argocd app rollback devops-lab-app

# Or just revert the Git commit and ArgoCD will auto-sync
```

### Update Configuration

To update the application, simply:

1. **Update Helm values**:
   ```bash
   # Edit values.yaml
   vim devops-lab-chart/values.yaml
   
   # Commit and push
   git add devops-lab-chart/values.yaml
   git commit -m "Update replica count"
   git push
   ```

2. **ArgoCD automatically syncs** (within ~3 minutes)

3. **Or manually sync**:
   ```bash
   argocd app sync devops-lab-app
   ```

## Multi-Environment Setup

### Development Environment

```yaml
# argocd/application-dev.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: devops-lab-dev
  namespace: argocd
spec:
  source:
    path: devops-lab-chart
    helm:
      valueFiles:
        - values.yaml
        - values-dev.yaml
  destination:
    namespace: devops-lab-dev
```

### Production Environment

```yaml
# argocd/application-prod.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: devops-lab-prod
  namespace: argocd
spec:
  source:
    path: devops-lab-chart
    helm:
      valueFiles:
        - values.yaml
        - values-prod.yaml
  destination:
    namespace: devops-lab-prod
```

## Best Practices

1. **Branch Strategy**: Use branches for environments (main → prod, develop → dev)
2. **PR Workflow**: Require PR approval before merging to main
3. **Secrets**: Use Sealed Secrets or External Secrets Operator
4. **Health Checks**: Configure proper health checks in application
5. **Notifications**: Set up Slack/Email notifications for sync failures
6. **RBAC**: Configure proper access control in ArgoCD

## Troubleshooting

### Application Not Syncing

```bash
# Check application status
argocd app get devops-lab-app

# View sync errors
kubectl describe application devops-lab-app -n argocd

# Check ArgoCD logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller
```

### Authentication Issues

```bash
# Reset admin password
kubectl -n argocd patch secret argocd-secret -p '{"stringData": {"admin.password": ""}}'
kubectl -n argocd delete pod -l app.kubernetes.io/name=argocd-server
```

### Sync Stuck

```bash
# Force sync
argocd app sync devops-lab-app --force

# Terminate operation
argocd app terminate-op devops-lab-app
```

## Monitoring

### Health Status

- **Healthy**: All resources deployed and healthy
- **Progressing**: Sync in progress
- **Degraded**: Some resources unhealthy
- **Suspended**: Auto-sync disabled
- **Missing**: Resources not found in cluster
- **Unknown**: Health status unknown

### Sync Status

- **Synced**: Git matches cluster state
- **OutOfSync**: Git differs from cluster
- **Unknown**: Sync status unknown

## Advanced Features

### Sync Waves

Control the order of resource creation:

```yaml
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "1"  # Deploy first
```

### Sync Hooks

Run jobs before/after sync:

```yaml
metadata:
  annotations:
    argocd.argoproj.io/hook: PreSync
    argocd.argoproj.io/hook-delete-policy: HookSucceeded
```

### Resource Exclusions

Ignore certain resources:

```yaml
spec:
  ignoreDifferences:
    - group: apps
      kind: Deployment
      jsonPointers:
        - /spec/replicas  # Ignore HPA-managed replicas
```

## Resources

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Getting Started Guide](https://argo-cd.readthedocs.io/en/stable/getting_started/)
- [Best Practices](https://argo-cd.readthedocs.io/en/stable/user-guide/best_practices/)
