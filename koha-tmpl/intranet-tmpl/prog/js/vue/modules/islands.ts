import { Component, defineCustomElement } from "vue";
import { createPinia } from "pinia";
import { $__ } from "../i18n";
import { useMainStore } from "../stores/main";
import { useNavigationStore } from "../stores/navigation";
import { usePermissionsStore } from "../stores/permissions";
import { useVendorStore } from "../stores/vendors";

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
 * @property {string} key - The name of the component.
 * @property {WebComponentDynamicImport} value - The configuration for the component. Includes the import function and optional configuration.
 * @example
 * //
 * [
 *     "hello-islands",
 *     {
 *         importFn: async () => {
 *             const module = await import(
 *                 /* webpackChunkName: "hello-islands" */
/**                "../components/Islands/HelloIslands.vue"
 *             );
 *             return module.default;
 *         },
 *         config: {
 *             stores: ["mainStore", "navigationStore"],
 *         },
 *     },
 * ],
 */
export const componentRegistry: Map<string, WebComponentDynamicImport> =
    new Map([
        [
            "acquisitions-menu",
            {
                importFn: async () => {
                    const module = await import(
                        /* webpackChunkName: "acquisitions-menu" */
                        "../components/Islands/AcquisitionsMenu.vue"
                    );
                    return module.default;
                },
                config: {
                    stores: [
                        "vendorStore",
                        "navigationStore",
                        "permissionsStore",
                    ],
                },
            },
        ],
        [
            "vendor-menu",
            {
                importFn: async () => {
                    const module = await import(
                        /* webpackChunkName: "vendor-menu" */
                        "../components/Islands/VendorMenu.vue"
                    );
                    return module.default;
                },
                config: {
                    stores: ["navigationStore", "permissionsStore"],
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
            permissionsStore: usePermissionsStore(pinia),
            vendorStore: useVendorStore(pinia),
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
                            app.config.globalProperties.$__ = $__;
                            // Further config options can be added here as we expand this further
                        },
                    }),
                })
            );
        });
    });
}

if (parseInt(document?.currentScript?.getAttribute("init") ?? "0", 10)) {
    hydrate();
}
