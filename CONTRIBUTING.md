# Contributing

Thank you for your interest in contributing to the DevOps Lab project!

## Getting Started

1. Clone the repository
2. Install dependencies in `my-node-app/`:
   ```bash
   cd my-node-app
   npm install
   ```
3. Run the app locally:
   ```bash
   npm run dev
   ```
4. Run linting and tests:
   ```bash
   npm run lint
   npm test
   ```

## Running the Full Stack

From the repo root:
```bash
docker-compose up --build
```

## Code Style

- Use ESLint for linting (run `npm run lint`)
- Follow Node.js best practices
- Add tests for new features

## Testing

Before submitting a PR:
1. Run `npm test` to verify the app is healthy
2. Check that Docker builds without errors: `docker build -t devops-lab:test ./my-node-app`
3. Ensure no lint errors: `npm run lint`

## Submitting Changes

1. Create a feature branch
2. Make your changes and commit
3. Push to your fork
4. Open a pull request with a clear description

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
