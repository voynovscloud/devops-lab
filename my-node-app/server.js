const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;
const { client, requestCounter, dbConnectionGauge } = require('./metrics');
const { testConnection } = require('./database');

app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
  next();
});

app.get('/', (req, res) => {
  requestCounter.inc({ method: req.method, route: '/', status: 200 });
  res.send('Hello from Node.js Docker Project!');
});

app.get('/health', async (req, res) => {
  const dbStatus = await testConnection();
  const health = {
    status: 'ok',
    timestamp: new Date().toISOString(),
    database: dbStatus
  };
  
  dbConnectionGauge.set(dbStatus.connected ? 1 : 0);
  
  res.json(health);
});

app.get('/db-test', async (req, res) => {
  const dbStatus = await testConnection();
  dbConnectionGauge.set(dbStatus.connected ? 1 : 0);
  res.json(dbStatus);
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', client.register.contentType);
  res.end(await client.register.metrics());
});

// Error handler (eslint-disable-next-line: next param required by Express error handler signature)
// eslint-disable-next-line no-unused-vars
app.use((err, req, res, next) => {
  console.error('Error:', err.message);
  res.status(500).json({ error: 'Internal Server Error' });
});

const server = app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully...');
  server.close(() => process.exit(0));
});
