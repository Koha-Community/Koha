<template>
    <div v-if="initialized">
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
                    <LeftMenu :title="$__('Acquisitions')"></LeftMenu>
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
import "vue-select/dist/vue-select.css";
import { storeToRefs } from "pinia";
import { APIClient } from "../../fetch/api-client.js";

export default {
    setup() {
        const vendorStore = inject("vendorStore");
        const { config, authorisedValues, userPermissions } =
            storeToRefs(vendorStore);
        const { loadAuthorisedValues } = vendorStore;

        const mainStore = inject("mainStore");
        const { loading, loaded, setError } = mainStore;

        const initialized = ref(false);

        onBeforeMount(() => {
            loading();

            loadAuthorisedValues(authorisedValues.value, vendorStore).then(
                () => {
                    const client = APIClient.acquisition;
                    client.config.get("vendors").then(result => {
                        userPermissions.value = result.permissions;
                        config.value.settings.edifact = result.edifact;
                        config.value.settings.ermModule = result.erm_module;
                        config.value.settings.marcOrderAutomation =
                            result.marcOrderAutomation;
                        vendorStore.currencies = result.currencies;
                        vendorStore.gstValues = result.gst_values.map(gv => {
                            return {
                                label: `${Number(gv.option * 100).format_price()}%`,
                                value: gv.option,
                            };
                        });
                        loaded();
                        initialized.value = true;
                    });
                }
            );
        });

        return {
            vendorStore,
            setError,
            loading,
            loaded,
            userPermissions,
            config,
            loadAuthorisedValues,
            authorisedValues,
            initialized,
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

<style></style>
