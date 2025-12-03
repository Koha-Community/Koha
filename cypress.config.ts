import { defineConfig } from "cypress";
import { devServer } from "cypress-rspack-dev-server";

export default defineConfig({
    fixturesFolder: "t/cypress/fixtures",
    screenshotsFolder: "t/cypress/screenshots",
    videosFolder: "t/cypress/videos",
    defaultCommandTimeout: 10000,
    requestTimeout: 10000,

    e2e: {
        setupNodeEvents(on, config) {
            return require("./t/cypress/plugins/index.js")(on, config);
        },
        experimentalStudio: true,
        baseUrl: process.env.KOHA_INTRANET_URL || "http://localhost:8081",
        specPattern: "t/cypress/integration/**/*.*",
        supportFile: "t/cypress/support/e2e.js",
        env: {
            opacBaseUrl: process.env.KOHA_OPAC_URL || "http://localhost:8080",
            apiUsername: process.env.KOHA_USER || "koha",
            apiPassword: process.env.KOHA_PASS || "koha",
        },
    },

    component: {
        devServer(devServerConfig) {
            return devServer({
                ...devServerConfig,
                rspackConfig: require("./rspack.config.js")[0],
            });
        },
        indexHtmlFile: "t/cypress/support/component-index.html",
        specPattern: "t/cypress/component/**/*.ts",
        supportFile: "t/cypress/support/component.ts",
    },
});
