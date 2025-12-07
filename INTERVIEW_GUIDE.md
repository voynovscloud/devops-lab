# 🎯 DevOps Lab - Interview Guide

> **Memorize these answers. Practice them out loud. This is what gets you hired.**

---

## 🔥 The 10-Second Pitch

*"I built a production-ready DevOps platform using Kubernetes, Terraform, GitOps, CI/CD pipelines, and full AWS infrastructure."*

---

## 📝 30-Second Overview

*"This is a full end-to-end DevOps platform I built from scratch. It includes a Node.js app with PostgreSQL, Docker, Kubernetes with Helm, ArgoCD for GitOps, CI/CD with GitHub Actions and Jenkins, Terraform for AWS infrastructure (VPC, EKS, RDS), and complete monitoring with Prometheus and Grafana. Everything is automated and production-ready."*

---

## 🎯 Common Interview Questions

### 1. "Walk me through your DevOps project"

**Answer (1 minute):**

*"I built a complete DevOps platform demonstrating the full application lifecycle. The application is a Node.js API with PostgreSQL integration, health checks, and Prometheus metrics.*

*For CI/CD, when I push code to GitHub, Actions automatically runs tests, builds a Docker image, pushes it to the container registry, and updates the Helm chart version. ArgoCD watches the Git repository and automatically deploys changes to Kubernetes — this is GitOps in action.*

*The infrastructure is managed as code using Terraform. On AWS, I provision a VPC with public and private subnets, an EKS cluster for Kubernetes, and RDS PostgreSQL in a private subnet for security. The entire cloud infrastructure can be created with a single 'terraform apply' command.*

*For monitoring, Prometheus scrapes metrics every 30 seconds, Grafana visualizes dashboards, and HPA auto-scales the application between 2 and 10 replicas based on CPU and memory usage. The biggest value is that everything is automated — from code push to production deployment with zero manual intervention."*

---

### 2. "What is GitOps and why did you use it?"

**Answer (30 seconds):**

*"GitOps means Git is the single source of truth for your infrastructure. I use ArgoCD which continuously monitors my Git repository. When I want to make changes — like scaling replicas or updating the image tag — I just commit to Git. ArgoCD detects the change and automatically syncs the Kubernetes cluster to match.*

*This gives me version control, full audit trails, easy rollbacks (just revert the commit), and eliminates error-prone manual kubectl commands. Plus, it enforces security because no one needs direct cluster access — they just push to Git."*

---

### 3. "Explain your CI/CD pipeline"

**Answer (35 seconds):**

*"I have GitHub Actions workflows that trigger on every push. First, it runs 'npm install' and 'npm test' to validate the code. Then it builds a Docker image using a multi-stage Dockerfile for optimization. The image is tagged with version numbers and pushed to GitHub Container Registry.*

*A separate workflow automatically bumps the Helm chart version. ArgoCD watches the Helm chart in Git, detects the version change, and deploys the new image to Kubernetes automatically. I also have Jenkins configured to show knowledge of traditional CI/CD tools. The entire pipeline is hands-off after the initial push."*

---

### 4. "Describe your AWS infrastructure"

**Answer (45 seconds):**

*"I used Terraform to provision everything as code. The architecture includes a custom VPC with 2 public subnets and 2 private subnets across two availability zones for high availability.*

*The EKS Kubernetes cluster runs in private subnets for security, with managed node groups that auto-scale based on demand. RDS PostgreSQL is also in a private subnet and only accessible from the cluster — this follows the principle of least privilege.*

*I configured NAT gateways for controlled outbound internet access and an Internet gateway for the public subnets. Application Load Balancers handle ingress traffic. The entire setup follows AWS Well-Architected Framework best practices and costs approximately $180-240 per month, which I documented for cost transparency."*

---

### 5. "How do you handle monitoring and observability?"

**Answer (25 seconds):**

*"I implemented a full monitoring stack. Prometheus is configured with ServiceMonitor for automatic pod discovery — it scrapes metrics every 30 seconds including CPU, memory, request rates, and custom application metrics.*

*Grafana connects to Prometheus and provides visualization dashboards. I also configured Horizontal Pod Autoscaler that monitors metrics and automatically scales the application between 2 and 10 replicas when CPU exceeds 60% or memory exceeds 70%. This ensures the app handles traffic spikes without manual intervention."*

---

### 6. "What about security?"

**Answer (30 seconds):**

*"Security is built in at multiple layers. The database and application run in private subnets with no direct internet access. Containers run as non-root users with read-only root filesystems. I configured resource limits to prevent resource exhaustion attacks.*

*Network policies control pod-to-pod communication. Secrets are managed through Kubernetes secrets (production would use AWS Secrets Manager or HashiCorp Vault). The entire infrastructure uses security groups and NACLs for defense in depth. Plus, GitOps means no one needs direct cluster credentials — they only push to Git."*

---

### 7. "How does auto-scaling work in your setup?"

**Answer (20 seconds):**

*"I configured Horizontal Pod Autoscaler with CPU threshold at 60% and memory at 70%. When metrics exceed these thresholds, HPA automatically increases replicas from the minimum of 2 up to a maximum of 10. When load decreases, it scales back down. This is paired with cluster autoscaler on EKS which adds or removes nodes as needed."*

---

### 8. "What happens when you push code?"

**Answer (40 seconds - walk through the flow):**

*"Here's the complete flow: I push code to GitHub. GitHub Actions triggers immediately and runs tests. If tests pass, it builds a Docker image with the new code, tags it with a version, and pushes it to GitHub Container Registry. Another workflow bumps the Helm chart version and commits it back to the repo.*

*ArgoCD polls Git every 3 minutes. It detects the Helm chart change and compares it to the current cluster state. Seeing a difference, it automatically pulls the new image and updates the Kubernetes deployment. Prometheus immediately starts monitoring the new pods, and Grafana dashboards reflect the new deployment. Zero manual intervention."*

---

### 9. "Why Helm instead of plain Kubernetes manifests?"

**Answer (25 seconds):**

*"Helm is like a package manager for Kubernetes. Instead of managing dozens of YAML files, I created one Helm chart with over 100 configurable parameters. The same chart deploys to dev, staging, or production — I just change the values file. Helm also provides easy versioning, rollbacks with 'helm rollback', and templating to avoid YAML duplication. It makes Kubernetes deployments repeatable and maintainable."*

---

### 10. "What was the hardest part?"

**Answer (30 seconds - shows problem-solving):**

*"The hardest part was understanding how all the pieces connect and troubleshooting when things broke. For example, I had a GitHub Actions CI failure because package-lock.json was missing PostgreSQL dependencies after I added database support. I had to debug the npm install process, regenerate the lock file with all dependencies, and commit it properly.*

*Another challenge was configuring ArgoCD to watch the right Git path and sync properly with Helm. But these challenges taught me the importance of reading logs, understanding error messages, and systematic troubleshooting — critical DevOps skills."*

---

### 11. "What would you improve or add next?"

**Answer (30 seconds - shows forward thinking):**

*"Several things: First, implement proper secrets management with AWS Secrets Manager or HashiCorp Vault instead of Kubernetes secrets. Second, add integration tests that run in the CI pipeline. Third, implement blue-green or canary deployments with Argo Rollouts for safer releases. Fourth, add alerting with AlertManager so Prometheus can send notifications when things go wrong. Finally, implement service mesh with Istio for advanced traffic management and security."*

---

## 🧠 Technical Deep Dives (If Asked)

### "Explain your Terraform structure"

*"I organized Terraform into modular files: main.tf for providers, vpc.tf for network setup, eks.tf for the Kubernetes cluster, rds.tf for the database, variables.tf for inputs, and outputs.tf for values I need later. I use terraform.tfvars for environment-specific values. State is stored remotely for team collaboration. This follows infrastructure-as-code best practices and makes the setup reusable across environments."*

---

### "How does ArgoCD achieve self-healing?"

*"ArgoCD has a 'selfHeal' setting enabled in my application manifest. It continuously compares Git (desired state) with the cluster (actual state). If someone manually changes a deployment — like kubectl scale — ArgoCD detects the drift within 3 minutes and reverts it back to match Git. This enforces Git as the single source of truth and prevents configuration drift."*

---

### "Explain your Docker image strategy"

*"I use multi-stage builds: first stage installs dependencies and runs tests, second stage copies only production dependencies and application code. This keeps the final image small and secure. Images are tagged with semantic versions and pushed to GitHub Container Registry. The Helm chart references the image tag, and ArgoCD pulls the exact version specified. This ensures reproducible deployments."*

---

### "How does Prometheus discover your app?"

*"I created a ServiceMonitor custom resource that tells Prometheus to scrape pods with the label 'app: node-app' on port 3000 at the '/metrics' endpoint. The kube-prometheus-stack automatically detects ServiceMonitors and configures scraping. My Node.js app exposes metrics using the prom-client library, including default Node.js metrics and custom application metrics like request counts and database connection pool status."*

---

## 💡 Key Technical Terms to Use

- **GitOps**: Declarative infrastructure where Git is source of truth
- **Infrastructure as Code (IaC)**: Managing infrastructure through code files
- **Horizontal Pod Autoscaler (HPA)**: Automatic scaling based on metrics
- **Service Mesh**: Advanced traffic management (mention if asked about improvements)
- **Immutable Infrastructure**: New versions deployed, not modified in place
- **Rolling Updates**: Zero-downtime deployments
- **Blue-Green Deployment**: Two identical environments for safe releases
- **Observability**: Metrics, logs, and traces for system insight
- **Self-Healing**: Automatic recovery from failures
- **Multi-AZ**: High availability across availability zones

---

## 🚨 Red Flags to Avoid

❌ **Don't say:** "I followed a tutorial"  
✅ **Instead:** "I researched best practices and implemented production patterns"

❌ **Don't say:** "It's just a simple app"  
✅ **Instead:** "The focus was building a production-grade DevOps pipeline"

❌ **Don't say:** "I don't know much about X"  
✅ **Instead:** "I haven't worked with X yet, but I understand the concept and it's on my learning roadmap"

❌ **Don't say:** "I used AI to generate everything"  
✅ **Instead:** "I researched documentation, troubleshot issues, and iteratively improved the setup"

---

## 📊 Metrics to Mention (Impressive Numbers)

- **Helm Chart**: 100+ configurable parameters
- **Auto-scaling**: 2-10 replicas based on load
- **Monitoring**: 30-second scrape interval
- **ArgoCD**: 3-minute sync interval
- **AWS Setup**: ~30 minutes to provision full infrastructure
- **Cost**: $180-240/month (shows business awareness)
- **Subnets**: 2 public + 2 private across 2 availability zones
- **Deployment**: Zero-downtime rolling updates
- **Container**: Multi-stage build, non-root user

---

## 🎭 Practice Scenarios

### Scenario 1: "Your app is slow in production"

**Answer:** *"First, check Grafana dashboards for CPU and memory usage. If pods are hitting resource limits, HPA should scale automatically. Check Prometheus for request latency and error rates. Look at database connection pool metrics. Review kubectl logs for errors. If needed, increase resource limits or optimize slow queries. Use kubectl top pods to see real-time resource usage."*

---

### Scenario 2: "ArgoCD shows OutOfSync"

**Answer:** *"Check kubectl describe application to see what resources differ. Compare Git with 'kubectl get' commands. Common causes: someone manually edited resources, or there's a configuration error in the Helm chart. If Git is correct, force sync with ArgoCD. If the manual change was intentional, update Git to match, or let ArgoCD revert if selfHeal is enabled."*

---

### Scenario 3: "CI pipeline is failing"

**Answer:** *"Check GitHub Actions logs for the specific failure. Common issues: test failures (fix code), Docker build errors (check Dockerfile), authentication issues (verify registry credentials), or missing dependencies (update package.json and package-lock.json). Run the same commands locally to reproduce. Once fixed, commit and the pipeline re-runs automatically."*

---

## 🎓 University/Course Context (If Asked)

**"Where did you learn this?"**

*"I learned through a combination of official documentation, hands-on practice, and troubleshooting real issues. I started with local Kubernetes on Minikube, then added CI/CD, then GitOps with ArgoCD, and finally expanded to AWS with Terraform. Each component taught me something new about how modern infrastructure works. The best learning came from things breaking and having to fix them — that's when you really understand the system."*

---

## 💼 Final Tips

1. **Practice out loud** - Say these answers in front of a mirror or record yourself
2. **Don't memorize word-for-word** - Understand the concepts and explain naturally
3. **Use the STAR method** - Situation, Task, Action, Result
4. **Show enthusiasm** - Talk about what you found interesting
5. **Be honest** - If you don't know something, say you'd research it
6. **Have questions ready** - Ask about their DevOps practices

---

## 🔗 Quick Links to Show

- **GitHub Repo**: https://github.com/voynovscloud/devops-lab
- **README**: Comprehensive documentation
- **Diagrams**: Architecture flow in README
- **Cost Sheet**: AWS cost transparency in terraform/README.md

---

**Good luck! You've got this. 🚀**

*This is production-grade work. Be confident.*
