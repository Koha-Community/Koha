export * from "./islands";
import {
    hydrate as hydrateIslands,
    registerIsland,
    IslandStoreDefinitions,
    WebComponentDynamicImport,
} from "./islands";
import { useMainStore } from "../stores/main";

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
            config: {
                stores: ["mainStore"],
            },
        },
    ],
]);

/**
 * The Pinia stores islands in the OPAC may request via config.stores.
 * @type {IslandStoreDefinitions}
 */
const storeDefinitions: IslandStoreDefinitions = {
    mainStore: useMainStore,
};

// Core islands take the same registration path as plugin islands.
islands.forEach((entry, name) => registerIsland(name, entry));

/**
 * Hydrates islands with the OPAC store set.
 *
 * This local export takes precedence over the star re-export from ./islands,
 * so imports of hydrate from the built islands.esm.js get the stores baked in.
 * @returns {void}
 */
export function hydrate(): void {
    hydrateIslands(storeDefinitions);
}

if (parseInt(document?.currentScript?.getAttribute("init") ?? "0", 10)) {
    hydrate();
}
