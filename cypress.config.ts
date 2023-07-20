import { defineConfig } from "cypress";

export default defineConfig({
    fixturesFolder: "t/cypress/fixtures",
    screenshotsFolder: "t/cypress/screenshots",
    videosFolder: "t/cypress/videos",
    defaultCommandTimeout: 10000,

    e2e: {
        experimentalStudio: true,
        baseUrl: "http://localhost:8081",
        specPattern: "t/cypress/integration/**/*.*",
        supportFile: "t/cypress/support/e2e.js",
    },

    component: {
        devServer: {
            framework: "vue-cli",
            bundler: "webpack",
        },
    },
});
