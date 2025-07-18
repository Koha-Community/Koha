/**
 * Koha API Client for Cypress Testing
 *
 * This module provides a wrapper around the Koha API client for use in Cypress tests.
 * It handles authentication, request preparation, and provides convenient methods
 * for making API calls during test execution.
 *
 * @module api-client
 */

const { APIClient } = require("./dist/api-client.cjs.js");

const client = APIClient.default.koha;

/**
 * Prepares request parameters for API calls by extracting and organizing headers and URL.
 *
 * @function prepareRequest
 * @param {Object} params - Request parameters
 * @param {string} params.baseUrl - Base URL for the API
 * @param {string} params.endpoint - API endpoint path
 * @param {string} [params.authHeader] - Authorization header value
 * @param {Object} [params.headers={}] - Additional headers to include
 * @param {...*} params.rest - Other parameters to pass through
 * @returns {Object} Prepared request object
 * @returns {string} returns.url - Complete URL for the request
 * @returns {Object} returns.headers - Combined headers object
 * @returns {Object} returns.rest - Pass-through parameters
 * @private
 */
const prepareRequest = params => {
    const { baseUrl, endpoint, authHeader, headers = {}, ...rest } = params;
    const url = baseUrl + endpoint;
    const finalHeaders = {
        ...headers,
        ...(authHeader ? { Authorization: authHeader } : {}),
    };
    return { url, headers: finalHeaders, rest };
};

/**
 * Performs a GET request to the Koha API.
 *
 * @function apiGet
 * @param {Object} params - Request parameters
 * @param {string} params.baseUrl - Base URL for the API
 * @param {string} params.endpoint - API endpoint path
 * @param {string} [params.authHeader] - Authorization header value
 * @param {Object} [params.headers={}] - Additional headers to include
 * @param {...*} params.rest - Additional parameters for the request
 * @returns {Promise<*>} API response data
 * @example
 * // Get a list of patrons
 * const patrons = await apiGet({
 *   baseUrl: 'http://localhost:8081',
 *   endpoint: '/api/v1/patrons',
 *   authHeader: 'Basic dGVzdDp0ZXN0'
 * });
 *
 * @example
 * // Get a specific patron with query parameters
 * const patron = await apiGet({
 *   baseUrl: 'http://localhost:8081',
 *   endpoint: '/api/v1/patrons?q={"patron_id":123}',
 *   authHeader: 'Basic dGVzdDp0ZXN0'
 * });
 */
const apiGet = params => {
    const { url, headers, rest } = prepareRequest(params);
    return client.get({
        endpoint: url,
        headers,
        ...rest,
    });
};

/**
 * Performs a POST request to the Koha API.
 *
 * @function apiPost
 * @param {Object} params - Request parameters
 * @param {string} params.baseUrl - Base URL for the API
 * @param {string} params.endpoint - API endpoint path
 * @param {string} [params.authHeader] - Authorization header value
 * @param {Object} [params.headers={}] - Additional headers to include
 * @param {Object} [params.body] - Request body data
 * @param {...*} params.rest - Additional parameters for the request
 * @returns {Promise<*>} API response data
 * @example
 * // Create a new patron
 * const newPatron = await apiPost({
 *   baseUrl: 'http://localhost:8081',
 *   endpoint: '/api/v1/patrons',
 *   authHeader: 'Basic dGVzdDp0ZXN0',
 *   body: {
 *     firstname: 'John',
 *     surname: 'Doe',
 *     library_id: 'CPL',
 *     category_id: 'PT'
 *   }
 * });
 */
const apiPost = params => {
    const { url, headers, rest } = prepareRequest(params);
    return client.post({
        endpoint: url,
        headers,
        ...rest,
    });
};

/**
 * Performs a PUT request to the Koha API.
 *
 * @function apiPut
 * @param {Object} params - Request parameters
 * @param {string} params.baseUrl - Base URL for the API
 * @param {string} params.endpoint - API endpoint path
 * @param {string} [params.authHeader] - Authorization header value
 * @param {Object} [params.headers={}] - Additional headers to include
 * @param {Object} [params.body] - Request body data
 * @param {...*} params.rest - Additional parameters for the request
 * @returns {Promise<*>} API response data
 * @example
 * // Update a patron
 * const updatedPatron = await apiPut({
 *   baseUrl: 'http://localhost:8081',
 *   endpoint: '/api/v1/patrons/123',
 *   authHeader: 'Basic dGVzdDp0ZXN0',
 *   body: {
 *     email: 'newemail@example.com'
 *   }
 * });
 */
const apiPut = params => {
    const { url, headers, rest } = prepareRequest(params);
    return client.put({
        endpoint: url,
        headers,
        ...rest,
    });
};

/**
 * Performs a DELETE request to the Koha API.
 *
 * @function apiDelete
 * @param {Object} params - Request parameters
 * @param {string} params.baseUrl - Base URL for the API
 * @param {string} params.endpoint - API endpoint path
 * @param {string} [params.authHeader] - Authorization header value
 * @param {Object} [params.headers={}] - Additional headers to include
 * @param {...*} params.rest - Additional parameters for the request
 * @returns {Promise<*>} API response data
 * @example
 * // Delete a patron
 * await apiDelete({
 *   baseUrl: 'http://localhost:8081',
 *   endpoint: '/api/v1/patrons/123',
 *   authHeader: 'Basic dGVzdDp0ZXN0'
 * });
 */
const apiDelete = params => {
    const { url, headers, rest } = prepareRequest(params);
    return client.delete({
        endpoint: url,
        headers,
        ...rest,
    });
};

module.exports = {
    apiGet,
    apiPost,
    apiPut,
    apiDelete,
};
