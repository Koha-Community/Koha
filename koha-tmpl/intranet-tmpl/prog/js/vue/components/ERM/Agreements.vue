<template>
    <Toolbar v-if="current_view == 'list'" />
    <Dialog />
    <List
        v-if="current_view == 'list'"
    />
    <Show
        v-if="current_view == 'show'"
        :agreement_id="current_object_id"
    />
    <AddForm
        v-if="current_view == 'add-form'"
        :agreement_id="current_object_id"
    />
    <ConfirmDeleteForm
        v-if="current_view == 'confirm-delete-form'"
        :agreement_id="current_object_id"
    />
</template>

<script>
import Dialog from "./Dialog.vue"
import Toolbar from "./AgreementsToolbar.vue"
import List from "./AgreementsList.vue"
import Show from "./AgreementsShow.vue"
import AddForm from "./AgreementsFormAdd.vue"
import ConfirmDeleteForm from "./AgreementsFormConfirmDelete.vue"

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
