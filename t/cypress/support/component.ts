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
import { createPinia, defineStore } from "pinia";
import { useMainStore } from "@koha-vue/stores/main";
import { useNavigationStore } from "@koha-vue/stores/navigation";

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

    // Create a default testing store for use where stores may be dynamic
    const testingStore = defineStore("testing", {
        state: () => options?.global?.testingStore?.initialState || {},
    });

    const pinia = createPinia();
    const storesMatrix = {
        mainStore: useMainStore(pinia),
        navigationStore: useNavigationStore(pinia),
    };

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
            if (!app.config.globalProperties.$router) {
                app.use(options.router);
            }
            if (!app._context.components["v-select"]) {
                app.component("v-select", vSelect);
            }
            if (!app.config.globalProperties.$pinia) {
                app.use(pinia);
                if (options.global.stores?.length > 0) {
                    options.global.stores.forEach(store => {
                        Cypress.Commands.add(
                            `get_${store}`,
                            () => storesMatrix[store]
                        );
                        app.provide(store, storesMatrix[store]);
                    });
                }
                app.provide("testingStore", testingStore());
            }
            if (!app.config.globalProperties.$__) {
                app.use(i18n);
            }
        },
    });
    return mount(component, options);
});

// Example use:
// cy.mount(MyComponent)

cy.getDummyAPIClient = () => {
    return {
        get: async id => {
            return await new Promise(resolve =>
                resolve({ id: id, name: "Object 1" })
            );
        },
        getAll: async (query, params) =>
            await new Promise(resolve =>
                resolve([{ id: 1, name: "Object 1" }])
            ),
        create: async object => {
            return await new Promise(resolve => resolve({ id: 1, ...object }));
        },
        update: async (object, id) => {
            return await new Promise(resolve => resolve({ id: id, ...object }));
        },
        delete: async id => {
            return await new Promise(resolve => resolve(null));
        },
        count: async query => {
            return await new Promise(resolve => resolve(1));
        },
    };
};

cy.getBaseResourceConfig = () => {
    return {
        moduleStore: "testingStore",
        i18n: {
            deleteConfirmationMessage: "Delete this object?",
        },
        apiClient: cy.getDummyAPIClient(),
        components: {
            show: "testShow",
            add: "testAdd",
            list: "testList",
            edit: "testEdit",
        },
        idAttr: "id",
        nameAttr: "name",
        resourceName: "testObject",
        table: {
            resourceTableUrl: "testTableUrl",
        },
    };
};

cy.getResourceAttrsWithNoGroups = () => {
    return [
        {
            name: "id",
            type: "text",
            hideIn: ["Form", "Show"],
        },
        {
            name: "name",
            type: "text",
        },
        {
            name: "relationships",
            type: "relationshipWidget",
            relationshipFields: [
                { name: "relField", type: "text" },
                { name: "avField", type: "select", avCat: "av_test" },
            ],
        },
        {
            name: "showField",
            type: "text",
            hideIn: ["Form"],
        },
        {
            name: "formField",
            type: "text",
            hideIn: ["Show"],
        },
        {
            name: "displayName",
            type: "text",
            hideIn: ["Form"],
        },
        {
            name: "select",
            type: "select",
            avCat: "av_test",
            hideIn: ["Form", "Show"],
        },
        {
            name: "textarea",
            type: "textarea",
            hideIn: ["Form", "Show"],
        },
        {
            name: "boolean",
            type: "boolean",
            hideIn: ["Form", "Show"],
        },
        {
            name: "checkbox",
            type: "checkbox",
            hideIn: ["Form", "Show"],
        },
        {
            name: "dummyType",
            type: "dummyType",
            hideIn: ["Form", "Show"],
        },
        {
            name: "defaultValue",
            type: "text",
            defaultValue: "This is a default value",
            hideIn: ["Form", "Show"],
        },
    ];
};
cy.getResourceAttrsWithGroups = () => {
    const resourceAttrs = cy.getResourceAttrsWithNoGroups();
    const groups = ["Group 1", "Group 2", "Group 3"];
    return resourceAttrs.map((attr, i) => {
        return {
            ...attr,
            group: groups[i % groups.length],
        };
    });
};
