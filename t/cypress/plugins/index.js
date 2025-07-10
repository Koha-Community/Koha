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
