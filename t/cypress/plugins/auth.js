/**
 * Authentication utilities for Cypress testing
 *
 * This module provides authentication helper functions for use in Cypress tests
 * when making API calls that require authentication.
 *
 * @module auth
 */

const { Buffer } = require("buffer");

/**
 * Generates a Basic Authentication header from username and password.
 *
 * @function getBasicAuthHeader
 * @param {string} username - Username for authentication
 * @param {string} password - Password for authentication
 * @returns {string} Basic authentication header value in format "Basic <base64>"
 * @example
 * // Generate auth header for API calls
 * const authHeader = getBasicAuthHeader('koha', 'koha');
 * // Returns: "Basic a29oYTprb2hh"
 *
 * // Use with API client
 * const response = await apiGet({
 *   baseUrl: 'http://localhost:8081',
 *   endpoint: '/api/v1/patrons',
 *   authHeader: getBasicAuthHeader('koha', 'koha')
 * });
 */
const getBasicAuthHeader = (username, password) => {
    const credentials = Buffer.from(`${username}:${password}`).toString(
        "base64"
    );
    return `Basic ${credentials}`;
};

module.exports = {
    getBasicAuthHeader,
};
