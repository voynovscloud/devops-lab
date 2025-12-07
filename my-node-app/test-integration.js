const http = require('http');

// Configuration
const APP_HOST = process.env.APP_HOST || 'localhost';
const APP_PORT = process.env.APP_PORT || 3000;
const BASE_URL = `http://${APP_HOST}:${APP_PORT}`;

// Test results
let passed = 0;
let failed = 0;

// Helper function to make HTTP requests
function makeRequest(path, method = 'GET') {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: APP_HOST,
      port: APP_PORT,
      path: path,
      method: method,
      timeout: 5000
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => {
        resolve({
          statusCode: res.statusCode,
          headers: res.headers,
          body: data
        });
      });
    });

    req.on('error', reject);
    req.on('timeout', () => {
      req.destroy();
      reject(new Error('Request timeout'));
    });

    req.end();
  });
}

// Test functions
async function testHealthEndpoint() {
  console.log('\n🧪 Testing /health endpoint...');
  try {
    const response = await makeRequest('/health');
    
    if (response.statusCode !== 200) {
      throw new Error(`Expected status 200, got ${response.statusCode}`);
    }

    const data = JSON.parse(response.body);
    if (data.status !== 'healthy') {
      throw new Error(`Expected status "healthy", got "${data.status}"`);
    }

    if (!data.timestamp) {
      throw new Error('Missing timestamp in response');
    }

    console.log('✅ Health endpoint test PASSED');
    console.log(`   Response: ${JSON.stringify(data)}`);
    passed++;
  } catch (error) {
    console.log(`❌ Health endpoint test FAILED: ${error.message}`);
    failed++;
  }
}

async function testDatabaseEndpoint() {
  console.log('\n🧪 Testing /db-test endpoint...');
  try {
    const response = await makeRequest('/db-test');
    
    if (response.statusCode !== 200) {
      throw new Error(`Expected status 200, got ${response.statusCode}`);
    }

    const data = JSON.parse(response.body);
    
    // Check if database is configured
    if (process.env.DB_ENABLED === 'true') {
      if (!data.message || !data.message.includes('successful')) {
        throw new Error('Database connection test failed');
      }
    }

    console.log('✅ Database endpoint test PASSED');
    console.log(`   Response: ${JSON.stringify(data)}`);
    passed++;
  } catch (error) {
    console.log(`❌ Database endpoint test FAILED: ${error.message}`);
    failed++;
  }
}

async function testMetricsEndpoint() {
  console.log('\n🧪 Testing /metrics endpoint...');
  try {
    const response = await makeRequest('/metrics');
    
    if (response.statusCode !== 200) {
      throw new Error(`Expected status 200, got ${response.statusCode}`);
    }

    const body = response.body;
    
    // Verify Prometheus format
    if (!body.includes('# HELP') || !body.includes('# TYPE')) {
      throw new Error('Invalid Prometheus metrics format');
    }

    // Check for required metrics
    const requiredMetrics = [
      'process_cpu_user_seconds_total',
      'nodejs_heap_size_used_bytes',
      'http_requests_total'
    ];

    for (const metric of requiredMetrics) {
      if (!body.includes(metric)) {
        throw new Error(`Missing required metric: ${metric}`);
      }
    }

    console.log('✅ Metrics endpoint test PASSED');
    console.log(`   Found ${body.split('\n').length} lines of metrics`);
    passed++;
  } catch (error) {
    console.log(`❌ Metrics endpoint test FAILED: ${error.message}`);
    failed++;
  }
}

async function testInvalidEndpoint() {
  console.log('\n🧪 Testing invalid endpoint (404 handling)...');
  try {
    const response = await makeRequest('/invalid-endpoint');
    
    if (response.statusCode !== 404) {
      throw new Error(`Expected status 404, got ${response.statusCode}`);
    }

    console.log('✅ 404 handling test PASSED');
    passed++;
  } catch (error) {
    console.log(`❌ 404 handling test FAILED: ${error.message}`);
    failed++;
  }
}

async function testConcurrentRequests() {
  console.log('\n🧪 Testing concurrent requests...');
  try {
    const requests = [];
    for (let i = 0; i < 10; i++) {
      requests.push(makeRequest('/health'));
    }

    const results = await Promise.all(requests);
    
    const allSuccessful = results.every(r => r.statusCode === 200);
    if (!allSuccessful) {
      throw new Error('Not all concurrent requests succeeded');
    }

    console.log('✅ Concurrent requests test PASSED');
    console.log(`   Successfully handled ${requests.length} concurrent requests`);
    passed++;
  } catch (error) {
    console.log(`❌ Concurrent requests test FAILED: ${error.message}`);
    failed++;
  }
}

async function testResponseHeaders() {
  console.log('\n🧪 Testing response headers...');
  try {
    const response = await makeRequest('/health');
    
    if (response.headers['content-type'] !== 'application/json; charset=utf-8') {
      throw new Error(`Expected JSON content-type, got ${response.headers['content-type']}`);
    }

    console.log('✅ Response headers test PASSED');
    passed++;
  } catch (error) {
    console.log(`❌ Response headers test FAILED: ${error.message}`);
    failed++;
  }
}

// Wait for server to be ready
async function waitForServer(maxAttempts = 10, delay = 2000) {
  console.log(`\n⏳ Waiting for server at ${BASE_URL}...`);
  
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      await makeRequest('/health');
      console.log('✅ Server is ready!\n');
      return true;
    } catch (error) {
      console.log(`   Attempt ${attempt}/${maxAttempts}: Server not ready yet...`);
      if (attempt < maxAttempts) {
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  }
  
  throw new Error(`Server did not become ready after ${maxAttempts} attempts`);
}

// Main test runner
async function runTests() {
  console.log('=================================');
  console.log('  Integration Tests');
  console.log('=================================');
  console.log(`Target: ${BASE_URL}`);
  
  try {
    await waitForServer();
    
    // Run all tests
    await testHealthEndpoint();
    await testDatabaseEndpoint();
    await testMetricsEndpoint();
    await testInvalidEndpoint();
    await testConcurrentRequests();
    await testResponseHeaders();
    
    // Print summary
    console.log('\n=================================');
    console.log('  Test Summary');
    console.log('=================================');
    console.log(`✅ Passed: ${passed}`);
    console.log(`❌ Failed: ${failed}`);
    console.log(`📊 Total:  ${passed + failed}`);
    console.log('=================================\n');
    
    if (failed > 0) {
      process.exit(1);
    }
    
    console.log('🎉 All tests passed!');
    process.exit(0);
    
  } catch (error) {
    console.log(`\n❌ Test execution failed: ${error.message}`);
    process.exit(1);
  }
}

// Run tests
runTests();
