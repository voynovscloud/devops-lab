#!/bin/bash

# Load Test Script for HPA Validation
# This script generates load to trigger Horizontal Pod Autoscaler

set -e

# Configuration
TARGET_URL="${TARGET_URL:-http://app.local}"
DURATION="${DURATION:-300}"  # 5 minutes default
CONCURRENT="${CONCURRENT:-50}"
REQUESTS_PER_SECOND="${REQUESTS_PER_SECOND:-100}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "======================================"
echo " Load Test for HPA Validation"
echo "======================================"
echo "Target URL: $TARGET_URL"
echo "Duration: ${DURATION}s"
echo "Concurrent connections: $CONCURRENT"
echo "Requests per second: $REQUESTS_PER_SECOND"
echo "======================================"
echo ""

# Check if required tools are installed
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl is required but not installed. Aborting." >&2; exit 1; }

# Get namespace from environment or use default
NAMESPACE="${NAMESPACE:-production}"

echo -e "${YELLOW}📊 Initial HPA status:${NC}"
kubectl get hpa -n $NAMESPACE 2>/dev/null || echo "No HPA found in namespace $NAMESPACE"
echo ""

echo -e "${YELLOW}📊 Initial pod count:${NC}"
kubectl get pods -n $NAMESPACE 2>/dev/null | grep -E "NAME|node-app" || echo "No pods found"
echo ""

echo -e "${GREEN}🚀 Starting load test...${NC}"
echo "Press Ctrl+C to stop"
echo ""

# Function to generate load using curl
generate_load() {
    local end_time=$((SECONDS + DURATION))
    local request_count=0
    
    while [ $SECONDS -lt $end_time ]; do
        # Run concurrent requests
        for i in $(seq 1 $CONCURRENT); do
            curl -s -o /dev/null -w "%{http_code}" "$TARGET_URL/health" > /dev/null 2>&1 &
        done
        
        request_count=$((request_count + CONCURRENT))
        
        # Rate limiting
        sleep $(echo "scale=2; $CONCURRENT / $REQUESTS_PER_SECOND" | bc)
        
        # Show progress every 10 seconds
        if [ $((SECONDS % 10)) -eq 0 ]; then
            echo "⏱️  $(date +%H:%M:%S) - Sent $request_count requests..."
        fi
    done
    
    # Wait for background jobs to complete
    wait
    
    echo ""
    echo -e "${GREEN}✅ Load test completed!${NC}"
    echo "Total requests sent: $request_count"
}

# Alternative: Use Apache Bench if available
generate_load_ab() {
    if command -v ab >/dev/null 2>&1; then
        echo "Using Apache Bench (ab) for load testing..."
        local total_requests=$((REQUESTS_PER_SECOND * DURATION))
        ab -n $total_requests -c $CONCURRENT -t $DURATION "$TARGET_URL/health"
    else
        echo "Apache Bench not available, falling back to curl"
        generate_load
    fi
}

# Start monitoring in background
monitor_hpa() {
    echo -e "\n${YELLOW}📊 Monitoring HPA (will update every 10s)...${NC}\n"
    while true; do
        clear
        echo "======================================"
        echo " HPA Status (Live)"
        echo "======================================"
        kubectl get hpa -n $NAMESPACE 2>/dev/null || echo "No HPA found"
        echo ""
        echo "======================================"
        echo " Pod Status (Live)"
        echo "======================================"
        kubectl get pods -n $NAMESPACE 2>/dev/null | grep -E "NAME|node-app" || echo "No pods found"
        echo ""
        echo "Press Ctrl+C to stop monitoring"
        sleep 10
    done
}

# Trap Ctrl+C
trap 'echo -e "\n${YELLOW}⚠️  Stopping load test...${NC}"; exit 0' INT

# Start load test based on available tools
if command -v ab >/dev/null 2>&1; then
    # Start monitoring in background
    monitor_hpa &
    MONITOR_PID=$!
    
    generate_load_ab
    
    # Stop monitoring
    kill $MONITOR_PID 2>/dev/null || true
else
    # Start monitoring in background
    monitor_hpa &
    MONITOR_PID=$!
    
    generate_load
    
    # Stop monitoring
    kill $MONITOR_PID 2>/dev/null || true
fi

# Final status
echo ""
echo "======================================"
echo " Final Status"
echo "======================================"
echo ""

echo -e "${YELLOW}📊 Final HPA status:${NC}"
kubectl get hpa -n $NAMESPACE 2>/dev/null || echo "No HPA found"
echo ""

echo -e "${YELLOW}📊 Final pod count:${NC}"
kubectl get pods -n $NAMESPACE 2>/dev/null | grep -E "NAME|node-app" || echo "No pods found"
echo ""

echo -e "${GREEN}✅ Load test completed successfully!${NC}"
echo ""
echo "💡 Tips:"
echo "   - Watch HPA: kubectl get hpa -n $NAMESPACE -w"
echo "   - Watch pods: kubectl get pods -n $NAMESPACE -w"
echo "   - View metrics: kubectl top pods -n $NAMESPACE"
echo "   - Check events: kubectl get events -n $NAMESPACE --sort-by='.lastTimestamp'"
echo ""
