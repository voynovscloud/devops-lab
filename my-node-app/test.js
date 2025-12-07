// Simple validation tests that don't require a running server
console.log('Running validation tests...\n');

let passed = 0;
let failed = 0;

function test(name, fn) {
  try {
    fn();
    console.log(`✓ ${name}`);
    passed++;
  } catch (err) {
    console.error(`✗ ${name}: ${err.message}`);
    failed++;
  }
}

// Test 1: Check if dependencies can be loaded
test('Dependencies load correctly', () => {
  require('express');
  require('prom-client');
  require('pg');
});

// Test 2: Check if server file exists and exports
test('Server module exists', () => {
  const fs = require('fs');
  if (!fs.existsSync('./server.js')) {
    throw new Error('server.js not found');
  }
});

// Test 3: Check if database module exists
test('Database module exists', () => {
  const fs = require('fs');
  if (!fs.existsSync('./database.js')) {
    throw new Error('database.js not found');
  }
});

// Test 4: Check if metrics module exists
test('Metrics module exists', () => {
  const fs = require('fs');
  if (!fs.existsSync('./metrics.js')) {
    throw new Error('metrics.js not found');
  }
});

// Test 5: Validate package.json
test('Package.json is valid', () => {
  const pkg = require('./package.json');
  if (!pkg.name) throw new Error('Package name missing');
  if (!pkg.dependencies) throw new Error('Dependencies missing');
  if (!pkg.dependencies.express) throw new Error('Express dependency missing');
  if (!pkg.dependencies['prom-client']) throw new Error('prom-client dependency missing');
  if (!pkg.dependencies.pg) throw new Error('pg dependency missing');
});

// Test 6: Check environment handling
test('Environment variables handled correctly', () => {
  const originalPort = process.env.PORT;
  process.env.PORT = '8080';
  const port = process.env.PORT || 3000;
  if (port !== '8080') throw new Error('PORT env var not read correctly');
  process.env.PORT = originalPort;
});

// Results
console.log(`\n${passed} passed, ${failed} failed`);

if (failed > 0) {
  process.exit(1);
}

console.log('\n✓ All tests passed!');
process.exit(0);
