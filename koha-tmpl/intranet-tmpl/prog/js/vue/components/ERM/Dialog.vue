<template>
    <div class="dialog message" v-if="message">{{ message }}</div>
    <div class="dialog alert" v-if="error">{{ error }}</div>
    <div class="dialog alert modal" v-if="warning">
        {{ warning }}
        <a
            id="close_modal"
            class="btn btn-default btn-xs"
            role="button"
            @click="removeMessages"
            >{{ $t("Close") }}</a
        >
    </div>
    <!-- Must be styled differently -->
</template>

<script>
import { storeToRefs } from "pinia"
import { useMainStore } from "../../stores/main"
export default {
    setup() {
        const mainStore = useMainStore()
        const { message, error, warning } = storeToRefs(mainStore)
        const { removeMessages } = mainStore
        return { message, error, warning, removeMessages }
    },
};
</script>

<style scoped>
.modal {
    position: fixed;
    z-index: 9998;
    display: table;
    transition: opacity 0.3s ease;
    margin: auto;
    padding: 20px 30px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.33);
    transition: all 0.3s ease;
}
#close_modal {
    float: right;
    cursor: pointer;
}
</style>