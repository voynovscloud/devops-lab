# Deploy

Quick local deploy using Docker Compose:

```bash
# build and start
docker-compose up -d --build

# stop and remove
docker-compose down --volumes --remove-orphans
```

For CI/CD: the repository contains a GitHub Actions workflow that builds and scans images. To publish images, add a GHCR or Docker Hub publish workflow and set appropriate secrets.
