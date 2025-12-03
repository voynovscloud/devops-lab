# DevOps Lab

[![GitHub Actions CI](https://github.com/voynovscloud/devops-lab/actions/workflows/ci.yml/badge.svg)](https://github.com/voynovscloud/devops-lab/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Node.js](https://img.shields.io/badge/Node.js-18-green)](https://nodejs.org/)
[![Docker](https://img.shields.io/badge/Docker-Supported-blue)](https://www.docker.com/)

A small demo DevOps lab containing a Node.js app, Prometheus, Grafana, Jenkins and other tooling wired together via `docker-compose`.

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

## Optimization Notes

The project includes several production-ready optimizations:

- **Multi-stage Docker build** — Reduces final image size
- **Non-root user** — Security best practice (appuser)
- **Health checks** — Automated container health monitoring
- **Graceful shutdown** — Proper signal handling (SIGTERM)
- **Request logging** — Timestamped request logs
- **Error handling** — Centralized error middleware
- **NPM caching** — CI caches dependencies for faster builds
- **Strict linting** — ESLint enforces code quality
- **Security scanning** — Trivy scans Docker images for vulnerabilities
- **EditorConfig** — Consistent code formatting across editors

## CI/CD

This repository includes GitHub Actions workflow that:
1. Installs dependencies with offline cache
2. Runs ESLint linting (fails on errors)
3. Runs health check tests
4. Builds Docker image
5. Scans image with Trivy for vulnerabilities
6. Uploads security results to GitHub

## CI

This repository includes a GitHub Actions workflow (`.github/workflows/ci.yml`) that runs lint, tests and builds the Docker image on push.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.

## Notes
- This repo is intended for learning and lab environments. Review secrets and ports before using in production.
