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
import { inject } from "vue";
import Breadcrumbs from "../Breadcrumbs.vue";
import Help from "../Help.vue";
import LeftMenu from "../LeftMenu.vue";
import Dialog from "../Dialog.vue";
import "vue-select/dist/vue-select.css";
import { storeToRefs } from "pinia";

export default {
    setup() {
        const vendorStore = inject("vendorStore");
        const { config, authorisedValues } = storeToRefs(vendorStore);
        const { loadAuthorisedValues } = vendorStore;

        const mainStore = inject("mainStore");
        const { loading, loaded, setError } = mainStore;

        const permissionsStore = inject("permissionsStore");
        const { userPermissions } = storeToRefs(permissionsStore);

        return {
            vendorStore,
            setError,
            loading,
            loaded,
            userPermissions,
            config,
            loadAuthorisedValues,
            authorisedValues,
        };
    },
    beforeCreate() {
        this.loading();

        this.loadAuthorisedValues(this.authorisedValues, this.vendorStore).then(
            () => {
                this.userPermissions = userPermissions;
                this.config.settings.edifact = edifact;
                this.config.settings.marcOrderAutomation = marcOrderAutomation;
                this.vendorStore.currencies = currencies;
                this.vendorStore.gstValues = gstValues.map(gv => {
                    return {
                        label: `${Number(gv.option * 100).format_price()}%`,
                        value: gv.option,
                    };
                });
                this.loaded();
                this.initialized = true;
            }
        );
    },
    data() {
        return {
            initialized: false,
        };
    },
    methods: {},
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
#navmenulist ul ul {
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
#navmenulist ul li a.current.disabled {
    background-color: inherit;
    border-left: 5px solid #e6e6e6;
    color: #000;
}
#navmenulist ul li a.disabled {
    color: #666;
    pointer-events: none;
    font-weight: 700;
}
</style>
