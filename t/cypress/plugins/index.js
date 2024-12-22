const { startDevServer } = require('@cypress/webpack-dev-server')

const mysql = require("cypress-mysql");

const { buildSampleObject, buildSampleObjects } = require("./mockData.js");

module.exports = (on, config) => {
    on('dev-server:start', options =>
      startDevServer({
        options,
      })
    )

    mysql.configurePlugin(on);

    on("task", {
        buildSampleObject,
        buildSampleObjects,
    });
    return config;
};
