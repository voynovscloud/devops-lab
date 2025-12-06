#!/bin/bash

# Jenkins Docker Setup Script
# Runs Jenkins in Docker with persistent storage

JENKINS_HOME="$HOME/jenkins_home"
JENKINS_PORT=8081

echo "🚀 Starting Jenkins in Docker..."

# Create Jenkins home directory if it doesn't exist
if [ ! -d "$JENKINS_HOME" ]; then
    echo "📁 Creating Jenkins home directory at $JENKINS_HOME"
    mkdir -p "$JENKINS_HOME"
    chmod 777 "$JENKINS_HOME"
fi

# Check if Jenkins container already exists
if docker ps -a --format '{{.Names}}' | grep -q '^jenkins$'; then
    echo "♻️  Jenkins container exists, restarting..."
    docker start jenkins
else
    echo "🆕 Creating new Jenkins container..."
    docker run -d \
        --name jenkins \
        --restart unless-stopped \
        --user root \
        -p $JENKINS_PORT:8080 \
        -p 50000:50000 \
        -v "$JENKINS_HOME:/var/jenkins_home" \
        -v /var/run/docker.sock:/var/run/docker.sock \
        jenkins/jenkins:lts
    
    echo "⏳ Installing Docker CLI in Jenkins container..."
    sleep 10
    docker exec -u root jenkins bash -c "apt-get update && apt-get install -y docker.io"
    
    echo "⏳ Waiting for Jenkins to fully start..."
    sleep 20
fi

echo ""
echo "✅ Jenkins is running!"
echo ""
echo "🌐 Access Jenkins at: http://localhost:$JENKINS_PORT"
echo ""

# Get admin password
if docker exec jenkins test -f /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null; then
    echo "🔑 Initial Admin Password:"
    docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
else
    echo "ℹ️  Jenkins is already configured (no initial password file)"
fi

echo ""
echo "📝 Useful commands:"
echo "   View logs:    docker logs -f jenkins"
echo "   Stop Jenkins: docker stop jenkins"
echo "   Restart:      docker start jenkins"
echo "   Remove:       docker stop jenkins && docker rm jenkins"
