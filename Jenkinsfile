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
        
        stage('Install Dependencies') {
            steps {
                echo 'Installing Node.js dependencies...'
                dir('my-node-app') {
                    sh """
                        docker run --rm -v /var/jenkins_home/workspace/devops-lab-pipeline/my-node-app:/app -w /app node:18-alpine npm ci --prefer-offline --no-audit
                    """
                }
            }
        }
        
        stage('Lint') {
            steps {
                echo 'Running ESLint...'
                dir('my-node-app') {
                    sh """
                        docker run --rm -v /var/jenkins_home/workspace/devops-lab-pipeline/my-node-app:/app -w /app node:18-alpine npm run lint
                    """
                }
            }
        }
        
        stage('Test') {
            when {
                expression { return !params.SKIP_TESTS }
            }
            steps {
                echo 'Running tests in Docker...'
                sh """
                    docker run --rm -d --name test-app-${BUILD_NUMBER} -p 3000:3000 -v /var/jenkins_home/workspace/devops-lab-pipeline/my-node-app:/app -w /app node:18-alpine sh -c 'npm start'
                    
                    for i in {1..30}; do
                        if curl -sf http://127.0.0.1:3000/health >/dev/null 2>&1; then
                            echo "App is ready"
                            break
                        fi
                        echo "Waiting for app... (\$i/30)"
                        sleep 1
                    done
                    
                    docker run --rm --network host -v /var/jenkins_home/workspace/devops-lab-pipeline/my-node-app:/app -w /app node:18-alpine npm test
                    
                    docker stop test-app-${BUILD_NUMBER} || true
                    docker rm test-app-${BUILD_NUMBER} || true
                """
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
        }
        success {
            echo "✓ Pipeline succeeded! Image: ${IMAGE_NAME}:${BUILD_TAG}"
        }
        failure {
            echo '✗ Pipeline failed'
        }
    }
}
