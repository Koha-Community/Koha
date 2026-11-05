<template>
    <div>
        <Teleport to="#vue-breadcrumbs-container">
            <Breadcrumbs />
        </Teleport>
        <Dialog />
        <router-view />
    </div>
</template>

<script>
import Breadcrumbs from "../../Breadcrumbs.vue";
import Dialog from "../../Dialog.vue";
import "vue-select/dist/vue-select.css";

export default {
    components: {
        Breadcrumbs,
        Dialog,
    },
};
</script>
