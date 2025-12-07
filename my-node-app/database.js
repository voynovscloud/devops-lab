const { Pool } = require('pg');

const dbConfig = {
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
  port: process.env.DB_PORT || 5432,
  ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false,
};

const pool = process.env.DB_HOST ? new Pool(dbConfig) : null;

const testConnection = async () => {
  if (!pool) {
    return { connected: false, message: 'Database not configured' };
  }

  try {
    const client = await pool.connect();
    const result = await client.query('SELECT NOW()');
    client.release();
    return { 
      connected: true, 
      message: 'Database connection successful',
      timestamp: result.rows[0].now
    };
  } catch (error) {
    return { 
      connected: false, 
      message: error.message 
    };
  }
};

const query = async (text, params) => {
  if (!pool) {
    throw new Error('Database not configured');
  }
  return pool.query(text, params);
};

module.exports = {
  pool,
  testConnection,
  query,
};
