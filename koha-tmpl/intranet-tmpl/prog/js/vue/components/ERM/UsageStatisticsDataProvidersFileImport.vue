<template>
    <div class="page-section" id="files">
        <form @submit="addDocument($event)" class="file_upload">
            <h2>Manual upload:</h2>
            <label>{{ $__("File") }}:</label>
            <div class="file_information">
                <span v-if="!file.filename">
                    {{ $__("Select a file") }}
                    <input
                        type="file"
                        @change="selectFile($event)"
                        :id="`import_file`"
                        :name="`import_file`"
                    />
                </span>
                <ol>
                    <li v-show="file.filename">
                        {{ $__("File name") }}:
                        <span>{{ file.filename }}</span>
                    </li>
                    <li v-show="file.file_type">
                        {{ $__("File type") }}:
                        <span>{{ file.file_type }}</span>
                    </li>
                </ol>
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
import { inject } from "vue"
import ButtonSubmit from "../ButtonSubmit.vue"
import { storeToRefs } from "pinia"
import { APIClient } from "../../fetch/api-client.js"

export default {
    data() {
        return {
            file: {
                filename: null,
                usage_data_provider_id: null,
                file_type: null,
                file_content: null,
                date: null,
                date_uploaded: null,
            },
        }
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
            // Harvesting and import to happen here
        },
        clearForm(e) {
            e.preventDefault()

            this.file = {
                filename: null,
                usage_data_provider_id: null,
                file_type: null,
                file_content: null,
                date: null,
                date_uploaded: null,
            }
        },
        async getDataProvider(usage_data_provider_id) {
            const client = APIClient.erm
            await client.usage_data_providers.get(usage_data_provider_id).then(
                usage_data_provider => {
                    this.file.usage_data_provider_id =
                        usage_data_provider.erm_usage_data_provider_id
                },
                error => {}
            )
        },
    },
    mounted() {
        this.getDataProvider(this.$route.params.usage_data_provider_id)
    },
    components: {
        ButtonSubmit,
    },
    name: "UsageStatisticsDataProvidersFileImport",
}
</script>

<style scoped>
label {
    margin: 0px 10px 0px 0px;
}
</style>
