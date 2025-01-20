const { startDevServer } = require("@cypress/webpack-dev-server");
const webpackConfig = require("@vue/cli-service/webpack.config.js");

const mysql = require("cypress-mysql");

const { buildSampleObject, buildSampleObjects } = require("./mockData.js");

module.exports = (on, config) => {
    on("dev-server:start", options =>
        startDevServer({
            options,
            webpackConfig,
        })
    );

    mysql.configurePlugin(on);

    on("task", {
        buildSampleObject,
        buildSampleObjects,
    });
    return config;
};
