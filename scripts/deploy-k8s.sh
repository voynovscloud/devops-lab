#!/usr/bin/env bash
set -eo pipefail

echo "========================================"
echo "DevOps Lab - Kubernetes Deployment Script"
echo "========================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    printf "${GREEN}✓${NC} %s\n" "$1"
}

print_warning() {
    printf "${YELLOW}⚠${NC} %s\n" "$1"
}

print_error() {
    printf "${RED}✗${NC} %s\n" "$1"
}

# Check if kubectl is available (either standalone or via minikube)
if command -v kubectl &> /dev/null; then
    KUBECTL="kubectl"
elif command -v minikube &> /dev/null; then
    KUBECTL="minikube kubectl --"
    print_status "Using kubectl via minikube"
else
    print_error "kubectl is not installed. Please install kubectl first."
    echo "Install with: curl -LO https://dl.k8s.io/release/\$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    exit 1
fi

# Check for Kubernetes installation (prefer Minikube over K3s)
echo "Checking for Kubernetes installation..."
CLUSTER_TYPE=""

if command -v minikube &> /dev/null; then
    CLUSTER_TYPE="minikube"
    print_status "Minikube is installed"
    
    # Check if Minikube is running
    if ! minikube status &> /dev/null; then
        print_warning "Minikube is not running. Starting..."
        minikube start --cpus=4 --memory=8192 --disk-size=20g
        print_status "Minikube started"
    else
        print_status "Minikube is running"
    fi
    
elif command -v k3s &> /dev/null; then
    CLUSTER_TYPE="k3s"
    print_status "K3s is installed"
    
    # Check if K3s service is running
    if ! systemctl is-active --quiet k3s 2>/dev/null && ! sudo systemctl is-active --quiet k3s 2>/dev/null; then
        print_warning "K3s is installed but not running"
        echo "Starting K3s..."
        sudo systemctl start k3s
        sleep 5
    fi
    
    # Setup kubeconfig if needed
    if [ ! -f ~/.kube/config ]; then
        print_warning "Setting up kubeconfig..."
        mkdir -p ~/.kube
        sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
        sudo chown $USER ~/.kube/config
    fi
else
    print_error "No Kubernetes cluster found!"
    echo ""
    echo "Install Minikube (recommended for local development):"
    echo "  # Install Minikube"
    echo "  curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64"
    echo "  sudo install minikube-linux-amd64 /usr/local/bin/minikube"
    echo ""
    echo "  # Start Minikube"
    echo "  minikube start --cpus=4 --memory=8192"
    echo ""
    echo "Or install K3s (lightweight):"
    echo "  curl -sfL https://get.k3s.io | sh -"
    echo ""
    echo "After installation, run this script again."
    exit 1
fi

# Check if Kubernetes cluster is accessible
echo "Checking Kubernetes cluster connectivity..."
RETRIES=0
MAX_RETRIES=10
while [ $RETRIES -lt $MAX_RETRIES ]; do
    if $KUBECTL cluster-info &> /dev/null; then
        print_status "Kubernetes cluster is accessible (using $CLUSTER_TYPE)"
        $KUBECTL cluster-info | head -2
        echo ""
        break
    fi
    
    RETRIES=$((RETRIES + 1))
    if [ $RETRIES -lt $MAX_RETRIES ]; then
        echo "Waiting for cluster to be ready... ($RETRIES/$MAX_RETRIES)"
        sleep 3
    else
        print_error "Cannot connect to Kubernetes cluster after $MAX_RETRIES attempts"
        echo ""
        if [ "$CLUSTER_TYPE" == "minikube" ]; then
            echo "Try these commands:"
            echo "  minikube status"
            echo "  minikube start"
            echo "  minikube logs"
        else
            echo "Try these commands:"
            echo "  sudo systemctl status k3s"
            echo "  sudo systemctl start k3s"
            echo "  sudo journalctl -u k3s -f"
        fi
        exit 1
    fi
done

# Use --validate=false to avoid API server issues
KUBECTL_OPTS="--validate=false"

# Function to wait for pods
wait_for_pods() {
    local namespace=$1
    local label=$2
    local timeout=300
    local elapsed=0
    
    echo "Waiting for pods in namespace $namespace (label: $label)..."
    
    while [ $elapsed -lt $timeout ]; do
        ready=$($KUBECTL get pods -n $namespace -l $label --no-headers 2>/dev/null | grep -c "1/1.*Running" || echo "0")
        total=$($KUBECTL get pods -n $namespace -l $label --no-headers 2>/dev/null | wc -l || echo "0")
        
        # Remove any whitespace from numbers
        ready=$(echo $ready | tr -d ' ')
        total=$(echo $total | tr -d ' ')
        
        if [ ! -z "$total" ] && [ "$total" -gt 0 ] 2>/dev/null && [ "$ready" -eq "$total" ] 2>/dev/null; then
            print_status "All pods ready in $namespace ($ready/$total)"
            return 0
        fi
        
        echo "  Pods ready: $ready/$total (${elapsed}s elapsed)"
        sleep 5
        elapsed=$((elapsed + 5))
    done
    
    print_error "Timeout waiting for pods in $namespace"
    return 1
}

# Function to restart not-ready pods
restart_not_ready_pods() {
    local namespace=$1
    
    echo "Checking for not-ready pods in namespace $namespace..."
    
    not_ready_pods=$($KUBECTL get pods -n $namespace --no-headers 2>/dev/null | grep -v "1/1.*Running" | awk '{print $1}' || echo "")
    
    if [ -z "$not_ready_pods" ]; then
        print_status "All pods are ready in $namespace"
        return 0
    fi
    
    for pod in $not_ready_pods; do
        print_warning "Restarting not-ready pod: $pod"
        $KUBECTL delete pod $pod -n $namespace --grace-period=10 || true
    done
    
    sleep 10
}

echo "Step 1: Applying Node App manifests..."
echo "========================================"
$KUBECTL apply $KUBECTL_OPTS -f k8s/node-app/namespace.yaml
$KUBECTL apply $KUBECTL_OPTS -f k8s/node-app/configmap.yaml
$KUBECTL apply $KUBECTL_OPTS -f k8s/node-app/deployment.yaml
$KUBECTL apply $KUBECTL_OPTS -f k8s/node-app/service.yaml
$KUBECTL apply $KUBECTL_OPTS -f k8s/node-app/ingress.yaml 2>/dev/null || print_warning "Ingress not applied (controller may not be installed)"
print_status "Node App manifests applied"
echo ""

echo "Step 2: Applying Prometheus manifests..."
echo "========================================"
$KUBECTL apply $KUBECTL_OPTS -f k8s/prometheus/namespace.yaml
$KUBECTL apply $KUBECTL_OPTS -f k8s/prometheus/rbac.yaml
$KUBECTL apply $KUBECTL_OPTS -f k8s/prometheus/configmap.yaml
$KUBECTL apply $KUBECTL_OPTS -f k8s/prometheus/pvc.yaml
$KUBECTL apply $KUBECTL_OPTS -f k8s/prometheus/deployment.yaml
$KUBECTL apply $KUBECTL_OPTS -f k8s/prometheus/service.yaml
print_status "Prometheus manifests applied"
echo ""

echo "Step 3: Applying Grafana manifests..."
echo "========================================"
$KUBECTL apply $KUBECTL_OPTS -f k8s/grafana/secret.yaml
$KUBECTL apply $KUBECTL_OPTS -f k8s/grafana/configmap.yaml
$KUBECTL apply $KUBECTL_OPTS -f k8s/grafana/pvc.yaml
$KUBECTL apply $KUBECTL_OPTS -f k8s/grafana/deployment.yaml
$KUBECTL apply $KUBECTL_OPTS -f k8s/grafana/service.yaml
print_status "Grafana manifests applied"
echo ""

echo "Step 4: Fixing Grafana permissions..."
echo "========================================"
print_warning "Patching Grafana deployment to run as root (fixes PVC permission issues)"
$KUBECTL patch deployment grafana -n monitoring --type='json' -p='[
  {
    "op": "remove",
    "path": "/spec/template/spec/containers/0/securityContext"
  },
  {
    "op": "add",
    "path": "/spec/template/spec/securityContext",
    "value": {
      "runAsUser": 0,
      "fsGroup": 0
    }
  }
]' 2>/dev/null || print_warning "Patch may have already been applied"

# Alternative: Add init container to fix permissions
$KUBECTL patch deployment grafana -n monitoring --type='json' -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/initContainers",
    "value": [
      {
        "name": "fix-permissions",
        "image": "busybox",
        "command": ["sh", "-c", "chown -R 472:472 /var/lib/grafana"],
        "volumeMounts": [
          {
            "name": "storage",
            "mountPath": "/var/lib/grafana"
          }
        ],
        "securityContext": {
          "runAsUser": 0
        }
      }
    ]
  }
]' 2>/dev/null || print_warning "Init container may already exist"

print_status "Grafana permissions fixed"
echo ""

echo "Step 5: Applying Jenkins manifests..."
echo "========================================"
$KUBECTL apply $KUBECTL_OPTS -f k8s/jenkins/namespace.yaml
$KUBECTL apply $KUBECTL_OPTS -f k8s/jenkins/rbac.yaml
$KUBECTL apply $KUBECTL_OPTS -f k8s/jenkins/pvc.yaml
$KUBECTL apply $KUBECTL_OPTS -f k8s/jenkins/deployment.yaml
$KUBECTL apply $KUBECTL_OPTS -f k8s/jenkins/service.yaml
print_status "Jenkins manifests applied"
echo ""

echo "Step 6: Waiting for initial pod creation..."
echo "========================================"
sleep 15
echo ""

echo "Step 7: Checking and restarting not-ready pods..."
echo "========================================"
restart_not_ready_pods "devops-lab"
restart_not_ready_pods "monitoring"
restart_not_ready_pods "jenkins"
echo ""

echo "Step 8: Waiting for all pods to be ready..."
echo "========================================"
wait_for_pods "devops-lab" "app=node-app" &
PID1=$!
wait_for_pods "monitoring" "app=prometheus" &
PID2=$!
wait_for_pods "monitoring" "app=grafana" &
PID3=$!
wait_for_pods "jenkins" "app=jenkins" &
PID4=$!

# Wait for all background jobs
wait $PID1 || print_error "Node App pods not ready"
wait $PID2 || print_error "Prometheus pods not ready"
wait $PID3 || print_error "Grafana pods not ready"
wait $PID4 || print_error "Jenkins pods not ready"
echo ""

echo "Step 9: Final status check..."
echo "========================================"
echo ""

echo "📦 Persistent Volume Claims:"
echo "----------------------------"
$KUBECTL get pvc -n devops-lab 2>/dev/null || echo "No PVCs in devops-lab"
$KUBECTL get pvc -n monitoring
$KUBECTL get pvc -n jenkins
echo ""

echo "🔄 Pods Status:"
echo "----------------------------"
echo "Node App (devops-lab):"
$KUBECTL get pods -n devops-lab -o wide
echo ""
echo "Prometheus (monitoring):"
$KUBECTL get pods -n monitoring -l app=prometheus -o wide
echo ""
echo "Grafana (monitoring):"
$KUBECTL get pods -n monitoring -l app=grafana -o wide
echo ""
echo "Jenkins (jenkins):"
$KUBECTL get pods -n jenkins -o wide
echo ""

echo "🌐 Services:"
echo "----------------------------"
$KUBECTL get svc -n devops-lab
$KUBECTL get svc -n monitoring
$KUBECTL get svc -n jenkins
echo ""

echo "========================================"
echo "✅ Deployment Complete!"
echo "========================================"
echo ""
echo "Access your services:"
echo "---------------------"
echo "Node App:    kubectl port-forward -n devops-lab svc/node-app 8080:80"
echo "Prometheus:  kubectl port-forward -n monitoring svc/prometheus 9090:9090"
echo "Grafana:     kubectl port-forward -n monitoring svc/grafana 3000:3000"
echo "Jenkins:     kubectl port-forward -n jenkins svc/jenkins 8081:8080"
echo ""
echo "Check logs if any service is not ready:"
echo "---------------------------------------"
echo "kubectl logs -f deployment/node-app -n devops-lab"
echo "kubectl logs -f deployment/prometheus -n monitoring"
echo "kubectl logs -f deployment/grafana -n monitoring"
echo "kubectl logs -f deployment/jenkins -n jenkins"
echo ""

# Check if any pods are not running
echo "Final Health Check:"
echo "-------------------"
not_running=$($KUBECTL get pods -A | grep -v "Running\|Completed" | grep -v "NAME" || echo "")
if [ -z "$not_running" ]; then
    print_status "All pods are running successfully!"
else
    print_warning "Some pods are not running:"
    echo "$not_running"
fi
