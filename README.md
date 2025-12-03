# DevOps Lab

A small demo DevOps lab containing a Node.js app, Prometheus, Grafana, Jenkins and other tooling wired together via `docker-compose`.

Contents
- `my-node-app/` — Node.js example app exposing Prometheus metrics and health endpoints
- `docker-compose.yml` — Local stack: node app, Prometheus, Grafana, Jenkins, cAdvisor, Portainer
- `prometheus.yml` — Prometheus scrape configuration

Quick start

Prerequisites: `docker` and `docker-compose` installed.

Run the whole stack:

```bash
docker-compose up --build
```

Services
- Node app: http://localhost:3000/ (metrics: `/metrics`, health: `/health`)
- Prometheus: http://localhost:9090/
- Grafana: http://localhost:3001/
- Jenkins: http://localhost:8081/

Testing the app

```bash
curl http://localhost:3000/health
curl http://localhost:3000/metrics
```

Development

Open `my-node-app` and use `npm install` then run `npm run dev` to start with auto-reload.

CI

This repository includes a GitHub Actions workflow (`.github/workflows/ci.yml`) that runs lint, tests and builds the Docker image on push.

Notes
- This repo is intended for learning and lab environments. Review secrets and ports before using in production.
