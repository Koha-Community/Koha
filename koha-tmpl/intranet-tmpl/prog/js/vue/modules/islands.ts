import { Component, defineCustomElement } from "vue";
import HelloIslands from "../components/HelloIslands.vue";

/**
 * A registry for Vue components.
 * @type {Map<string, string>}
 */
export const componentRegistry: Map<string, () => Promise<Component>> = new Map(
    [["hello-islands", HelloIslands]]
);

// Register and define custom elements
window.requestIdleCallback(() => {
    componentRegistry.forEach((component, name) => {
        customElements.define(
            name,
            defineCustomElement(component as any, { shadowRoot: false })
        );
    });
});
