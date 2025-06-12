const { startDevServer } = require("@cypress/webpack-dev-server");

const { buildSampleObject, buildSampleObjects } = require("./mockData.js");

const { query } = require("./db.js");

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
    });
    return config;
};
