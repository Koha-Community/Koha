const { startDevServer } = require("@cypress/webpack-dev-server");

const { buildSampleObject, buildSampleObjects } = require("./mockData.js");

const {
    insertSampleBiblio,
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
        insertSampleBiblio({ item_count }) {
            return insertSampleBiblio(item_count, baseUrl, authHeader);
        },
        insertObject({ type, object }) {
            return insertObject(type, object, baseUrl, authHeader);
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
