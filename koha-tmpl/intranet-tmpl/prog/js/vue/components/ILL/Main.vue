<template>
    <div v-if="initialized && config.settings.ILLModule == 1">
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

                <LeftMenu :title="$__('Interlibrary loans')"></LeftMenu>
            </div>
        </div>
    </div>
    <div class="main container-fluid" v-else>
        <Dialog />
    </div>
</template>

<script>
import { inject, onBeforeMount, ref } from "vue";
import { APIClient } from "../../fetch/api-client.js";
import Breadcrumbs from "../Breadcrumbs.vue";
import Help from "../Help.vue";
import LeftMenu from "../LeftMenu.vue";
import Dialog from "../Dialog.vue";
import "vue-select/dist/vue-select.css";
import { storeToRefs } from "pinia";
import { $__ } from "@koha-vue/i18n";

export default {
    setup() {
        const mainStore = inject("mainStore");

        const { loading, loaded, setError } = mainStore;

        const ILLStore = inject("ILLStore");

        const { config } = storeToRefs(ILLStore);

        const initialized = ref(false);

        onBeforeMount(() => {
            loading();
            const client = APIClient.ill;
            client.config.get().then(result => {
                config.value = result;
                if (config.value.settings.ILLModule != 1) {
                    loaded();
                    return setError(
                        $__(
                            "The ILL module is disabled, turn on <a href='/cgi-bin/koha/admin/preferences.pl?tab=&op=search&searchfield=ILLModule'>ILLModule</a> to use it"
                        ),
                        false
                    );
                }
                loaded();
                initialized.value = true;
            });
        });

        return {
            ILLStore,
            config,
            setError,
            loading,
            loaded,
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
