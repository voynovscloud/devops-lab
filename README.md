# DevOps Lab

[![GitHub Actions CI](https://github.com/voynovscloud/devops-lab/actions/workflows/ci.yml/badge.svg)](https://github.com/voynovscloud/devops-lab/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Node.js](https://img.shields.io/badge/Node.js-18-green)](https://nodejs.org/)
[![Docker](https://img.shields.io/badge/Docker-Supported-blue)](https://www.docker.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Ready-blue)](https://kubernetes.io/)

🚀 **Production-Ready DevOps Pipeline in Minutes** — Complete CI/CD setup with Jenkins, GitHub Actions, Kubernetes, and monitoring. Clone and deploy.

A professional DevOps lab featuring Node.js app, Prometheus, Grafana, Jenkins, and complete CI/CD pipelines.

## Contents
- `my-node-app/` — Node.js example app exposing Prometheus metrics and health endpoints
- `docker-compose.yml` — Local stack: node app, Prometheus, Grafana, Jenkins, cAdvisor, Portainer
- `prometheus.yml` — Prometheus scrape configuration

## Quick start

Prerequisites: `docker` and `docker-compose` installed.

Run the whole stack:

```bash
docker-compose up --build
```

## Services
- Node app: http://localhost:3000/ (metrics: `/metrics`, health: `/health`)
- Prometheus: http://localhost:9090/
- Grafana: http://localhost:3001/
- Jenkins: http://localhost:8081/

## Testing the app

```bash
curl http://localhost:3000/health
curl http://localhost:3000/metrics
```

## Development

Open `my-node-app` and use `npm install` then run `npm run dev` to start with auto-reload.

```bash
cd my-node-app
npm install
npm run dev
```

Available scripts:
- `npm start` — Start production server
- `npm run dev` — Start with auto-reload (nodemon)
- `npm run lint` — Run ESLint code quality check
- `npm run build` — Prepare build (currently no-op)
- `npm test` — Health check test against running server

## Features

✅ **Complete CI/CD**
- GitHub Actions workflow with automated testing and security scanning
- Jenkins pipeline with multi-stage builds and K8s deployment
- Container image publishing to GHCR

✅ **Kubernetes Ready**
- Production manifests with resource limits and health probes
- Multi-environment support (dev/staging/prod)
- Ingress configuration with TLS

✅ **Monitoring Stack**
- Prometheus metrics collection
- Grafana dashboards
- Container monitoring with cAdvisor

✅ **Production Hardened**
- Multi-stage Docker builds with non-root user
- Security scanning with Trivy
- Graceful shutdown and error handling
- Health checks and readiness probes

## Documentation

- 📖 [Architecture](docs/ARCHITECTURE.md) — System design and component overview
- 🚀 [Deployment Guide](docs/DEPLOY.md) — Deployment instructions and options
- 🔧 [Jenkins Setup](docs/JENKINS_SETUP.md) — Complete Jenkins CI/CD configuration
- 💰 [Monetization Strategy](docs/MONETIZATION.md) — Revenue streams and go-to-market plan

## CI/CD Pipelines

### GitHub Actions
Two workflows included:
- **CI Pipeline** (`.github/workflows/ci.yml`) — Lint, test, build, security scan on every push
- **Publish Pipeline** (`.github/workflows/publish.yml`) — Build and push images to GHCR on tags/main

### Jenkins
Production pipeline (`Jenkinsfile`) includes:
- Multi-environment support (dev/staging/prod)
- Automated testing with health checks
- Docker image building and tagging
- Security scanning with Trivy
- Push to GitHub Container Registry
- Kubernetes deployment

See [docs/JENKINS_SETUP.md](docs/JENKINS_SETUP.md) for complete setup guide.

## Kubernetes Deployment

Deploy to K8s/K3s:

```bash
kubectl apply -f k8s/deployment.yaml
kubectl get pods -n devops-lab
kubectl port-forward -n devops-lab svc/devops-lab-nodeapp 8080:80
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.

## Notes
- This repo is intended for learning and lab environments. Review secrets and ports before using in production.
