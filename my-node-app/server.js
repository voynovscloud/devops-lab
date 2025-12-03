const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;
const { client, requestCounter } = require('./metrics');

app.get('/', (req, res) => {
  requestCounter.inc({ method: req.method, route: '/', status: 200 });
  res.send('Hello from Node.js Docker Project!');
});

// Health
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// Prometheus metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', client.register.contentType);
  res.end(await client.register.metrics());
});

app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
