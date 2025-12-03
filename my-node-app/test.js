const http = require('http');

const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/health',
  method: 'GET',
  timeout: 2000
};

const req = http.request(options, res => {
  if (res.statusCode === 200) {
    console.log('OK: /health responded 200');
    process.exit(0);
  } else {
    console.error('FAIL: /health returned', res.statusCode);
    process.exit(2);
  }
});

req.on('error', err => {
  console.error('ERROR: Could not reach server:', err.message);
  process.exit(1);
});

req.end();
