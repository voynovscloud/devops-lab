const http = require('http');

// Retryable health check targeting IPv4 to avoid IPv6 ::1 issues on some runners
const options = (port = 3000) => ({
  hostname: '127.0.0.1',
  port,
  path: '/health',
  method: 'GET',
  timeout: 2000
});

const maxRetries = 10;
const delayMs = 1000;

function checkOnce(cb) {
  const req = http.request(options(), (res) => {
    let data = '';
    res.on('data', (chunk) => { data += chunk; });
    res.on('end', () => {
      cb(null, { statusCode: res.statusCode, body: data });
    });
  });

  req.on('error', (err) => cb(err));
  req.on('timeout', () => { req.destroy(); cb(new Error('timeout')); });
  req.end();
}

let attempt = 0;
function run() {
  attempt++;
  checkOnce((err, res) => {
    if (!err && res && res.statusCode === 200) {
      console.log('✓ Health check passed:', res.body);
      process.exit(0);
    }

    if (attempt >= maxRetries) {
      console.error('✗ Health check failed after', attempt, 'attempts', err ? err.message : `status ${res && res.statusCode}`);
      process.exit(1);
    }

    const wait = delayMs * attempt;
    console.log(`Health check attempt ${attempt} failed${err ? `: ${err.message}` : ''}. Retrying in ${wait}ms...`);
    setTimeout(run, wait);
  });
}

run();
