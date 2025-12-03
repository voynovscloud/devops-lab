const client = require('prom-client');

// Default metrics (CPU, memory etc.)
client.collectDefaultMetrics({ timeout: 5000 });

// Create a custom counter as example
const requestCounter = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method','route','status']
});

module.exports = {
  client,
  requestCounter
};
