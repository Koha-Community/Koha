import { Component, defineCustomElement } from "vue";

/**
 * A registry for Vue components.
 * @type {Map<string, () => Promise<Component>>}
 */
export const componentRegistry: Map<string, () => Promise<Component>> = new Map(
    [
        [
            "hello-islands",
            async () => {
                const module = await import(
                    /* webpackChunkName: "hello-islands" */
                    "../components/HelloIslands.vue"
                );
                return module.default;
            },
        ],
        [
            "hello-world",
            async () => {
                const module = await import(
                    /* webpackChunkName: "hello-world" */ "../components/HelloWorld.vue"
                );
                return module.default;
            },
        ],
    ]
);

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
            const importFn = componentRegistry.get(name);
            if (!importFn) {
                return;
            }

            const component = await importFn();
            customElements.define(
                name,
                defineCustomElement(component as any, {
                    shadowRoot: false,
                })
            );
        });
    });
}

hydrate();
