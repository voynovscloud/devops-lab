#!/bin/bash
set -e

echo "🚀 DevOps Lab - Quick Setup Script"
echo "=================================="
echo ""

# Check prerequisites
echo "Checking prerequisites..."
command -v docker >/dev/null 2>&1 || { echo "❌ Docker not found. Please install Docker."; exit 1; }
command -v docker-compose >/dev/null 2>&1 || command -v docker >/dev/null 2>&1 || { echo "❌ docker-compose not found. Please install docker-compose."; exit 1; }
echo "✅ Docker is installed"
echo ""

# Verify Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker daemon is not running. Please start Docker."
    exit 1
fi
echo "✅ Docker daemon is running"
echo ""

# Check if port 3000 is available
if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "⚠️  Port 3000 is already in use"
    read -p "Kill the process and continue? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        lsof -ti:3000 | xargs kill -9 2>/dev/null || true
        echo "✅ Port 3000 freed"
    else
        echo "❌ Exiting. Please free port 3000 manually."
        exit 1
    fi
fi

echo "Starting DevOps Lab stack..."
echo ""

# Start the full stack
docker-compose up -d

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 10

# Check if services are running
echo ""
echo "Checking service health..."

check_service() {
    local name=$1
    local url=$2
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -sf "$url" >/dev/null 2>&1; then
            echo "✅ $name is ready at $url"
            return 0
        fi
        attempt=$((attempt + 1))
        sleep 1
    done
    
    echo "⚠️  $name might not be ready yet at $url"
    return 1
}

check_service "Node App" "http://127.0.0.1:3000/health"
check_service "Prometheus" "http://127.0.0.1:9090/-/healthy"
check_service "Grafana" "http://127.0.0.1:3001/api/health"

echo ""
echo "=================================="
echo "✅ DevOps Lab is running!"
echo "=================================="
echo ""
echo "Access your services:"
echo "  📊 Node App:    http://localhost:3000"
echo "  📈 Metrics:     http://localhost:3000/metrics"
echo "  ❤️  Health:      http://localhost:3000/health"
echo "  🔥 Prometheus:  http://localhost:9090"
echo "  📉 Grafana:     http://localhost:3001 (admin/admin)"
echo "  🔧 Jenkins:     http://localhost:8081"
echo "  🐳 Portainer:   http://localhost:9000"
echo "  📊 cAdvisor:    http://localhost:8080"
echo ""
echo "Next steps:"
echo "  1. Visit http://localhost:3000 to see the app"
echo "  2. Check metrics at http://localhost:3000/metrics"
echo "  3. View Prometheus at http://localhost:9090"
echo "  4. Set up Grafana dashboard at http://localhost:3001"
echo "  5. Configure Jenkins at http://localhost:8081"
echo ""
echo "To stop: docker-compose down"
echo "To view logs: docker-compose logs -f"
echo ""
echo "📖 Full documentation: README.md"
echo "💰 Monetization guide: docs/MONETIZATION.md"
echo "🚀 Ready for production!"
