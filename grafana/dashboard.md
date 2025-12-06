# Grafana Dashboard for DevOps Lab Node App

Dashboard ID: Import this JSON into Grafana

```json
{
  "dashboard": {
    "title": "DevOps Lab - Node.js Metrics",
    "panels": [
      {
        "title": "HTTP Requests Total",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])"
          }
        ]
      },
      {
        "title": "Node.js Event Loop Lag",
        "targets": [
          {
            "expr": "nodejs_eventloop_lag_seconds"
          }
        ]
      },
      {
        "title": "Memory Usage",
        "targets": [
          {
            "expr": "process_resident_memory_bytes"
          }
        ]
      },
      {
        "title": "CPU Usage",
        "targets": [
          {
            "expr": "rate(process_cpu_seconds_total[5m])"
          }
        ]
      }
    ]
  }
}
```

## Import Steps
1. Open Grafana at http://localhost:3001
2. Go to Dashboards → Import
3. Paste the JSON above
4. Select Prometheus as data source
5. Click Import
