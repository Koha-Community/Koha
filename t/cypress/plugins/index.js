const { startDevServer } = require('@cypress/webpack-dev-server')

module.exports = (on, config) => {
    on('dev-server:start', options =>
      startDevServer({
        options,
      })
    )

    return config;
};

const mysql = require("cypress-mysql");

module.exports = (on, config) => {
    mysql.configurePlugin(on);
};

const { buildSampleObject, buildSampleObjects } = require("./mockData.js");

module.exports = (on, config) => {
    on("task", {
        buildSampleObject,
        buildSampleObjects,
    });
    return config;
};
