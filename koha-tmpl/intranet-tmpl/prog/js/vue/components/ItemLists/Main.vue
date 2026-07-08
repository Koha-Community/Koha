<template>
    <div>
        <Teleport to="#vue-breadcrumbs-container">
            <Breadcrumbs />
        </Teleport>
        <Dialog />
        <router-view v-if="initialized" />
    </div>
</template>

<script>
import { inject, onBeforeMount, ref } from "vue";
import Breadcrumbs from "../Breadcrumbs.vue";
import Dialog from "../Dialog.vue";
import { APIClient } from "../../fetch/api-client.js";
import { storeToRefs } from "pinia";

import "vue-select/dist/vue-select.css";

export default {
    setup() {
        const mainStore = inject("mainStore");

        const { loading, loaded, setError } = mainStore;

        const ItemListsStore = inject("ItemListsStore");
        const { config } = storeToRefs(ItemListsStore);

        const initialized = ref(false);

        onBeforeMount(() => {
            loading();

            const client = APIClient.item_lists;
            client.config.get().then(result => {
                config.value = result;
                initialized.value = true;
                loaded();
            });
        });

        return {
            loading,
            loaded,
            config,
            setError,
            initialized,
        };
    },
    components: {
        Breadcrumbs,
        Dialog,
    },
};
</script>
