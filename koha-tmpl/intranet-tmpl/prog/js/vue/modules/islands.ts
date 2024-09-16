import { Component, defineCustomElement } from "vue";
import { createPinia } from "pinia";
import { useMainStore } from "../stores/main";
import { useNavigationStore } from "../stores/navigation";

/**
 * A registry for Vue components.
 * @type {Map<string, () => Promise<Component>>}
 */
interface WebComponent {
    importFn: () => Promise<Component>;
    config?: {
        stores: string[];
    };
}
export const componentRegistry: Map<string, WebComponent> = new Map([
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

const pinia = createPinia();

const mainStore = useMainStore(pinia);
const navigationStore = useNavigationStore(pinia);

const storesMatrix = {
    mainStore,
    navigationStore,
};

/**
 * Hydrates custom elements by scanning the document and loading only necessary components.
 * @returns {void}
 */
export function hydrate(): void {
    window.requestIdleCallback(async () => {
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
                            if (config.stores && config.stores.length > 0) {
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
