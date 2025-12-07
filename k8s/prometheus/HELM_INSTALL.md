# Prometheus & Grafana Stack Installation

Install the kube-prometheus-stack on your EKS cluster for comprehensive monitoring.

## Installation

### Add Helm Repository

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

### Install kube-prometheus-stack

```bash
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
  --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false \
  --set nodeExporter.enabled=true \
  --set kubeStateMetrics.enabled=true \
  --set grafana.enabled=true \
  --set grafana.adminPassword=admin \
  --set grafana.dashboards.default.enabled=true \
  --set grafana.datasources.datasources.yaml.apiVersion=1 \
  --set prometheus.prometheusSpec.retention=30d \
  --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=50Gi
```

### Custom Values (Alternative)

Create `prometheus-values.yaml`:

```yaml
prometheus:
  prometheusSpec:
    serviceMonitorSelectorNilUsesHelmValues: false
    podMonitorSelectorNilUsesHelmValues: false
    retention: 30d
    storageSpec:
      volumeClaimTemplate:
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 50Gi

nodeExporter:
  enabled: true

kubeStateMetrics:
  enabled: true

grafana:
  enabled: true
  adminPassword: admin
  persistence:
    enabled: true
    size: 10Gi
  dashboards:
    default:
      enabled: true
  datasources:
    datasources.yaml:
      apiVersion: 1
      datasources:
        - name: Prometheus
          type: prometheus
          url: http://prometheus-kube-prometheus-prometheus:9090
          access: proxy
          isDefault: true
```

Install with values file:

```bash
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  -f prometheus-values.yaml
```

## Access Grafana

### Port Forward (Development)

```bash
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```

Access at: http://localhost:3000
- Username: `admin`
- Password: `admin` (or value you set)

### LoadBalancer (Production - AWS)

Update Grafana service type:

```bash
kubectl patch svc prometheus-grafana -n monitoring -p '{"spec":{"type":"LoadBalancer"}}'
```

Get LoadBalancer URL:

```bash
kubectl get svc prometheus-grafana -n monitoring
```

### Ingress (Production)

Create ingress for Grafana:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: grafana-ingress
  namespace: monitoring
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  ingressClassName: nginx
  rules:
  - host: grafana.yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: prometheus-grafana
            port:
              number: 80
  tls:
  - hosts:
    - grafana.yourdomain.com
    secretName: grafana-tls
```

## Access Prometheus

### Port Forward

```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
```

Access at: http://localhost:9090

## Pre-configured Dashboards

The stack includes these dashboards:

- **Kubernetes / Compute Resources / Cluster**
- **Kubernetes / Compute Resources / Namespace (Pods)**
- **Kubernetes / Compute Resources / Node (Pods)**
- **Kubernetes / Networking / Cluster**
- **Node Exporter / Nodes**
- **Prometheus / Overview**

## Monitor Your Application

### ServiceMonitor

Create a ServiceMonitor for your Node.js app:

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: node-app
  namespace: devops-lab
  labels:
    app: node-app
spec:
  selector:
    matchLabels:
      app: node-app
  endpoints:
  - port: http
    path: /metrics
    interval: 30s
```

Apply:

```bash
kubectl apply -f servicemonitor.yaml
```

## Verify Installation

```bash
# Check pods
kubectl get pods -n monitoring

# Check services
kubectl get svc -n monitoring

# Check PVCs
kubectl get pvc -n monitoring
```

## Uninstall

```bash
helm uninstall prometheus -n monitoring
kubectl delete namespace monitoring
```

## Troubleshooting

### Grafana not accessible

```bash
kubectl logs -n monitoring -l app.kubernetes.io/name=grafana
```

### Prometheus not scraping

```bash
kubectl logs -n monitoring -l app.kubernetes.io/name=prometheus
```

### Check ServiceMonitor

```bash
kubectl get servicemonitor -n devops-lab
kubectl describe servicemonitor node-app -n devops-lab
```
