# Kubernetes Manifests

Complete Kubernetes deployment for the DevOps Lab stack.

## Structure

```
k8s/
├── node-app/          # Node.js application
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
├── prometheus/        # Monitoring with Prometheus
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── pvc.yaml
│   └── rbac.yaml
├── grafana/          # Visualization with Grafana
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── pvc.yaml
│   ├── configmap.yaml
│   └── secret.yaml
└── jenkins/          # CI/CD with Jenkins
    ├── namespace.yaml
    ├── deployment.yaml
    ├── service.yaml
    ├── pvc.yaml
    └── rbac.yaml
```

## Prerequisites

- Kubernetes cluster (K3s, K8s, EKS, GKE, AKS)
- kubectl configured
- Storage provisioner (default StorageClass)
- (Optional) Nginx Ingress Controller for Ingress resources

## Quick Deploy

### Deploy Everything

```bash
# Deploy all services
kubectl apply -f k8s/node-app/
kubectl apply -f k8s/prometheus/
kubectl apply -f k8s/grafana/
kubectl apply -f k8s/jenkins/
```

### Deploy Individual Services

**Node App:**
```bash
kubectl apply -f k8s/node-app/
kubectl get pods -n devops-lab
kubectl port-forward -n devops-lab svc/node-app 8080:80
# Visit http://localhost:8080
```

**Prometheus:**
```bash
kubectl apply -f k8s/prometheus/
kubectl get pods -n monitoring
kubectl port-forward -n monitoring svc/prometheus 9090:9090
# Visit http://localhost:9090
```

**Grafana:**
```bash
kubectl apply -f k8s/grafana/
kubectl get pods -n monitoring
kubectl port-forward -n monitoring svc/grafana 3000:3000
# Visit http://localhost:3000 (admin/admin)
```

**Jenkins:**
```bash
kubectl apply -f k8s/jenkins/
kubectl get pods -n jenkins
kubectl port-forward -n jenkins svc/jenkins 8080:8080
# Visit http://localhost:8080
```

## Configuration

### Node App

**Environment Variables** (edit `k8s/node-app/configmap.yaml`):
- `NODE_ENV`: production/development
- `PORT`: 3000 (default)
- `LOG_LEVEL`: info/debug/error

**Image**: Update in `k8s/node-app/deployment.yaml`:
```yaml
image: ghcr.io/voynovscloud/devops-lab-nodeapp:latest
```

**Ingress** (edit `k8s/node-app/ingress.yaml`):
- Change `devops-lab.example.com` to your domain
- Requires Nginx Ingress Controller and cert-manager

### Grafana

**Change Default Password** (edit `k8s/grafana/secret.yaml`):
```yaml
stringData:
  password: "your-secure-password"
```

**Datasource**: Prometheus is pre-configured at `http://prometheus:9090`

### Jenkins

**Persistent Storage**: 20Gi by default (edit `k8s/jenkins/pvc.yaml`)

**Docker Socket**: Mounted from host for Docker-in-Docker builds
- May need adjustment based on cluster setup

### Prometheus

**Scrape Configuration**: Edit `k8s/prometheus/configmap.yaml`

**Auto-discovery**: Configured to scrape pods in `devops-lab` namespace with annotation:
```yaml
annotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "3000"
  prometheus.io/path: "/metrics"
```

## Resource Requirements

**Node App:**
- Requests: 128Mi RAM, 100m CPU
- Limits: 256Mi RAM, 500m CPU
- Replicas: 3 (adjust as needed)

**Prometheus:**
- Requests: 512Mi RAM, 250m CPU
- Limits: 1Gi RAM, 1000m CPU
- Storage: 10Gi

**Grafana:**
- Requests: 256Mi RAM, 100m CPU
- Limits: 512Mi RAM, 500m CPU
- Storage: 5Gi

**Jenkins:**
- Requests: 1Gi RAM, 500m CPU
- Limits: 2Gi RAM, 2000m CPU
- Storage: 20Gi

## Health Checks

All services include:
- **Liveness probes**: Restart if unhealthy
- **Readiness probes**: Remove from load balancer if not ready

## Security

**Node App:**
- Runs as non-root user (UID 1000)
- No privilege escalation
- Security context enforced

**RBAC:**
- Prometheus: ClusterRole for service discovery
- Jenkins: ClusterRole for deployment updates

**Secrets:**
- Grafana password in Secret (change before production!)
- Add image pull secrets if using private registries

## Scaling

**Manual Scaling:**
```bash
kubectl scale deployment/node-app --replicas=5 -n devops-lab
```

**Auto-scaling (HPA):**
```bash
kubectl autoscale deployment node-app --cpu-percent=80 --min=3 --max=10 -n devops-lab
```

## Monitoring

**Check Status:**
```bash
kubectl get all -n devops-lab
kubectl get all -n monitoring
kubectl get all -n jenkins
```

**View Logs:**
```bash
kubectl logs -f deployment/node-app -n devops-lab
kubectl logs -f deployment/prometheus -n monitoring
kubectl logs -f deployment/grafana -n monitoring
kubectl logs -f deployment/jenkins -n jenkins
```

**Describe Resources:**
```bash
kubectl describe pod <pod-name> -n <namespace>
```

## Troubleshooting

**Pod not starting:**
```bash
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>
```

**PVC pending:**
- Check if StorageClass exists: `kubectl get sc`
- Verify storage provisioner is running

**Image pull errors:**
- Add image pull secret if using private registry
- Verify image name and tag

**Service not accessible:**
```bash
kubectl get svc -n <namespace>
kubectl get endpoints -n <namespace>
```

## Cleanup

**Delete specific service:**
```bash
kubectl delete -f k8s/node-app/
kubectl delete -f k8s/prometheus/
kubectl delete -f k8s/grafana/
kubectl delete -f k8s/jenkins/
```

**Delete all:**
```bash
kubectl delete namespace devops-lab
kubectl delete namespace monitoring
kubectl delete namespace jenkins
```

## Production Considerations

1. **Ingress**: Set up proper domain and TLS certificates
2. **Secrets**: Use external secret management (Vault, Sealed Secrets)
3. **Storage**: Use proper storage classes with backups
4. **Monitoring**: Set up alerting rules in Prometheus
5. **Backups**: Regular backups of PVCs (especially Jenkins)
6. **Resource limits**: Adjust based on actual usage
7. **Security**: Network policies, Pod Security Standards
8. **High Availability**: Multiple replicas, anti-affinity rules

## Next Steps

1. Deploy to your Kubernetes cluster
2. Configure domain names for Ingress
3. Set up SSL certificates (cert-manager + Let's Encrypt)
4. Configure Grafana dashboards
5. Set up Jenkins pipeline to deploy to K8s
6. Add monitoring alerts
7. Implement GitOps with ArgoCD or Flux
