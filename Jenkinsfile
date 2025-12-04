pipeline {
agent any
environment {
APP_NAME = "devops-lab-nodeapp"
APP_DIR = "./my-node-app"
}
stages {
stage('Checkout') {
steps {
echo 'Cloning repository...'
checkout scm
}
}

```
    stage('Build Docker image') {
        steps {
            echo 'Building Docker image...'
            sh """
            if [ -f ${APP_DIR}/Dockerfile ]; then
                docker build -t ${APP_NAME}:latest ${APP_DIR}
            else
                echo "No Dockerfile found, skipping build"
            fi
            """
        }
    }

    stage('Run container (smoke test)') {
        steps {
            echo 'Running container briefly to check build...'
            sh """
            if docker images | grep -q ${APP_NAME}; then
                docker run --rm -d --name ${APP_NAME}-smoke ${APP_NAME}:latest
                sleep 5
                docker logs ${APP_NAME}-smoke || true
                docker stop ${APP_NAME}-smoke || true
            else
                echo "No image found, skipping run"
            fi
            """
        }
    }
}

post {
    always {
        echo 'Pipeline finished'
    }
}
```

}
