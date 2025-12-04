/**
 * Database Query Utilities for Cypress Testing
 *
 * This module provides direct database access for Cypress tests when API
 * endpoints are not available or when direct database operations are needed
 * for test setup and cleanup.
 *
 * @module db
 */

const mysql = require("mysql2/promise");

/**
 * Database connection configuration
 *
 * @todo Replace hardcoded credentials with environment variables
 * @type {Object}
 */
const connectionConfig = {
    host: process.env.DB_HOSTNAME || "db",
    user: process.env.DB_USER || "koha_kohadev",
    password: process.env.DB_PASSWORD || "password",
    database: process.env.DB_NAME || "koha_kohadev",
};

/**
 * Executes a SQL query with optional parameters.
 *
 * @async
 * @function query
 * @param {string} sql - SQL query string with optional parameter placeholders (?)
 * @param {Array} [params=[]] - Array of parameter values for the query
 * @returns {Promise<Array>} Query results as an array of rows
 * @throws {Error} When database connection or query execution fails
 * @description This function:
 * - Creates a new database connection for each query
 * - Uses parameterized queries to prevent SQL injection
 * - Automatically closes the connection after execution
 * - Returns the raw result rows from the database
 *
 * @example
 * // Simple SELECT query
 * const patrons = await query('SELECT * FROM borrowers LIMIT 10');
 *
 * @example
 * // Parameterized query for safety
 * const patron = await query(
 *   'SELECT * FROM borrowers WHERE borrowernumber = ?',
 *   [123]
 * );
 *
 * @example
 * // DELETE query with multiple parameters
 * await query(
 *   'DELETE FROM issues WHERE issue_id IN (?, ?, ?)',
 *   [1, 2, 3]
 * );
 */
async function query(sql, params = []) {
    const connection = await mysql.createConnection(connectionConfig);
    const [rows] = await connection.execute(sql, params);
    await connection.end();
    return rows;
}

module.exports = { query };
