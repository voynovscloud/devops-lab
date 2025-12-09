# 🔔 Alerting Setup Guide

This guide explains how to configure alerting for your DevOps Lab application using Prometheus Alertmanager.

## Table of Contents
- [Quick Start](#quick-start)
- [Slack Integration](#slack-integration)
- [Email Integration](#email-integration)
- [PagerDuty Integration](#pagerduty-integration)
- [Testing Alerts](#testing-alerts)

---

## Quick Start

### 1. Install Alertmanager

```bash
# Create Alertmanager configuration
kubectl apply -f k8s/prometheus/alertmanager-config.yaml

# Deploy Alertmanager
kubectl apply -f k8s/prometheus/alertmanager-deployment.yaml
kubectl apply -f k8s/prometheus/alertmanager-service.yaml

# Verify deployment
kubectl get pods -n monitoring -l app=alertmanager
```

### 2. Configure Prometheus to use Alertmanager

Update Prometheus ConfigMap to include Alertmanager:

```yaml
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      - alertmanager-service:9093
```

Apply alerts:

```bash
kubectl apply -f k8s/prometheus/alerts.yaml
kubectl rollout restart deployment prometheus -n monitoring
```

---

## Slack Integration

### Step 1: Create Slack Webhook

1. Go to https://api.slack.com/apps
2. Click "Create New App" → "From scratch"
3. Name: "Prometheus Alerts"
4. Select your workspace
5. Navigate to "Incoming Webhooks"
6. Activate Incoming Webhooks
7. Click "Add New Webhook to Workspace"
8. Select channel (e.g., #alerts)
9. Copy the Webhook URL

### Step 2: Create Alertmanager Secret

```bash
# Create secret with Slack webhook URL
kubectl create secret generic alertmanager-slack \
  --from-literal=webhook-url='https://hooks.slack.com/services/YOUR/WEBHOOK/URL' \
  -n monitoring
```

### Step 3: Configure Alertmanager for Slack

Create `alertmanager-config.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: alertmanager-config
  namespace: monitoring
data:
  alertmanager.yml: |
    global:
      resolve_timeout: 5m
      slack_api_url: '<YOUR_SLACK_WEBHOOK_URL>'

    route:
      group_by: ['alertname', 'cluster', 'service']
      group_wait: 10s
      group_interval: 10s
      repeat_interval: 12h
      receiver: 'slack-notifications'
      
      routes:
      - match:
          severity: critical
        receiver: 'slack-critical'
        
      - match:
          severity: warning
        receiver: 'slack-warnings'

    receivers:
    - name: 'slack-notifications'
      slack_configs:
      - channel: '#alerts'
        title: '{{ .GroupLabels.alertname }}'
        text: >-
          *Alert:* {{ .GroupLabels.alertname }}
          *Summary:* {{ .CommonAnnotations.summary }}
          *Description:* {{ .CommonAnnotations.description }}
          *Severity:* {{ .CommonLabels.severity }}
        send_resolved: true
        
    - name: 'slack-critical'
      slack_configs:
      - channel: '#critical-alerts'
        title: '🚨 CRITICAL: {{ .GroupLabels.alertname }}'
        text: >-
          *Alert:* {{ .GroupLabels.alertname }}
          *Summary:* {{ .CommonAnnotations.summary }}
          *Description:* {{ .CommonAnnotations.description }}
          *Severity:* {{ .CommonLabels.severity }}
        color: 'danger'
        send_resolved: true
        
    - name: 'slack-warnings'
      slack_configs:
      - channel: '#warning-alerts'
        title: '⚠️ WARNING: {{ .GroupLabels.alertname }}'
        text: >-
          *Alert:* {{ .GroupLabels.alertname }}
          *Summary:* {{ .CommonAnnotations.summary }}
          *Description:* {{ .CommonAnnotations.description }}
        color: 'warning'
        send_resolved: true
```

Apply configuration:

```bash
kubectl apply -f alertmanager-config.yaml
kubectl rollout restart deployment alertmanager -n monitoring
```

---

## Email Integration

### Step 1: Configure SMTP Settings

Create Alertmanager configuration with email:

```yaml
global:
  resolve_timeout: 5m
  smtp_smarthost: 'smtp.gmail.com:587'
  smtp_from: 'alerts@yourcompany.com'
  smtp_auth_username: 'your-email@gmail.com'
  smtp_auth_password: 'your-app-password'
  smtp_require_tls: true

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 12h
  receiver: 'email-notifications'

receivers:
- name: 'email-notifications'
  email_configs:
  - to: 'team@yourcompany.com'
    headers:
      Subject: '[{{ .Status }}] {{ .GroupLabels.alertname }}'
    html: |
      <h2>Alert: {{ .GroupLabels.alertname }}</h2>
      <p><strong>Summary:</strong> {{ .CommonAnnotations.summary }}</p>
      <p><strong>Description:</strong> {{ .CommonAnnotations.description }}</p>
      <p><strong>Severity:</strong> {{ .CommonLabels.severity }}</p>
      <p><strong>Status:</strong> {{ .Status }}</p>
```

### Step 2: For Gmail - Create App Password

1. Go to Google Account → Security
2. Enable 2-Step Verification
3. Go to App Passwords
4. Generate password for "Mail"
5. Use this password in the configuration

### Step 3: Create Secret for SMTP Credentials

```bash
kubectl create secret generic alertmanager-smtp \
  --from-literal=username='your-email@gmail.com' \
  --from-literal=password='your-app-password' \
  -n monitoring
```

---

## PagerDuty Integration

### Step 1: Create PagerDuty Integration

1. Go to PagerDuty → Services
2. Create new service or select existing
3. Add "Prometheus" integration
4. Copy the Integration Key

### Step 2: Configure Alertmanager

```yaml
global:
  resolve_timeout: 5m

route:
  receiver: 'pagerduty-notifications'
  routes:
  - match:
      severity: critical
    receiver: 'pagerduty-critical'

receivers:
- name: 'pagerduty-notifications'
  pagerduty_configs:
  - service_key: 'YOUR_PAGERDUTY_INTEGRATION_KEY'
    description: '{{ .GroupLabels.alertname }}: {{ .CommonAnnotations.summary }}'
    
- name: 'pagerduty-critical'
  pagerduty_configs:
  - service_key: 'YOUR_PAGERDUTY_INTEGRATION_KEY'
    severity: 'critical'
    description: '{{ .GroupLabels.alertname }}: {{ .CommonAnnotations.summary }}'
```

---

## Testing Alerts

### Test 1: Trigger High CPU Alert

Generate load to trigger CPU alert:

```bash
# Run load test
./scripts/load-test.sh

# Watch alerts firing
kubectl port-forward svc/prometheus-service 9090:9090 -n monitoring
# Open: http://localhost:9090/alerts
```

### Test 2: Simulate Pod Failure

```bash
# Delete a pod to trigger PodDown alert
kubectl delete pod -n production -l app=my-node-app --force

# Watch for alert
kubectl logs -n monitoring -l app=alertmanager -f
```

### Test 3: Test Alertmanager Configuration

```bash
# Check Alertmanager status
kubectl port-forward svc/alertmanager-service 9093:9093 -n monitoring

# Open: http://localhost:9093
# Verify configuration under "Status"

# Send test alert
curl -X POST http://localhost:9093/api/v1/alerts -d '[{
  "labels": {
    "alertname": "TestAlert",
    "severity": "warning"
  },
  "annotations": {
    "summary": "Test alert from Alertmanager",
    "description": "This is a test alert to verify notification channels"
  }
}]'
```

---

## Alert Rules Reference

### Available Alerts

| Alert Name | Severity | Trigger | Description |
|------------|----------|---------|-------------|
| `PodDown` | Critical | Pod down for 2+ minutes | Application pod is not running |
| `PodCrashLooping` | Warning | Frequent restarts | Pod is restarting repeatedly |
| `HighCPUUsage` | Warning | CPU > 80% for 5 minutes | High CPU utilization |
| `HighMemoryUsage` | Warning | Memory > 80% for 5 minutes | High memory utilization |
| `HighErrorRate` | Critical | 5xx errors > 5% | Application returning errors |
| `HighResponseTime` | Warning | p95 > 1 second | Slow response times |
| `HPAMaxedOut` | Warning | At max replicas for 10 min | HPA at maximum capacity |

### Customizing Alert Thresholds

Edit `k8s/prometheus/alerts.yaml` and adjust values:

```yaml
- alert: HighCPUUsage
  expr: cpu_usage > 80    # Change to 90 for less sensitive
  for: 5m                  # Change to 10m for longer grace period
```

Apply changes:

```bash
kubectl apply -f k8s/prometheus/alerts.yaml
kubectl rollout restart deployment prometheus -n monitoring
```

---

## Silencing Alerts

### Temporary Silence (Maintenance Windows)

```bash
# Port-forward Alertmanager
kubectl port-forward svc/alertmanager-service 9093:9093 -n monitoring

# Create silence via API
curl -X POST http://localhost:9093/api/v1/silences -d '{
  "matchers": [
    {
      "name": "alertname",
      "value": "HighCPUUsage",
      "isRegex": false
    }
  ],
  "startsAt": "2024-12-07T10:00:00Z",
  "endsAt": "2024-12-07T12:00:00Z",
  "createdBy": "admin",
  "comment": "Planned maintenance"
}'
```

Or use the Alertmanager UI at http://localhost:9093

---

## Troubleshooting

### Alerts Not Firing

1. Check Prometheus is scraping targets:
```bash
kubectl port-forward svc/prometheus-service 9090:9090 -n monitoring
# Visit: http://localhost:9090/targets
```

2. Verify alert rules are loaded:
```bash
# Visit: http://localhost:9090/rules
```

3. Check Prometheus logs:
```bash
kubectl logs -n monitoring -l app=prometheus
```

### Notifications Not Received

1. Check Alertmanager logs:
```bash
kubectl logs -n monitoring -l app=alertmanager -f
```

2. Verify webhook URLs:
```bash
kubectl get configmap alertmanager-config -n monitoring -o yaml
```

3. Test connectivity:
```bash
# Test Slack webhook
curl -X POST YOUR_SLACK_WEBHOOK_URL \
  -H 'Content-Type: application/json' \
  -d '{"text":"Test message from Alertmanager"}'
```

---

## Best Practices

1. **Alert Fatigue**: Don't alert on everything
   - Only alert on actionable issues
   - Use appropriate severity levels
   - Set reasonable thresholds

2. **Notification Channels**:
   - Critical → PagerDuty/Phone
   - Warning → Slack/Email
   - Info → Dashboard only

3. **Alert Grouping**:
   - Group related alerts together
   - Avoid duplicate notifications
   - Use appropriate wait times

4. **Documentation**:
   - Include runbooks in alert descriptions
   - Add links to dashboards
   - Document remediation steps

---

## Additional Resources

- [Prometheus Alerting Rules](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/)
- [Alertmanager Configuration](https://prometheus.io/docs/alerting/latest/configuration/)
- [Grafana Alerting](https://grafana.com/docs/grafana/latest/alerting/)
- [Alert Rule Best Practices](https://prometheus.io/docs/practices/alerting/)
