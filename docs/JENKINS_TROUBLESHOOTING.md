# Jenkins Pipeline Troubleshooting Guide

## Issue: "npm: not found" Error

**Problem**: Jenkins container doesn't have Node.js installed by default.

**Solution**: Use Docker-in-Docker to run Node.js commands inside containers.

## Fixed Pipeline Approach

The updated Jenkinsfile now uses Docker containers for all Node.js operations:

```groovy
// Install dependencies
docker run --rm -v $(pwd)/my-node-app:/app -w /app node:18-alpine npm ci

// Run lint
docker run --rm -v $(pwd)/my-node-app:/app -w /app node:18-alpine npm run lint

// Run tests
docker run --rm -d --name test-app -p 3000:3000 node:18-alpine npm start
docker run --rm --network host node:18-alpine npm test
docker stop test-app
```

## How to Test in Jenkins

1. **Ensure Docker is available** in Jenkins:
   - Jenkins needs Docker socket access
   - Your docker-compose already mounts: `/var/run/docker.sock:/var/run/docker.sock`

2. **Rebuild the pipeline**:
   - Go to http://localhost:8081
   - Click your pipeline job
   - Click "Build with Parameters"
   - Set:
     - ENVIRONMENT: `dev`
     - SKIP_TESTS: `false` or `true` (to test faster initially)
     - PUSH_IMAGE: `false` (don't push until working)
   - Click "Build"

3. **Check Console Output**:
   - You should see Docker commands running
   - Each stage will pull node:18-alpine and execute commands

## Expected Pipeline Flow

```
✓ Checkout              - Clone repo, get commit hash
✓ Install Dependencies  - docker run node:18-alpine npm ci
✓ Lint                  - docker run node:18-alpine npm run lint
✓ Test                  - Start app in container, run tests
✓ Build Docker Image    - docker build
✓ Security Scan         - Trivy scan
⊗ Push to Registry      - Only if PUSH_IMAGE=true
⊗ Deploy to K8s         - Only if PUSH_IMAGE=true and not dev
```

## Common Issues & Solutions

### 1. "Cannot connect to Docker daemon"
**Solution**: Verify Jenkins has Docker socket access:
```bash
docker exec jenkins docker ps
```
If error, check docker-compose.yml has:
```yaml
volumes:
  - /var/run/docker.sock:/var/run/docker.sock
```

### 2. "Permission denied" on /var/run/docker.sock
**Solution**: Add Jenkins user to docker group in container:
```bash
docker exec -u root jenkins sh -c "chmod 666 /var/run/docker.sock"
```

### 3. Test stage fails with ECONNREFUSED
**Solution**: Use `--network host` for test container to reach app on localhost:
```groovy
docker run --rm --network host -v $(pwd)/my-node-app:/app -w /app node:18-alpine npm test
```

### 4. "ghcr-credentials" not found
**Solution**: Add credentials in Jenkins:
- Manage Jenkins → Credentials → System → Global credentials
- Add → Username with password
- ID: `ghcr-credentials`
- Username: Your GitHub username
- Password: GitHub Personal Access Token with `write:packages` scope

### 5. Trivy image pull fails
**Solution**: Already using `ghcr.io/aquasecurity/trivy:latest` which is public.
If still fails, check internet connectivity from Jenkins.

## Quick Test Without Full Pipeline

Test individual stages from Jenkins container:

```bash
# Enter Jenkins container
docker exec -it jenkins sh

# Test Node.js commands
docker run --rm node:18-alpine node --version

# Test app directory access
docker run --rm -v $(pwd)/workspace/devops-lab-pipeline/my-node-app:/app -w /app node:18-alpine ls -la

# Test npm install
docker run --rm -v $(pwd)/workspace/devops-lab-pipeline/my-node-app:/app -w /app node:18-alpine npm ci
```

## Optimize Pipeline (Optional)

If builds are slow, cache node_modules:

```groovy
stage('Install Dependencies') {
    steps {
        sh """
            docker run --rm \
                -v \$(pwd)/${APP_DIR}:/app \
                -v jenkins-npm-cache:/root/.npm \
                -w /app \
                node:18-alpine npm ci --prefer-offline
        """
    }
}
```

Create the volume first:
```bash
docker volume create jenkins-npm-cache
```

## Next Steps After Pipeline Works

1. ✓ Get all stages passing with SKIP_TESTS=true
2. ✓ Enable tests with SKIP_TESTS=false
3. ✓ Set PUSH_IMAGE=true to push to GHCR
4. ✓ Set up K8s deployment (optional)
5. ✓ Add webhooks for auto-trigger on git push

## GitHub Webhook Setup (Auto-trigger)

1. GitHub repo → Settings → Webhooks → Add webhook
2. Payload URL: `http://YOUR_PUBLIC_IP:8081/github-webhook/`
3. Content type: `application/json`
4. Events: Push events
5. Active: ✓

Then in Jenkins job config:
- Build Triggers → GitHub hook trigger for GITScm polling: ✓

---

**Your pipeline should now work!** 🚀

Try rebuilding in Jenkins UI. All stages should use Docker containers for Node.js operations.
