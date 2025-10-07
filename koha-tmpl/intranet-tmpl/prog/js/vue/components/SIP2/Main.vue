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
                    <LeftMenu :title="$__('SIP2')"></LeftMenu>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import { inject, onBeforeMount, ref } from "vue";
import Breadcrumbs from "../Breadcrumbs.vue";
import { storeToRefs } from "pinia";
import Help from "../Help.vue";
import LeftMenu from "../LeftMenu.vue";
import Dialog from "../Dialog.vue";
import "vue-select/dist/vue-select.css";

export default {
    setup() {
        const SIP2Store = inject("SIP2Store");
        const { authorisedValues } = storeToRefs(SIP2Store);
        const { loadAuthorisedValues } = SIP2Store;

        const mainStore = inject("mainStore");

        const { loading, loaded, setError } = mainStore;

        const initialized = ref(false);

        onBeforeMount(() => {
            loading();
            loadAuthorisedValues(authorisedValues.value, SIP2Store).then(() => {
                loaded();
                initialized.value = true;
            });
        });

        return {
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
