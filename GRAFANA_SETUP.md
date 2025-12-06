# Grafana Dashboard Setup Guide

## Quick Access

- **Grafana URL**: http://grafana.local
- **Default Credentials**: admin / admin

## Import Dashboard for Node App Metrics

### Method 1: Import JSON (Recommended)

1. Open Grafana at http://grafana.local
2. Login with admin/admin
3. Click **"+"** (plus icon) in the left sidebar → **Import**
4. Click **"Upload JSON file"**
5. Select `/k8s/grafana/dashboard-nodeapp.json` from this repository
6. Click **Import**

### Method 2: Manual Dashboard Creation

If import doesn't work, create queries manually:

#### CPU Usage Panel
```promql
# User CPU
rate(process_cpu_user_seconds_total{job="node-app"}[1m])

# System CPU
rate(process_cpu_system_seconds_total{job="node-app"}[1m])
```

#### Memory Usage Panel
```promql
# Resident Memory
process_resident_memory_bytes{job="node-app"}

# Heap Used
nodejs_heap_size_used_bytes{job="node-app"}

# Heap Total
nodejs_heap_size_total_bytes{job="node-app"}
```

#### HTTP Requests Panel
```promql
rate(http_requests_total{job="node-app"}[1m])
```

#### Event Loop Lag Panel
```promql
nodejs_eventloop_lag_seconds{job="node-app"}
```

## Available Metrics

The Node.js app exposes these metrics:

### Process Metrics
- `process_cpu_user_seconds_total` - User CPU time
- `process_cpu_system_seconds_total` - System CPU time
- `process_resident_memory_bytes` - Resident memory
- `process_heap_bytes` - Heap memory
- `process_uptime_seconds` - Process uptime

### Node.js Specific
- `nodejs_heap_size_used_bytes` - Heap memory used
- `nodejs_heap_size_total_bytes` - Total heap size
- `nodejs_eventloop_lag_seconds` - Event loop lag
- `nodejs_active_handles_total` - Active handles
- `nodejs_active_requests_total` - Active requests

### Application Metrics
- `http_requests_total` - Total HTTP requests (with labels: method, route, status)

## Troubleshooting

### Data Source Not Connected

1. Go to **Configuration** → **Data Sources**
2. Click on **Prometheus**
3. Verify URL is: `http://prometheus:9090`
4. Click **"Save & Test"** - should show "Data source is working"

### No Data Showing

1. Check Prometheus is scraping:
   ```bash
   curl http://prometheus.local/api/v1/targets
   ```

2. Verify node-app metrics are available:
   ```bash
   curl http://app.local/metrics
   ```

3. Check time range in Grafana (top right) - set to "Last 5 minutes"

### Prometheus Query Errors

- Make sure queries use `job="node-app"` label
- Check Prometheus has data: http://prometheus.local/graph
- Try queries there first before adding to Grafana

## Generate Traffic

To see metrics activity, generate some traffic:

```bash
# Generate requests
for i in {1..100}; do curl http://app.local/health; done

# Monitor metrics
watch -n 1 'curl -s http://app.local/metrics | grep http_requests_total'
```

## Quick Dashboard URLs

After setup, you can access:
- **Node App Dashboard**: http://grafana.local/d/node-app/devops-lab-node-app-metrics
- **Prometheus Targets**: http://prometheus.local/targets
- **Node App Metrics**: http://app.local/metrics
