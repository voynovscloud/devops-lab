const client = require('prom-client');

client.collectDefaultMetrics({ timeout: 5000 });

const requestCounter = new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method','route','status']
});

const dbConnectionGauge = new client.Gauge({
  name: 'db_connection_status',
  help: 'Database connection status (1 = connected, 0 = disconnected)'
});

module.exports = {
  client,
  requestCounter,
  dbConnectionGauge
};
