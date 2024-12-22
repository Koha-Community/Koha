import { defineConfig } from "cypress";

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
        baseUrl: "http://localhost:8081",
        specPattern: "t/cypress/integration/**/*.*",
        supportFile: "t/cypress/support/e2e.js",
        env: {
            db: {
                host: "db",
                user: "koha_kohadev",
                password: "password",
                database: "koha_kohadev",
            },
        },
    },
});
