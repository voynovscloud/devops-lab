pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Install dependencies') {
            steps {
                dir('my-node-app') {
                    sh 'npm ci'
                    sh 'npm test || true'
                }
            }
        }

        stage('Build Docker image') {
            steps {
                dir('my-node-app') {
                    sh 'docker build -t devops-lab-nodeapp:latest .'
                }
            }
        }

        stage('Run Docker container') {
            steps {
                sh 'docker rm -f nodeapp || true'
                sh 'docker run -d --name nodeapp -p 3000:3000 devops-lab-nodeapp:latest'
            }
        }
    }

    post {
        success {
            echo 'Pipeline finished successfully!'
        }
        failure {
            echo 'Pipeline failed. Check logs.'
        }
    }
}
