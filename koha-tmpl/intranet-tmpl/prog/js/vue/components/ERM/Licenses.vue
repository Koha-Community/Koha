<template>
    <Toolbar v-if="op == 'list'" @switch-view="switchView" />
    <div class="dialog message" v-if="message">{{ message }}</div>
    <div class="dialog alert" v-if="error">{{ error }}</div>
    <List
        v-if="op == 'list'"
        :av_license_types="license_types"
        :av_license_statuses="license_statuses"
        @set-current-license-id="setCurrentLicenseID"
        @switch-view="switchView"
        @set-error="setError"
    />
    <Show
        v-if="op == 'show'"
        :license_id="license_id"
        :av_license_types="license_types"
        :av_license_statuses="license_statuses"
        @switch-view="switchView"
        @set-error="setError"
    />
    <AddForm
        v-if="op == 'add-form'"
        :license_id="license_id"
        :av_license_types="license_types"
        :av_license_statuses="license_statuses"
        @license-created="licenseCreated"
        @license-updated="licenseUpdated"
        @switch-view="switchView"
        @set-error="setError"
    />
    <ConfirmDeleteForm
        v-if="op == 'confirm-delete-form'"
        :license_id="license_id"
        @license-deleted="licenseDeleted"
        @switch-view="switchView"
        @set-error="setError"
    />
</template>

<script>
import Toolbar from "./LicensesToolbar.vue"
import List from "./LicensesList.vue"
import Show from "./LicensesShow.vue"
import AddForm from "./LicensesFormAdd.vue"
import ConfirmDeleteForm from "./LicensesFormConfirmDelete.vue"

import { reactive, computed } from "vue"

export default {
    data() {
        return {
            license_id: null,
            op: "list",
            message: null,
            error: null,
            license_types,
            license_statuses,
        }
    },
    methods: {
        switchView(view) {
            this.message = null
            this.error = null
            this.op = view
            if (view == "list") this.license_id = null
        },
        licenseCreated() {
            this.message = "License created"
            this.error = null
            this.license_id = null
            this.op = "list"
        },
        licenseUpdated() {
            this.message = "License updated"
            this.error = null
            this.license_id = null
            this.op = "list"
        },
        licenseDeleted() {
            this.message = "License deleted"
            this.error = null
            this.license_id = null
            this.op = "list"
        },
        setCurrentLicenseID(license_id) {
            this.license_id = license_id
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
