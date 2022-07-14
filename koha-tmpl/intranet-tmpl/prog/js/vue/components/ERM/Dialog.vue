<template>
    <div class="dialog message" v-if="message">{{ message }}</div>
    <div class="dialog alert" v-if="error">{{ error }}</div>
    <div class="dialog alert" v-if="warning">{{ warning }}</div> <!-- Must be styled differently -->
</template>

<script>
import { storeToRefs } from "pinia"
import { useMainStore } from "../../stores/main"

export default {
    setup(){
        const mainStore = useMainStore()
        const { message, error, warning } = storeToRefs(mainStore)
        return { message, error, warning }
    },
};
</script>