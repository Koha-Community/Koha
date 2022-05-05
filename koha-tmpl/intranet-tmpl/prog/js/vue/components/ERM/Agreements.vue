<template>
    <Toolbar v-if="op == 'list'" @switch-view="switchView" />
    <div class="dialog message" v-if="message">{{ message }}</div>
    <div class="dialog alert" v-if="error">{{ error }}</div>
    <List
        v-if="op == 'list'"
        @set-current-agreement-id="setCurrentAgreementID"
        @switch-view="switchView"
        @set-error="setError"
    />
    <Show
        v-if="op == 'show'"
        :agreement_id="agreement_id"
        @switch-view="switchView"
        @set-error="setError"
    />
    <AddForm
        v-if="op == 'add-form'"
        :agreement_id="agreement_id"
        @agreement-created="agreementCreated"
        @agreement-updated="agreementUpdated"
        @switch-view="switchView"
        @set-error="setError"
    />
    <ConfirmDeleteForm
        v-if="op == 'confirm-delete-form'"
        :agreement_id="agreement_id"
        @agreement-deleted="agreementDeleted"
        @switch-view="switchView"
        @set-error="setError"
    />
</template>

<script>
import Toolbar from "./AgreementsToolbar.vue"
import List from "./AgreementsList.vue"
import Show from "./AgreementsShow.vue"
import AddForm from "./AgreementsFormAdd.vue"
import ConfirmDeleteForm from "./AgreementsFormConfirmDelete.vue"
import { ref, reactive, computed } from "vue"

export default {
    data() {
        return {
            agreement_id: null,
            op: "list",
            message: null,
            error: null,
        }
    },
    methods: {
        switchView(view) {
            this.message = null
            this.error = null
            this.op = view
            if (view == "list") this.agreement_id = null
        },
        agreementCreated() {
            this.message = "Agreement created"
            this.error = null
            this.agreement_id = null
            this.op = "list"
        },
        agreementUpdated() {
            this.message = "Agreement updated"
            this.error = null
            this.agreement_id = null
            this.op = "list"
        },
        agreementDeleted() {
            this.message = "Agreement deleted"
            this.error = null
            this.agreement_id = null
            this.op = "list"
        },
        setCurrentAgreementID(agreement_id) {
            this.agreement_id = agreement_id
        },
        setError(error) {
            this.message = null
            this.error = "Something went wrong: " + error
        },
    },
    components: {
        Toolbar,
        List,
        Show,
        AddForm,
        ConfirmDeleteForm,
    },
    emits: ["set-error"],
};
</script>
