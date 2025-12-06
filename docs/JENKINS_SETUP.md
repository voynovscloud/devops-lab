# Jenkins CI/CD Setup Guide

## Prerequisites
- Jenkins running (use `docker-compose up -d` to start from this repo)
- Jenkins at http://localhost:8081
- Docker installed on Jenkins agent
- kubectl configured (for K8s deployments)

## Initial Jenkins Configuration

### 1. Install Required Plugins
Navigate to: Manage Jenkins → Plugins → Available plugins

Install:
- Docker Pipeline
- Kubernetes CLI
- Git
- Pipeline
- Credentials Binding
- Blue Ocean (optional, for better UI)

### 2. Configure Credentials

#### GitHub Credentials (for SCM)
1. Manage Jenkins → Credentials → System → Global credentials
2. Add Credentials → Username with password
3. ID: `github-credentials`
4. Username: your GitHub username
5. Password: Personal Access Token (create at github.com/settings/tokens)

#### GHCR (GitHub Container Registry) Credentials
1. Add Credentials → Username with password
2. ID: `ghcr-credentials`
3. Username: your GitHub username
4. Password: Personal Access Token with `write:packages` scope

#### Kubernetes Config (if deploying to K8s)
1. Add Credentials → Secret file
2. ID: `kubeconfig`
3. Upload your `~/.kube/config` file

### 3. Create Pipeline Job

1. New Item → Pipeline → Name: "devops-lab-pipeline"
2. Pipeline section:
   - Definition: Pipeline script from SCM
   - SCM: Git
   - Repository URL: https://github.com/voynovscloud/devops-lab.git
   - Branch: */main
   - Script Path: Jenkinsfile
3. Build Triggers:
   - Poll SCM: `H/5 * * * *` (every 5 minutes)
   - Or use GitHub webhook
4. Save

### 4. Configure Parameters (Optional)
The Jenkinsfile includes parameters that will appear after first run:
- ENVIRONMENT: dev/staging/prod
- SKIP_TESTS: Skip test stage
- PUSH_IMAGE: Push to container registry

### 5. First Run

1. Click "Build with Parameters"
2. Select:
   - ENVIRONMENT: dev
   - SKIP_TESTS: false
   - PUSH_IMAGE: false (don't push on first run)
3. Click "Build"
4. Monitor Console Output

### 6. Enable Image Push

Once the pipeline succeeds locally:
1. Click "Build with Parameters"
2. Set PUSH_IMAGE: true
3. Build

The image will be pushed to: `ghcr.io/voynovscloud/devops-lab-nodeapp:latest`

## Pipeline Stages Explained

```
1. Checkout          - Clone repository
2. Install Deps      - npm ci in my-node-app/
3. Lint              - ESLint code quality
4. Test              - Start app, run health tests
5. Build Image       - docker build with multiple tags
6. Security Scan     - Trivy vulnerability scan
7. Push to Registry  - Push to GHCR (if PUSH_IMAGE=true)
8. Deploy to K8s     - kubectl set image (if staging/prod)
```

## Kubernetes Deployment

### Setup K3s (Lightweight Kubernetes)

```bash
# Install K3s
curl -sfL https://get.k3s.io | sh -

# Get kubeconfig
sudo cat /var/lib/rancher/k3s/server/node-token
sudo k3s kubectl config view --raw > ~/.kube/config

# Verify
kubectl get nodes
```

### Deploy Application

```bash
# Create namespace and deploy
kubectl apply -f k8s/deployment.yaml

# Check status
kubectl get pods -n devops-lab
kubectl get svc -n devops-lab

# Get logs
kubectl logs -f deployment/devops-lab-nodeapp -n devops-lab

# Port-forward to test
kubectl port-forward -n devops-lab svc/devops-lab-nodeapp 8080:80
curl http://localhost:8080/health
```

### Update Deployment from Jenkins

The Jenkinsfile includes a K8s deploy stage:
```groovy
kubectl set image deployment/devops-lab-nodeapp \
    devops-lab-nodeapp=${IMAGE_NAME}:${BUILD_TAG} \
    -n ${ENVIRONMENT}
```

This updates the running deployment with the new image.

## Troubleshooting

### Pipeline fails at Test stage
- Check my-node-app/server.log in Jenkins workspace
- Ensure port 3000 is available
- Verify Node.js is installed on agent

### Docker build fails
- Check Dockerfile exists in my-node-app/
- Verify Docker daemon is running
- Check Jenkins user has Docker permissions: `sudo usermod -aG docker jenkins`

### Push to registry fails
- Verify ghcr-credentials are configured
- Check token has write:packages scope
- Test login: `echo $TOKEN | docker login ghcr.io -u USERNAME --password-stdin`

### K8s deployment fails
- Verify kubectl is configured: `kubectl get nodes`
- Check namespace exists: `kubectl get ns devops-lab`
- Verify image pull secrets if using private registry

## Webhook Setup (Auto-trigger on Push)

### GitHub Webhook
1. GitHub repo → Settings → Webhooks → Add webhook
2. Payload URL: `http://YOUR_JENKINS_URL:8081/github-webhook/`
3. Content type: application/json
4. Events: Just the push event
5. Active: ✓
6. Save

### Jenkins Configuration
1. Pipeline → Configure
2. Build Triggers → GitHub hook trigger for GITScm polling: ✓
3. Save

Now pushes to main will trigger the pipeline automatically.

## Production Best Practices

- Use separate credentials per environment (dev/staging/prod)
- Enable approval gates for production deployments
- Set up notifications (Slack, email)
- Archive artifacts (trivy-report.json, test results)
- Use Jenkins declarative pipeline syntax
- Pin Docker image versions in K8s
- Implement rollback strategy
- Monitor Jenkins logs and disk space

## Next Steps

1. Set up Prometheus to monitor Jenkins
2. Add integration tests stage
3. Implement blue-green or canary deployments
4. Add Slack/email notifications
5. Set up Jenkins backup
