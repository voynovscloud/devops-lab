# Ingress Access Guide

## Quick Setup

Add these entries to your `/etc/hosts` file:

```bash
192.168.49.2 app.local
192.168.49.2 jenkins.local
192.168.49.2 grafana.local
192.168.49.2 prometheus.local
```

### Automatic Setup (Linux/Mac)

Run this command:

```bash
sudo bash -c "cat >> /etc/hosts << HOSTS
192.168.49.2 app.local
192.168.49.2 jenkins.local
192.168.49.2 grafana.local
192.168.49.2 prometheus.local
HOSTS"
```

## Access Your Services

Once hosts are configured, access your services directly:

- **Node App**: http://app.local
- **Jenkins**: http://jenkins.local
- **Grafana**: http://grafana.local (admin/admin)
- **Prometheus**: http://prometheus.local

## Verify Ingress

Check Ingress status:
```bash
kubectl get ingress -A
```

Check Ingress controller:
```bash
kubectl get pods -n ingress-nginx
```

## Troubleshooting

If services are not accessible:

1. Verify Minikube IP: `minikube ip`
2. Check Ingress resources: `kubectl get ingress -A`
3. Check Ingress controller: `kubectl get pods -n ingress-nginx`
4. Verify /etc/hosts entries: `cat /etc/hosts | grep local`

## Remove Hosts Entries

To remove the hosts entries later:
```bash
sudo sed -i.bak '/app.local\|jenkins.local\|grafana.local\|prometheus.local/d' /etc/hosts
```
