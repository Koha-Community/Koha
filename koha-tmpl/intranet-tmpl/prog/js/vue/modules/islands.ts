import { createApp, Component, App } from "vue";

/**
 * A registry for Vue components.
 * @type {Map<string, Component>}
 */
export const componentRegistry: Map<string, Component> = new Map<
    string,
    Component
>();

/**
 * Registers a Vue component with a name.
 * @param {string} name - The name of the component.
 * @param {Component} component - The Vue component to register.
 * @returns {void}
 */
export function registerComponent(name: string, component: Component): void {
    componentRegistry.set(name, component);
}

/**
 * Mounts Vue components to DOM elements based on the `data-component` attribute.
 * Components are created with props parsed from the `data-props` attribute.
 * Watches for changes in props and updates the component accordingly.
 * @returns {void}
 */
export function mountComponents(): void {
    console.log("Mounting components");

    const elements: NodeListOf<Element> =
        document.querySelectorAll("[data-component]");
    elements.forEach((element: Element) => {
        const componentName: string | null =
            element.getAttribute("data-component");
        if (!componentName) {
            console.warn("No data-component attribute found.");
            return;
        }

        const component: Component | undefined =
            componentRegistry.get(componentName);
        if (!component) {
            console.warn(`Component ${componentName} not found.`);
            return;
        }

        const props: string | null = element.getAttribute("data-props");
        const parsedProps: Record<string, any> = props ? JSON.parse(props) : {};

        // Create and mount the Vue component
        const app: App = createApp(component, parsedProps);
        app.mount(element);

        // Watch for updates to props
        watchProps(element, app, component);
    });
}

/**
 * Watches for changes in props and updates the component accordingly.
 * @param {Element} element - The DOM element where the component is mounted.
 * @param {App} app - The Vue application instance.
 * @param {Component} component - The Vue component.
 * @returns {void}
 */
function watchProps(element: Element, app: App, component: Component): void {
    const propsAttr: string | null = element.getAttribute("data-props");
    let prevProps: Record<string, any> = propsAttr ? JSON.parse(propsAttr) : {};

    const observer = new MutationObserver(() => {
        const newPropsAttr: string | null = element.getAttribute("data-props");
        if (newPropsAttr) {
            const newProps: Record<string, any> = JSON.parse(newPropsAttr);
            if (JSON.stringify(newProps) !== JSON.stringify(prevProps)) {
                prevProps = newProps;
                app.unmount(); // Unmount existing component
                createApp(component, newProps).mount(element); // Mount with new props
            }
        }
    });

    observer.observe(element, {
        attributes: true,
        attributeFilter: ["data-props"],
    });
}

import HelloIslands from "../components/HelloIslands.vue";
registerComponent("HelloIslands", HelloIslands);

// Automatically mount components when the DOM is fully loaded
document.addEventListener("DOMContentLoaded", mountComponents);
