<template>
    <a
        class="btn btn-default"
        @click="
            this.current_object_id = null;
            this.setCurrentView('add-form');
        "
        ><font-awesome-icon icon="plus" /> New license</a
    >
</template>

<script>
import { useMainStore } from "../../stores/main"
import { storeToRefs } from "pinia"
export default {
    setup() {
        const mainStore = useMainStore()
        const { setCurrentView } = mainStore
        const { current_object_id } = storeToRefs(mainStore)
        return { setCurrentView, current_object_id }
    },
    name: "LicensesToolbar",
}
</script>
