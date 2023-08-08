const { Pool } = require('pg')
const pool = new Pool({
    host: '45.154.26.37',
    user: 'postgres',
    port: 5432,
    password: 'Ai123456@TCS',
    database: 'posdb_uat'
});

module.exports = pool;