<template>
    <div v-if="initialized && config.settings.enabled == 1">
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
                    <LeftMenu :title="$__('Preservation')"></LeftMenu>
                </div>
            </div>
        </div>
    </div>
    <div class="main container-fluid" v-else>
        <Dialog />
    </div>
</template>

<script>
import { inject } from "vue";
import Breadcrumbs from "../Breadcrumbs.vue";
import Help from "../Help.vue";
import LeftMenu from "../LeftMenu.vue";
import Dialog from "../Dialog.vue";
import { APIClient } from "../../fetch/api-client.js";
import "vue-select/dist/vue-select.css";
import { storeToRefs } from "pinia";

export default {
    setup() {
        const mainStore = inject("mainStore");

        const { loading, loaded, setError } = mainStore;

        const PreservationStore = inject("PreservationStore");

        const { config, authorisedValues } = storeToRefs(PreservationStore);
        const { loadAuthorisedValues } = PreservationStore;

        return {
            loading,
            loaded,
            config,
            setError,
            authorisedValues,
            loadAuthorisedValues,
            PreservationStore,
        };
    },
    data() {
        return {
            initialized: false,
        };
    },
    beforeCreate() {
        this.loading();

        const client = APIClient.preservation;
        client.config.get().then(config => {
            this.config = config;
            if (this.config.settings.enabled != 1) {
                this.loaded();
                return this.setError(
                    this.$__(
                        'The preservation module is disabled, turn on <a href="/cgi-bin/koha/admin/preferences.pl?tab=&op=search&searchfield=PreservationModule">PreservationModule</a> to use it'
                    ),
                    false
                );
            }
            this.loadAuthorisedValues(
                this.authorisedValues,
                this.PreservationStore
            ).then(() => {
                this.loaded();
                this.initialized = true;
            });
        });
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
    ),
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
    border-left: 5px solid #e6e6e6;
    color: #000;
}
.sidebar_menu ul li a.disabled {
    color: #666;
    pointer-events: none;
    font-weight: 700;
}
</style>
