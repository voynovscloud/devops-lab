# Architecture

This repo contains:

- `my-node-app/`: Node.js Express app exposing `/`, `/health`, `/metrics`.
- `docker-compose.yml`: local stack (Prometheus, Grafana, Jenkins, Portainer, cAdvisor) to run for demos.
- `.github/workflows/ci.yml`: CI pipeline for lint, tests, build and Trivy scan.

Design decisions:
- Multi-stage Dockerfile for smaller images
- Non-root runtime user for security
- Prometheus for metrics collection; Grafana for visualization
- Trivy for vulnerability scanning
