const oracledb = require('oracledb');
require('dotenv').config();

// Inicializar el cliente Oracle
try {
    oracledb.initOracleClient();
} catch (err) {
    console.error('Error al inicializar Oracle Client:', err);
}

const dbConfig = {
    user: process.env.ORACLE_USER,
    password: process.env.ORACLE_PASSWORD,
    connectString: process.env.ORACLE_DSN
};

async function getConnection() {
    try {
        const connection = await oracledb.getConnection(dbConfig);
        return connection;
    } catch (error) {
        console.error('Error connecting to database:', error);
        throw error;
    }
}

module.exports = { getConnection };