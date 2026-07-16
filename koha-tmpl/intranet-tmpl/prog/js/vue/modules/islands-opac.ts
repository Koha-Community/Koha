export * from "./islands";
import { hydrate, registerIsland, WebComponentDynamicImport } from "./islands";

/**
 * The islands available in the OPAC.
 * @type {Map<string, WebComponentDynamicImport>}
 */
const islands: Map<string, WebComponentDynamicImport> = new Map([
    [
        "patron-self-renewal",
        {
            importFn: async () => {
                const module = await import(
                    /* webpackChunkName: "patron-self-renewal" */
                    "../components/Islands/PatronSelfRenewal/PatronSelfRenewal.vue"
                );
                return module.default;
            },
            config: {},
        },
    ],
]);

// Core islands take the same registration path as plugin islands.
islands.forEach((entry, name) => registerIsland(name, entry));

if (parseInt(document?.currentScript?.getAttribute("init") ?? "0", 10)) {
    hydrate();
}
