pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "devops-lab-nodeapp:latest"
        APP_DIR = "my-node-app"
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/voynovscloud/devops-lab', branch: 'main'
            }
        }

        stage('Install dependencies') {
            steps {
                sh 'docker run --rm -v $PWD:/app -w /app node:18 npm ci'
            }
        }

        stage('Test') {
            steps {
                sh 'docker run --rm -v $PWD:/app -w /app node:18 npm test || true'
            }
        }

        stage('Build Docker image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE} ./my-node-app"
            }
        }

        stage('Run container (smoke test)') {
            steps {
                sh """
                docker run --rm -d --name nodeapp-test -p 3000:3000 ${DOCKER_IMAGE}
                sleep 5
                curl -f http://localhost:3000/ || exit 1
                docker stop nodeapp-test
                """
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline finished successfully!"
        }
        failure {
            echo "❌ Pipeline failed. Check logs!"
        }
    }
}
