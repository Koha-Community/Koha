const { startDevServer } = require("@cypress/webpack-dev-server");

const { buildSampleObject, buildSampleObjects } = require("./mockData.js");

const { query } = require("./db.js");

const { apiGet, apiPost, apiPut, apiDelete } = require("./api-client.js");

module.exports = (on, config) => {
    on("dev-server:start", options =>
        startDevServer({
            options,
        })
    );

    on("task", {
        buildSampleObject,
        buildSampleObjects,
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
