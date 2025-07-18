/**
 * Cypress Plugin Configuration
 *
 * This is the main Cypress plugin configuration file that registers all
 * testing utilities as Cypress tasks. It provides a bridge between Cypress
 * tests and the various utility modules for data generation, API access,
 * and database operations.
 *
 * @module cypress-plugins
 */

const { startDevServer } = require("@cypress/webpack-dev-server");

const { buildSampleObject, buildSampleObjects } = require("./mockData.js");

const {
    insertSampleBiblio,
    insertSampleHold,
    insertSampleCheckout,
    insertSamplePatron,
    insertObject,
    deleteSampleObjects,
} = require("./insertData.js");

const { getBasicAuthHeader } = require("./auth.js");

const { query } = require("./db.js");

const { apiGet, apiPost, apiPut, apiDelete } = require("./api-client.js");

/**
 * Cypress plugin configuration function.
 *
 * @function
 * @param {Function} on - Cypress plugin registration function
 * @param {Object} config - Cypress configuration object
 * @param {string} config.baseUrl - Base URL for the application under test
 * @param {Object} config.env - Environment variables from cypress.config.js
 * @param {string} config.env.apiUsername - Username for API authentication
 * @param {string} config.env.apiPassword - Password for API authentication
 * @returns {Object} Modified Cypress configuration
 * @description This function:
 * - Registers all testing utilities as Cypress tasks
 * - Sets up authentication headers for API calls
 * - Configures the development server for component testing
 * - Provides automatic parameter injection for common arguments
 *
 * Available Cypress tasks:
 * - Data Generation: buildSampleObject, buildSampleObjects
 * - Data Insertion: insertSampleBiblio, insertSampleHold, insertSampleCheckout, insertSamplePatron
 * - Data Cleanup: deleteSampleObjects
 * - API Access: apiGet, apiPost, apiPut, apiDelete
 * - Database Access: query
 * - Authentication: getBasicAuthHeader
 *
 * @example
 * // Usage in Cypress tests
 * cy.task('insertSampleBiblio', { item_count: 2 }).then(result => {
 *   // Test with the created biblio
 * });
 *
 * @example
 * // API call through task
 * cy.task('apiGet', { endpoint: '/api/v1/patrons' }).then(patrons => {
 *   // Work with patron data
 * });
 */
module.exports = (on, config) => {
    const baseUrl = config.baseUrl;
    const authHeader = getBasicAuthHeader(
        config.env.apiUsername,
        config.env.apiPassword
    );

    on("dev-server:start", options =>
        startDevServer({
            options,
        })
    );

    on("task", {
        getBasicAuthHeader() {
            return getBasicAuthHeader(
                config.env.apiUsername,
                config.env.apiPassword
            );
        },
        buildSampleObject,
        buildSampleObjects,
        insertSampleBiblio(args) {
            return insertSampleBiblio({ ...args, baseUrl, authHeader });
        },
        insertSampleHold(args) {
            return insertSampleHold({ ...args, baseUrl, authHeader });
        },
        insertSampleCheckout(args) {
            return insertSampleCheckout({ ...args, baseUrl, authHeader });
        },
        insertSamplePatron(args) {
            return insertSamplePatron({ ...args, baseUrl, authHeader });
        },
        insertObject(args) {
            return insertObject({ ...args, baseUrl, authHeader });
        },
        deleteSampleObjects,
        query,

        apiGet(args) {
            return apiGet({ ...args, baseUrl, authHeader });
        },
        apiPost(args) {
            return apiPost({ ...args, baseUrl, authHeader });
        },
        apiPut(args) {
            return apiPut({ ...args, baseUrl, authHeader });
        },
        apiDelete(args) {
            return apiDelete({ ...args, baseUrl, authHeader });
        },
    });
    return config;
};
