import { Component, defineCustomElement } from "vue";
export * from "vue";
import { createPinia } from "pinia";
import { $__ } from "../i18n";

/**
 * Represents a web component with an import function and optional configuration.
 * @typedef {Object} WebComponentDynamicImport
 * @property {function(): Promise<Component>} importFn - A function that imports the component dynamically.
 * @property {Object} [config] - An optional configuration object for the web component.
 * @property {Array<string>} [config.stores] - An optional array of strings representing store names associated with the component.
 */
export type WebComponentDynamicImport = {
    importFn: () => Promise<Component>;
    config?: Record<"stores", Array<string>>;
};

/**
 * Pinia store definitions available to islands, keyed by the name components
 * reference in their config.stores list.
 * @typedef {Object.<string, function(Pinia): Object>} IslandStoreDefinitions
 */
export type IslandStoreDefinitions = Record<
    string,
    (pinia: ReturnType<typeof createPinia>) => unknown
>;

/**
 * A registry for Vue components.
 *
 * Starts empty; the per-application entry points (islands-intranet.ts,
 * islands-opac.ts) and Koha plugins populate it via registerIsland().
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
    new Map();

/**
 * Registers an island component for hydration.
 *
 * This allows Koha plugins to provide Vue micro frontends as custom elements.
 * Plugins should call this function from their intranet_js hook before hydrate()
 * runs (which is deferred via requestIdleCallback).
 *
 * @param {string} name - The custom element tag name (must contain a hyphen per web component spec).
 * @param {WebComponentDynamicImport} entry - The component import function and optional store configuration.
 *
 * @example
 * // In a plugin's intranet_js output:
 * import { registerIsland } from "/path/to/islands.esm.js";
 * registerIsland("plugin-notes-panel", {
 *     importFn: () => import("/api/v1/contrib/myplugin/static/dist/NotesPanel.js"),
 *     config: { stores: [] },
 * });
 */
export function registerIsland(
    name: string,
    entry: WebComponentDynamicImport
): void {
    if (!/^[a-z][a-z0-9]*-[a-z0-9-]*$/.test(name)) {
        console.warn(
            `[islands] Invalid custom element name "${name}". ` +
                `Must be lowercase, contain a hyphen, and start with a letter.`
        );
        return;
    }
    if (componentRegistry.has(name)) {
        console.warn(
            `[islands] Component "${name}" is already registered, skipping.`
        );
        return;
    }
    componentRegistry.set(name, entry);
}

/**
 * Hydrates custom elements by scanning the document and loading only necessary components.
 * @param {IslandStoreDefinitions} [storeDefinitions] - The stores islands on this page may request via config.stores.
 * @returns {void}
 */
export function hydrate(storeDefinitions: IslandStoreDefinitions = {}): void {
    window.requestIdleCallback(async () => {
        if (componentRegistry.size === 0) {
            return;
        }

        const pinia = createPinia();
        const storesMatrix = Object.fromEntries(
            Object.entries(storeDefinitions).map(([name, useStore]) => [
                name,
                useStore(pinia),
            ])
        );

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

            let component = await importFn();
            if (!component || customElements.get(name)) {
                return;
            }

            // ES module default exports may be frozen — create a mutable
            // shallow clone preserving all property descriptors so that
            // defineCustomElement can set internal properties like `name`.
            if (!Object.isExtensible(component)) {
                component = Object.create(
                    Object.getPrototypeOf(component),
                    Object.getOwnPropertyDescriptors(component)
                );
            }

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
