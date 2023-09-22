import { defineConfig } from "cypress";

export default defineConfig({
    fixturesFolder: "t/cypress/fixtures",
    screenshotsFolder: "t/cypress/screenshots",
    videosFolder: "t/cypress/videos",
    defaultCommandTimeout: 10000,

    e2e: {
        experimentalStudio: true,
        baseUrl: "http://kohadev-intra.mydnsname.org:8081",
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

    component: {
        devServer: {
            framework: "vue-cli",
            bundler: "webpack",
        },
    },
});
