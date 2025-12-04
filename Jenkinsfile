pipeline {
    agent any

    environment {
        IMAGE_NAME = "devops-lab-nodeapp:latest"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker image') {
            steps {
                echo "Building Docker image ${env.IMAGE_NAME}"
                sh "docker build -t ${env.IMAGE_NAME} ./my-node-app"
            }
        }

        stage('Optional: run container smoke test') {
            steps {
                echo "Running quick smoke test (container should start and exit quickly)"
                // Запускаме контейнера в отделен namespace и проверяваме че образа стартира
                sh '''
                  set -e
                  cid=$(docker create ${IMAGE_NAME})
                  docker start $cid
                  sleep 2
                  # опционално: docker logs $cid
                  docker rm -f $cid || true
                '''
            }
            when {
                expression { return true } // сменяш на false ако не искаш тест
            }
        }
    }

    post {
        success {
            echo "Build finished successfully."
        }
        failure {
            echo "Build failed."
        }
    }
}
