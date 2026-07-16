export * from "./islands";
import {
    hydrate as hydrateIslands,
    registerIsland,
    IslandStoreDefinitions,
    WebComponentDynamicImport,
} from "./islands";
import { useMainStore } from "../stores/main";
import { useNavigationStore } from "../stores/navigation";
import { useVendorStore } from "../stores/vendors";

/**
 * The islands available in the staff interface.
 * @type {Map<string, WebComponentDynamicImport>}
 */
const islands: Map<string, WebComponentDynamicImport> = new Map([
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
                stores: ["vendorStore", "navigationStore"],
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
                stores: ["vendorStore", "navigationStore"],
            },
        },
    ],
    [
        "admin-menu",
        {
            importFn: async () => {
                const module = await import(
                    /* webpackChunkName: "admin-menu" */
                    "../components/Islands/AdminMenu.vue"
                );
                return module.default;
            },
            config: {
                stores: [],
            },
        },
    ],
]);

/**
 * The Pinia stores islands in the staff interface may request via config.stores.
 * @type {IslandStoreDefinitions}
 */
const storeDefinitions: IslandStoreDefinitions = {
    mainStore: useMainStore,
    navigationStore: useNavigationStore,
    vendorStore: useVendorStore,
};

// Core islands take the same registration path as plugin islands.
islands.forEach((entry, name) => registerIsland(name, entry));

/**
 * Hydrates islands with the staff interface store set.
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
