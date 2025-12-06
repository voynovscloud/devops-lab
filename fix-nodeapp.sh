#!/bin/bash
set -e

echo "Building node app image..."
cd /home/voynovs/devops-lab/my-node-app
docker build -t devops-lab-nodeapp:latest .

echo ""
echo "Loading image into Minikube..."
minikube image load devops-lab-nodeapp:latest

echo ""
echo "Applying updated deployment..."
cd /home/voynovs/devops-lab
minikube kubectl -- apply -f k8s/node-app/deployment.yaml

echo ""
echo "Waiting for pods to restart..."
sleep 10

echo ""
echo "Checking pod status..."
minikube kubectl -- get pods -n devops-lab

echo ""
echo "Done!"
