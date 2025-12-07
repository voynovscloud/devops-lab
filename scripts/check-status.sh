#!/bin/bash

echo "=== Cluster Status ==="
minikube status

echo ""
echo "=== All Pods ==="
minikube kubectl -- get pods -A

echo ""
echo "=== All Services ==="
minikube kubectl -- get svc -A

echo ""
echo "=== All PVCs ==="
minikube kubectl -- get pvc -A

echo ""
echo "=== Deployments ==="
minikube kubectl -- get deployments -A
