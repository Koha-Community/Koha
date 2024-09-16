import { Component, defineCustomElement } from "vue";
import { createPinia } from "pinia";
import { useMainStore } from "../stores/main";
import { useNavigationStore } from "../stores/navigation";

/**
 * Represents a web component with an import function and optional configuration.
 * @typedef {Object} WebComponentDynamicImport
 * @property {function(): Promise<Component>} importFn - A function that imports the component dynamically.
 * @property {Object} [config] - An optional configuration object for the web component.
 * @property {Array<string>} [config.stores] - An optional array of strings representing store names associated with the component.
 */
type WebComponentDynamicImport = {
    importFn: () => Promise<Component>;
    config?: Record<"stores", Array<string>>;
};

/**
 * A registry for Vue components.
 * @type {Map<string, WebComponentDynamicImport>}
 */
export const componentRegistry: Map<string, WebComponentDynamicImport> =
    new Map([
        [
            "hello-islands",
            {
                importFn: async () => {
                    const module = await import(
                        /* webpackChunkName: "hello-islands" */
                        "../components/HelloIslands.vue"
                    );
                    return module.default;
                },
                config: {
                    stores: ["mainStore", "navigationStore"],
                },
            },
        ],
        [
            "hello-world",
            {
                importFn: async () => {
                    const module = await import(
                        /* webpackChunkName: "hello-world" */
                        "../components/HelloWorld.vue"
                    );
                    return module.default;
                },
            },
        ],
    ]);

/**
 * Hydrates custom elements by scanning the document and loading only necessary components.
 * @returns {void}
 */
export function hydrate(): void {
    window.requestIdleCallback(async () => {
        const pinia = createPinia();
        const storesMatrix = {
            mainStore: useMainStore(pinia),
            navigationStore: useNavigationStore(pinia),
        };

        const islandTagNames = Array.from(componentRegistry.keys()).join(", ");
        const requestedIslands = new Set(
            Array.from(document.querySelectorAll(islandTagNames)).map(element =>
                element.tagName.toLowerCase()
            )
        );

        requestedIslands.forEach(async name => {
            const { importFn, config } = componentRegistry.get(name);
            if (!importFn) {
                return;
            }

            const component = await importFn();
            customElements.define(
                name,
                defineCustomElement(component as any, {
                    shadowRoot: false,
                    ...(config && {
                        configureApp(app) {
                            if (config.stores?.length > 0) {
                                app.use(pinia);
                                config.stores.forEach(store => {
                                    app.provide(store, storesMatrix[store]);
                                });
                            }
                            // Further config options can be added here as we expand this further
                        },
                    }),
                })
            );
        });
    });
}

hydrate();
