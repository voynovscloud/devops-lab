pipeline {
    agent any

    stages {
        stage('Install deps in Docker') {
            agent {
                docker {
                    image 'node:18'
                    args '-v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                dir('my-node-app') {
                    sh 'npm ci'
                }
            }
        }

        stage('Build Docker image') {
            steps {
                sh 'docker build -t devops-lab-nodeapp:latest ./my-node-app'
            }
        }

        stage('Run container') {
            steps {
                sh 'docker rm -f nodeapp || true'
                sh 'docker run -d --name nodeapp -p 3000:3000 devops-lab-nodeapp:latest'
            }
        }
    }

    post {
        failure {
            echo 'Pipeline failed.'
        }
        success {
            echo 'Pipeline succeeded!'
        }
    }
}
