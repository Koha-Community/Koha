<template>
    <div v-if="initialized && config.settings.ERMModule == 1">
        <div id="sub-header">
            <Breadcrumbs />
            <Help />
        </div>
        <div class="main container-fluid">
            <div class="row">
                <div class="col-md-10 order-md-2 order-sm-1">
                    <main>
                        <Dialog />
                        <router-view />
                    </main>
                </div>

                <div class="col-md-2 order-sm-2 order-md-1">
                    <LeftMenu
                        :title="$__('E-resource management')"
                        :condition="filterProviders"
                    ></LeftMenu>
                </div>
            </div>
        </div>
    </div>
    <div class="main container-fluid" v-else>
        <Dialog />
    </div>
</template>

<script>
import { inject, onBeforeMount, ref } from "vue";
import Breadcrumbs from "../Breadcrumbs.vue";
import Help from "../Help.vue";
import LeftMenu from "../LeftMenu.vue";
import Dialog from "../Dialog.vue";
import { APIClient } from "../../fetch/api-client.js";
import "vue-select/dist/vue-select.css";
import { storeToRefs } from "pinia";
import { $__ } from "../../i18n";

export default {
    setup() {
        const vendorStore = inject("vendorStore");

        const mainStore = inject("mainStore");

        const { loading, loaded, setError } = mainStore;

        const ERMStore = inject("ERMStore");

        const { config, authorisedValues } = storeToRefs(ERMStore);
        const { loadAuthorisedValues } = ERMStore;

        const initialized = ref(false);

        const filterProviders = navigationTree => {
            const eHoldings = navigationTree.find(
                element => element.path === "/cgi-bin/koha/erm/eholdings"
            );
            const providers = config.value.settings.ERMProviders;
            eHoldings.children = eHoldings.children.filter(element =>
                providers
                    .map(provider => `${eHoldings.path}/${provider}`)
                    .includes(element.path)
            );
            return navigationTree;
        };

        onBeforeMount(() => {
            loading();

            const fetch_config = () => {
                const acq_client = APIClient.acquisition;
                acq_client.vendors.getAll().then(
                    vendors => {
                        vendorStore.vendors = vendors;
                    },
                    error => {}
                );
                loadAuthorisedValues(authorisedValues.value, ERMStore).then(
                    () => {
                        loaded();
                        initialized.value = true;
                    }
                );
            };

            const client = APIClient.erm;
            client.config.get().then(result => {
                config.value = result;
                if (config.value.settings.ERMModule != 1) {
                    return setError(
                        $__(
                            "The e-resource management module is disabled, turn on <a href='/cgi-bin/koha/admin/preferences.pl?tab=&op=search&searchfield=ERMModule'>ERMModule</a> to use it"
                        ),
                        false
                    );
                }
                return fetch_config();
            });
        });

        return {
            vendorStore,
            ERMStore,
            config,
            setError,
            loading,
            loaded,
            initialized,
            filterProviders,
        };
    },
    components: {
        Breadcrumbs,
        Dialog,
        Help,
        LeftMenu,
    },
};
</script>

<style>
#menu ul ul,
.sidebar_menu ul ul {
    background-color: transparent;
    padding-left: 2em;
    font-size: 100%;
}

form .v-select {
    display: inline-block;
    background-color: white;
    width: 30%;
}

.v-select,
input:not([type="submit"]):not([type="search"]):not([type="button"]):not(
        [type="checkbox"]
    ):not([type="radio"]),
textarea {
    border-color: rgba(60, 60, 60, 0.26);
    border-width: 1px;
    border-radius: 4px;
    min-width: 30%;
}
.flatpickr-input {
    width: 30%;
}
.sidebar_menu ul li a.current.disabled {
    background-color: inherit;
    border-left: 5px solid transparent;
    color: #000;
}
.sidebar_menu ul li a.disabled {
    color: #666;
    pointer-events: none;
    font-weight: 700;
}
</style>
