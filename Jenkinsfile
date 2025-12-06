pipeline {
    agent any
    
    environment {
        APP_NAME = "devops-lab-nodeapp"
        APP_DIR = "./my-node-app"
        DOCKER_REGISTRY = "ghcr.io"
        IMAGE_NAME = "${DOCKER_REGISTRY}/${GIT_ORG}/${APP_NAME}"
        GIT_ORG = "voynovscloud"
    }
    
    parameters {
        choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'prod'], description: 'Target environment')
        booleanParam(name: 'SKIP_TESTS', defaultValue: false, description: 'Skip tests')
        booleanParam(name: 'PUSH_IMAGE', defaultValue: false, description: 'Push image to registry')
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
                echo "Building Docker image: ${IMAGE_NAME}:${BUILD_TAG}"
                sh """
                    docker build -t ${APP_NAME}:latest -t ${APP_NAME}:${BUILD_TAG} -t ${IMAGE_NAME}:${BUILD_TAG} -t ${IMAGE_NAME}:latest ${APP_DIR}
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
                    # Use a random high port to avoid conflicts
                    TEST_PORT=\$((3100 + BUILD_NUMBER))
                    
                    # Start the app from the built image
                    docker run --rm -d --name test-app-${BUILD_NUMBER} -p \${TEST_PORT}:3000 ${APP_NAME}:latest
                    
                    # Wait for app to be ready
                    for i in {1..30}; do
                        if curl -sf http://127.0.0.1:\${TEST_PORT}/health >/dev/null 2>&1; then
                            echo "App is ready on port \${TEST_PORT}"
                            break
                        fi
                        echo "Waiting for app... (\$i/30)"
                        sleep 1
                    done
                    
                    # Run a simple health check test
                    curl -f http://127.0.0.1:\${TEST_PORT}/health || exit 1
                    curl -f http://127.0.0.1:\${TEST_PORT}/metrics || exit 1
                    echo "✓ Health and metrics endpoints working"
                    
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
        
        stage('Push to Registry') {
            when {
                expression { return params.PUSH_IMAGE }
            }
            steps {
                echo "Pushing image to ${DOCKER_REGISTRY}..."
                withCredentials([usernamePassword(credentialsId: 'ghcr-credentials', usernameVariable: 'REGISTRY_USER', passwordVariable: 'REGISTRY_TOKEN')]) {
                    sh """
                        echo \$REGISTRY_TOKEN | docker login ${DOCKER_REGISTRY} -u \$REGISTRY_USER --password-stdin
                        docker push ${IMAGE_NAME}:${BUILD_TAG}
                        docker push ${IMAGE_NAME}:latest
                        docker logout ${DOCKER_REGISTRY}
                    """
                }
            }
        }
        
        stage('Deploy to K8s') {
            when {
                expression { return params.PUSH_IMAGE && params.ENVIRONMENT != 'dev' }
            }
            steps {
                echo "Deploying to Kubernetes (${params.ENVIRONMENT})..."
                sh """
                    kubectl set image deployment/devops-lab-nodeapp devops-lab-nodeapp=${IMAGE_NAME}:${BUILD_TAG} -n ${params.ENVIRONMENT} || echo "Deployment not found, skipping"
                """
            }
        }
    }
    
    post {
        always {
            echo 'Cleaning up...'
            sh 'docker system prune -f || true'
            archiveArtifacts artifacts: 'trivy-report.json', allowEmptyArchive: true
            
            // Summary report
            script {
                def duration = currentBuild.durationString.replace(' and counting', '')
                echo """
                =====================================
                BUILD SUMMARY
                =====================================
                Status: ${currentBuild.currentResult}
                Duration: ${duration}
                Image: ${IMAGE_NAME}:${BUILD_TAG}
                Environment: ${params.ENVIRONMENT}
                Commit: ${env.GIT_COMMIT_SHORT}
                Build: #${BUILD_NUMBER}
                =====================================
                """
            }
        }
        success {
            echo """
            ✅ PIPELINE SUCCEEDED!
            
            Next Steps:
            1. View image: docker pull ${IMAGE_NAME}:${BUILD_TAG}
            2. Run locally: docker run -p 3000:3000 ${IMAGE_NAME}:${BUILD_TAG}
            3. Check security: Review trivy-report.json artifact
            ${params.PUSH_IMAGE ? "4. Image pushed to GHCR ✓" : "4. Set PUSH_IMAGE=true to publish"}
            ${params.ENVIRONMENT != 'dev' && params.PUSH_IMAGE ? "5. K8s deployment updated ✓" : ""}
            """
        }
        failure {
            echo """
            ❌ PIPELINE FAILED
            
            Troubleshooting:
            1. Check console output above for errors
            2. Review stage that failed
            3. Check Docker logs: docker logs <container-id>
            4. Verify credentials if push failed
            """
        }
    }
}
