# DevOps Lab Helm Chart

Production-ready Helm chart for deploying Node.js application with monitoring and observability.

## Features

- ✅ **Flexible Configuration** - Extensive values.yaml for customization
- ✅ **High Availability** - Multiple replicas with rolling updates
- ✅ **Auto-scaling** - HPA support for CPU/Memory based scaling
- ✅ **Health Checks** - Liveness and readiness probes
- ✅ **Monitoring** - Prometheus metrics annotations
- ✅ **Ingress** - Nginx ingress with TLS support
- ✅ **Security** - Non-root containers, security contexts
- ✅ **Resource Management** - CPU/Memory requests and limits

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- Nginx Ingress Controller (if using ingress)

## Installation

### Install from local directory

```bash
# Install with default values
helm install devops-lab ./devops-lab-chart

# Install with custom values
helm install devops-lab ./devops-lab-chart -f custom-values.yaml

# Install in specific namespace
helm install devops-lab ./devops-lab-chart -n devops-lab --create-namespace
```

### Dry-run to see generated manifests

```bash
helm install devops-lab ./devops-lab-chart --dry-run --debug
```

### Template rendering

```bash
# Generate templates without installing
helm template devops-lab ./devops-lab-chart

# Save templates to file
helm template devops-lab ./devops-lab-chart > manifests.yaml
```

## Configuration

The following table lists the configurable parameters and their default values.

### Application Settings

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `3` |
| `image.repository` | Image repository | `devops-lab-nodeapp` |
| `image.tag` | Image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `Never` |

### Service Settings

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `80` |
| `service.targetPort` | Container port | `3000` |

### Ingress Settings

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `true` |
| `ingress.className` | Ingress class name | `nginx` |
| `ingress.hosts[0].host` | Hostname | `app.local` |
| `ingress.tls` | TLS configuration | `[]` |

### Resources

| Parameter | Description | Default |
|-----------|-------------|---------|
| `resources.limits.cpu` | CPU limit | `500m` |
| `resources.limits.memory` | Memory limit | `256Mi` |
| `resources.requests.cpu` | CPU request | `100m` |
| `resources.requests.memory` | Memory request | `128Mi` |

### Autoscaling

| Parameter | Description | Default |
|-----------|-------------|---------|
| `autoscaling.enabled` | Enable HPA | `false` |
| `autoscaling.minReplicas` | Minimum replicas | `2` |
| `autoscaling.maxReplicas` | Maximum replicas | `10` |
| `autoscaling.targetCPUUtilizationPercentage` | Target CPU % | `80` |

### Application Config

| Parameter | Description | Default |
|-----------|-------------|---------|
| `config.nodeEnv` | Node environment | `production` |
| `config.port` | Application port | `3000` |
| `config.logLevel` | Log level | `info` |

## Usage Examples

### Basic Installation

```bash
helm install my-app ./devops-lab-chart
```

### Custom Replica Count

```bash
helm install my-app ./devops-lab-chart --set replicaCount=5
```

### Enable Autoscaling

```bash
helm install my-app ./devops-lab-chart \
  --set autoscaling.enabled=true \
  --set autoscaling.minReplicas=3 \
  --set autoscaling.maxReplicas=20
```

### Custom Image

```bash
helm install my-app ./devops-lab-chart \
  --set image.repository=ghcr.io/voynovscloud/devops-lab-nodeapp \
  --set image.tag=v1.2.3 \
  --set image.pullPolicy=Always
```

### Custom Ingress Host

```bash
helm install my-app ./devops-lab-chart \
  --set ingress.hosts[0].host=myapp.example.com
```

### Different Environment

```bash
helm install my-app ./devops-lab-chart \
  --set config.nodeEnv=staging \
  --set config.logLevel=debug
```

## Upgrade

```bash
# Upgrade with new values
helm upgrade my-app ./devops-lab-chart -f new-values.yaml

# Upgrade single value
helm upgrade my-app ./devops-lab-chart --set replicaCount=10

# Upgrade with reuse of existing values
helm upgrade my-app ./devops-lab-chart --reuse-values
```

## Rollback

```bash
# Rollback to previous release
helm rollback my-app

# Rollback to specific revision
helm rollback my-app 2
```

## Uninstall

```bash
# Uninstall release
helm uninstall my-app

# Uninstall and delete namespace
helm uninstall my-app -n devops-lab
kubectl delete namespace devops-lab
```

## Monitoring

The chart includes Prometheus annotations for automatic metrics scraping:

```yaml
podAnnotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "3000"
  prometheus.io/path: "/metrics"
```

Access metrics:
```bash
kubectl port-forward deployment/my-app 3000:3000
curl http://localhost:3000/metrics
```

## Health Checks

The application includes health endpoints:

- **Liveness**: `GET /health` - Checks if app is alive
- **Readiness**: `GET /health` - Checks if app is ready to serve traffic

## Troubleshooting

### Check pod status

```bash
kubectl get pods -n devops-lab -l app=node-app
```

### View logs

```bash
kubectl logs -n devops-lab -l app=node-app --tail=100 -f
```

### Describe deployment

```bash
kubectl describe deployment -n devops-lab my-app-devops-lab-chart
```

### Check HPA status

```bash
kubectl get hpa -n devops-lab
kubectl describe hpa -n devops-lab
```

### Verify generated manifests

```bash
helm template my-app ./devops-lab-chart --debug
```

### Common Issues

#### ImagePullBackOff
- Check `image.repository` and `image.tag` are correct
- Verify `imagePullSecrets` if using private registry
- Change `image.pullPolicy` if needed

#### Pods not ready
- Check health endpoint is working: `kubectl exec -it <pod> -- wget -q -O- http://localhost:3000/health`
- Increase `initialDelaySeconds` in probes
- Check logs for application errors

#### Ingress not working
- Verify Nginx Ingress Controller is installed: `kubectl get pods -n ingress-nginx`
- Check ingress resource: `kubectl get ingress -n devops-lab`
- Verify DNS/hosts file configuration

## Development

### Lint the chart

```bash
helm lint ./devops-lab-chart
```

### Package the chart

```bash
helm package ./devops-lab-chart
```

### Test the chart

```bash
helm test my-app
```

## Contributing

1. Make changes to templates or values
2. Test with `helm template` and `helm lint`
3. Update Chart.yaml version
4. Commit changes

## License

MIT License - see LICENSE file for details
