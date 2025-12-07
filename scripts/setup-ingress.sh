#!/bin/bash
set -e

echo "🌐 Setting up Ingress access for DevOps Lab"
echo "==========================================="
echo ""

# Get Minikube IP
MINIKUBE_IP=$(minikube ip)
echo "✓ Minikube IP: $MINIKUBE_IP"
echo ""

# Check if Ingress controller is ready
echo "Checking Ingress controller..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s 2>/dev/null && echo "✓ Ingress controller ready" || echo "⚠ Ingress controller not ready yet"

echo ""
echo "Applying Ingress resources..."
kubectl apply -f k8s/ingress-all.yaml

echo ""
echo "Waiting for Ingress resources..."
sleep 5

echo ""
echo "📋 Ingress Status:"
kubectl get ingress -A

echo ""
echo "=========================================="
echo "✅ Ingress Configuration Complete!"
echo "=========================================="
echo ""
echo "To access your services, add these entries to /etc/hosts:"
echo ""
echo "$MINIKUBE_IP app.local"
echo "$MINIKUBE_IP jenkins.local"
echo "$MINIKUBE_IP grafana.local"
echo "$MINIKUBE_IP prometheus.local"
echo ""
echo "Run this command to add them automatically:"
echo ""
echo "sudo bash -c \"cat >> /etc/hosts << EOF"
echo "$MINIKUBE_IP app.local"
echo "$MINIKUBE_IP jenkins.local"
echo "$MINIKUBE_IP grafana.local"
echo "$MINIKUBE_IP prometheus.local"
echo "EOF\""
echo ""
echo "Then access your services at:"
echo "  📱 Node App:    http://app.local"
echo "  🔧 Jenkins:     http://jenkins.local"
echo "  📊 Grafana:     http://grafana.local"
echo "  📈 Prometheus:  http://prometheus.local"
echo ""
