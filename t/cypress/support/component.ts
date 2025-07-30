// ***********************************************************
// This example support/component.ts is processed and
// loaded automatically before your test files.
//
// This is a great place to put global configuration and
// behavior that modifies Cypress.
//
// You can change the location of this file or turn off
// automatically serving support files with the
// 'supportFile' configuration option.
//
// You can read more here:
// https://on.cypress.io/configuration
// ***********************************************************

// Import commands.js using ES2015 syntax:
// import './commands'

// Alternatively you can use CommonJS syntax:
// require('./commands')

import { mount } from "cypress/vue";
import i18n from "@koha-vue/i18n";
import { createWebHistory, createRouter } from "vue-router";
import vSelect from "vue-select";

// Augment the Cypress namespace to include type definitions for
// your custom command.
// Alternatively, can be defined in cypress/support/component.d.ts
// with a <reference path="./component" /> at the top of your spec.
// declare global {
//   namespace Cypress {
//     interface Chainable {
//       mount: typeof mount
//     }
//   }
// };

Cypress.Commands.add("mount", (component, options = {}) => {
    options.global = options.global || {};
    options.global.plugins = options.global.plugins || [];

    if (!options.router) {
        options.router = createRouter({
            routes: [
                {
                    path: "/:pathMatch(.*)*",
                    name: "home",
                    children: [],
                },
            ],
            history: createWebHistory(),
        });
        options.router.beforeEach((to, from, next) => {
            if (!to.matched.length) next();
        });
        options.global.plugins.push({
            install(app) {
                app.use(options.router).component("v-select", vSelect);
            },
        });
    }
    options.global.plugins.push(i18n);
    return mount(component, options);
});

// Example use:
// cy.mount(MyComponent)
