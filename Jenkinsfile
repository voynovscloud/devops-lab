pipeline {
    agent any
    
    environment {
        APP_NAME = "devops-lab-nodeapp"
        APP_DIR = "./my-node-app"
        DOCKER_REGISTRY = "ghcr.io"
        IMAGE_NAME = "${DOCKER_REGISTRY}/${GIT_ORG}/${APP_NAME}"
        GIT_ORG = "voynovscloud"
        MINIKUBE_ACTIVE = "true"
    }
    
    parameters {
        choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'prod'], description: 'Target environment')
        booleanParam(name: 'SKIP_TESTS', defaultValue: false, description: 'Skip tests')
        booleanParam(name: 'DEPLOY_TO_MINIKUBE', defaultValue: true, description: 'Deploy to local Minikube')
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Cloning repository...'
                checkout scm
                script {
                    env.GIT_COMMIT_SHORT = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
                    env.BUILD_TAG = "${env.ENVIRONMENT}-${env.GIT_COMMIT_SHORT}-${env.BUILD_NUMBER}"
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo "Building Docker image: ${APP_NAME}:${BUILD_TAG}"
                sh """
                    docker build -t ${APP_NAME}:latest -t ${APP_NAME}:${BUILD_TAG} ${APP_DIR}
                """
            }
        }
        
        stage('Test') {
            when {
                expression { return !params.SKIP_TESTS }
            }
            steps {
                echo 'Running tests with built image...'
                sh """
                    # Start the app container
                    echo "Starting test container..."
                    docker run --rm -d --name test-app-${BUILD_NUMBER} ${APP_NAME}:latest
                    
                    # Wait a moment for container to start
                    sleep 3
                    
                    # Check if container is running
                    if ! docker ps | grep -q test-app-${BUILD_NUMBER}; then
                        echo "❌ Container failed to start!"
                        echo "Container logs:"
                        docker logs test-app-${BUILD_NUMBER} 2>&1 || true
                        exit 1
                    fi
                    
                    # Get container IP
                    CONTAINER_IP=\$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' test-app-${BUILD_NUMBER})
                    echo "Container IP: \${CONTAINER_IP}"
                    
                    # Wait for app to be ready
                    echo "Waiting for app to start..."
                    READY=0
                    for i in \$(seq 1 30); do
                        if docker exec test-app-${BUILD_NUMBER} wget -q -O- http://localhost:3000/health >/dev/null 2>&1; then
                            echo "✓ App is ready (took \${i}s)"
                            READY=1
                            break
                        fi
                        if [ \$((i % 5)) -eq 0 ]; then
                            echo "Still waiting... (\${i}/30s)"
                        fi
                        sleep 1
                    done
                    
                    if [ \$READY -eq 0 ]; then
                        echo "❌ App failed to become ready within 30 seconds"
                        echo "Container logs:"
                        docker logs test-app-${BUILD_NUMBER}
                        docker stop test-app-${BUILD_NUMBER} || true
                        exit 1
                    fi
                    
                    # Run health check tests
                    echo "Running health checks..."
                    docker exec test-app-${BUILD_NUMBER} wget -q -O- http://localhost:3000/health || exit 1
                    docker exec test-app-${BUILD_NUMBER} wget -q -O- http://localhost:3000/metrics || exit 1
                    echo "✓ All health checks passed"
                    
                    # Cleanup
                    docker stop test-app-${BUILD_NUMBER} || true
                    docker rm test-app-${BUILD_NUMBER} || true
                """
            }
        }
        
        stage('Security Scan') {
            steps {
                echo 'Running Trivy security scan...'
                sh """
                    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v \$(pwd):/workspace ghcr.io/aquasecurity/trivy:latest image --format json --output /workspace/trivy-report.json ${APP_NAME}:latest || true
                    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock ghcr.io/aquasecurity/trivy:latest image --severity HIGH,CRITICAL ${APP_NAME}:latest || true
                """
            }
        }
        
        stage('Deploy to Minikube') {
            when {
                expression { return params.DEPLOY_TO_MINIKUBE }
            }
            steps {
                echo "Deploying to Minikube..."
                sh """
                    # Load image into Minikube
                    minikube image load ${APP_NAME}:latest || echo "⚠️  Minikube not accessible from Jenkins container"
                    
                    # Try to restart deployment if kubectl is accessible
                    if command -v kubectl &> /dev/null; then
                        kubectl rollout restart deployment/node-app -n devops-lab || echo "⚠️  kubectl not configured"
                    else
                        echo "⚠️  kubectl not installed in Jenkins"
                        echo "To deploy, run manually: minikube image load ${APP_NAME}:latest && kubectl rollout restart deployment/node-app -n devops-lab"
                    fi
                """
            }
        }
    }
    
    post {
        success {
            echo """
            ✅ PIPELINE SUCCEEDED!
            
            Next Steps:
            1. View image: docker images | grep ${APP_NAME}
            2. Run locally: docker run -p 3000:3000 ${APP_NAME}:latest
            3. Check security: Review trivy-report.json artifact
            
            To deploy to Minikube manually:
            docker save ${APP_NAME}:latest | minikube image load -
            kubectl rollout restart deployment/node-app -n devops-lab
            """
        }
        failure {
            echo """
            ❌ PIPELINE FAILED
            
            Check console output above for errors.
            """
        }
    }
}
