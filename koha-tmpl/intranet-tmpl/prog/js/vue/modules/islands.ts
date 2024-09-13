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
    ]
);

// Register and define custom elements
window.requestIdleCallback(async () => {
    componentRegistry.forEach(async (importFn, name) => {
        const component = await importFn();
        customElements.define(
            name,
            defineCustomElement(component as any, { shadowRoot: false })
        );
    });
});
