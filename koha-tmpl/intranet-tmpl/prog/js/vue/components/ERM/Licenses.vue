<template>
    <Toolbar v-if="current_view == 'list'" />
    <Dialog />
    <List
        v-if="current_view == 'list'"
    />
    <Show
        v-if="current_view == 'show'"
        :license_id="current_object_id"
    />
    <AddForm
        v-if="current_view == 'add-form'"
        :license_id="current_object_id"
    />
    <ConfirmDeleteForm
        v-if="current_view == 'confirm-delete-form'"
        :license_id="current_object_id"
    />
</template>

<script>
import Dialog from "./Dialog.vue"
import Toolbar from "./LicensesToolbar.vue"
import List from "./LicensesList.vue"
import Show from "./LicensesShow.vue"
import AddForm from "./LicensesFormAdd.vue"
import ConfirmDeleteForm from "./LicensesFormConfirmDelete.vue"

import { useMainStore } from "../../stores/main"
import { storeToRefs } from "pinia"

export default {
    setup() {
        const mainStore = useMainStore()
        const { current_object_id, current_view } = storeToRefs(mainStore)
        return { current_object_id, current_view };
    },
    components: {
        Dialog,
        Toolbar,
        List,
        Show,
        AddForm,
        ConfirmDeleteForm,
    },
};
</script>
