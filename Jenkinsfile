pipeline {
  agent any
  stages {
    stage('Checkout') {
      steps { checkout scm }
    }
    stage('Build') {
      steps {
        dir('my-node-app') {
          sh 'npm ci'
          sh 'npm test || true'
        }
        sh 'docker build -t devops-lab-nodeapp:latest ./my-node-app'
      }
    }
  }
}
