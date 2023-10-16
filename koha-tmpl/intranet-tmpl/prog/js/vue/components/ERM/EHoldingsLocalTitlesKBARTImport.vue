<template>
    <h2>{{ $__("Import from a KBART file") }}</h2>
    <div class="page-section" id="files">
        <form @submit="addDocument($event)" class="file_upload">
            <label>{{ $__("File") }}:</label>
            <div class="file_information">
                <span v-if="!file.filename">
                    {{ $__("Select a file") }}
                    <input
                        type="file"
                        @change="selectFile($event)"
                        :id="`import_file`"
                        :name="`import_file`"
                        required
                    />
                </span>
                <ol>
                    <li v-show="file.filename">
                        {{ $__("File name") }}:
                        <span>{{ file.filename }}</span>
                    </li>
                </ol>
                <fieldset id="package_list">
                    {{ $__("To the following local package") }}:
                    <v-select
                        v-model="package_id"
                        label="name"
                        :reduce="p => p.package_id"
                        :options="packages"
                        :clearable="false"
                        :required="!package_id"
                    >
                        <template #search="{ attributes, events }">
                            <input
                                :required="!package_id"
                                class="vs__search"
                                v-bind="attributes"
                                v-on="events"
                            />
                        </template>
                    </v-select>
                    <span class="required">{{ $__("Required") }}</span>
                </fieldset>
            </div>
            <fieldset class="action">
                <ButtonSubmit />
                <a @click="clearForm($event)" role="button" class="cancel">{{
                    $__("Clear form")
                }}</a>
            </fieldset>
        </form>
    </div>
</template>

<script>
import ButtonSubmit from "../ButtonSubmit.vue"
import { APIClient } from "../../fetch/api-client.js"
import { setMessage, setWarning } from "../../messages"

export default {
    data() {
        return {
            file: {
                filename: null,
                file_content: null,
            },
            packages: [],
            package_id: null,
        }
    },
    beforeCreate() {
        const client = APIClient.erm
        client.localPackages.getAll().then(
            packages => {
                this.packages = packages
                this.initialized = true
            },
            error => {}
        )
    },
    methods: {
        selectFile(e) {
            let files = e.target.files
            if (!files) return
            let file = files[0]
            const reader = new FileReader()
            reader.onload = e => this.loadFile(file.name, e.target.result)
            reader.readAsBinaryString(file)
        },
        loadFile(filename, content) {
            this.file.filename = filename
            this.file.file_content = btoa(content)
        },
        addDocument(e) {
            e.preventDefault()

            const client = APIClient.erm
            const importData = {
                file: this.file,
                package_id: this.package_id,
            }
            client.localTitles.import_kbart(importData).then(
                success => {
                    let message = ""
                    if (success.job_ids) {
                        if (success.job_ids.length > 1) {
                            message += this.__(
                                "<li>Your file was too large to process in one job, the file has been split into %s jobs to meet the maximum size limits.</li>"
                            ).format(success.job_ids.length)
                        }
                        success.job_ids.forEach((job, i) => {
                            message += this.$__(
                                '<li>Job for uploaded file %s has been queued, <a href="/cgi-bin/koha/admin/background_jobs.pl?op=view&id=%s" target="_blank">click here</a> to check its progress.</li>'
                            ).format(i + 1, job)
                        })
                        setMessage(message, true)
                    }
                    if (success.invalid_columns) {
                        message +=
                            "<p>Invalid columns were detected in your report, please check the list below:</p>"
                        success.invalid_columns.forEach(column => {
                            message += this.$__(
                                `<li style="font-weight: normal; font-size: medium;">%s</li>`
                            ).format(column)
                        })
                        message +=
                            '<p style="margin-top: 1em;">Below is a list of columns allowed in a KBART phase II report:</p>'
                        success.valid_columns.forEach(column => {
                            message += this.$__(
                                `<li style="font-weight: normal; font-size: medium;">%s</li>`
                            ).format(column)
                        })
                        setWarning(message)
                    }
                },
                error => {}
            )
        },
        clearForm(e) {
            e.preventDefault()
            this.file = {
                filename: null,
                file_type: null,
                file_content: null,
            }
            this.package_id = null
        },
    },
    components: {
        ButtonSubmit,
    },
    name: "EHoldingsLocalTitlesKBARTImport",
}
</script>

<style scoped>
label {
    margin: 0px 10px 0px 0px;
}
</style>
