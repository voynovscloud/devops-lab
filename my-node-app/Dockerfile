FROM node:18-alpine AS builder
WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

# Install dev dependencies and allow optional build steps
RUN npm run build || true

FROM node:18-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production

COPY --from=builder /app /app

RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
	CMD node -e "require('http').get('http://localhost:3000/health', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)}).on('error', () => process.exit(1))" || exit 1

LABEL org.opencontainers.image.source="https://github.com/voynovscloud/devops-lab"

CMD ["node", "server.js"]
