<template>
    <h2>{{ $__("Import from a KBART file") }}</h2>
    <div class="page-section" id="files">
        <form @submit="addDocument($event)" class="file_upload">
            <h3>{{ $__("Requirements:") }}</h3>
            <ul style="margin-bottom: 1.5em">
                <li>{{ $__("The file must be in TSV or CSV format") }}</li>
                <li>
                    {{
                        $__(
                            "The file should not contain any additional information / header rows, e.g. a file with a single title would be structured as follows:"
                        )
                    }}
                    <ol>
                        <li>{{ $__("Column headings row") }}</li>
                        <li>{{ $__("Title data row") }}</li>
                    </ol>
                </li>
            </ul>
            <fieldset class="rows" id="package_list">
                <h3>{{ $__("Select file for upload") }}:</h3>
                <ol>
                    <li>
                        <label for="import_file">{{ $__("File") }}:</label>
                        <input
                            type="file"
                            @change="selectFile($event)"
                            :id="`import_file`"
                            :name="`import_file`"
                            required
                            ref="fileLoader"
                        />
                    </li>
                    <li>
                        <label for="package_id"
                            >{{ $__("To the following local package") }}:</label
                        >
                        <v-select
                            id="package_id"
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
                    </li>
                    <li>
                        <label for="create_linked_biblio"
                            >{{
                                $__("Create linked bibliographic record")
                            }}:</label
                        >
                        <input
                            type="checkbox"
                            id="create_linked_biblio"
                            v-model="create_linked_biblio"
                        />
                    </li>
                </ol>
            </fieldset>
            <fieldset class="action">
                <ButtonSubmit />
                <a @click="clearForm()" role="button" class="cancel">{{
                    $__("Clear form")
                }}</a>
            </fieldset>
        </form>
    </div>
</template>

<script>
import ButtonSubmit from "../ButtonSubmit.vue";
import { APIClient } from "../../fetch/api-client.js";
import { ref, inject } from "vue";

export default {
    setup() {
        const { setMessage, setWarning } = inject("mainStore");
        return {
            setMessage,
            setWarning,
        };
    },
    data() {
        const fileLoader = ref();
        return {
            file: {
                filename: null,
                file_content: null,
            },
            packages: [],
            package_id: null,
            create_linked_biblio: false,
            fileLoader,
        };
    },
    beforeCreate() {
        const client = APIClient.erm;
        client.localPackages.getAll().then(
            packages => {
                this.packages = packages;
                this.initialized = true;
            },
            error => {}
        );
    },
    methods: {
        selectFile(e) {
            let files = e.target.files;
            if (!files) return;
            let file = files[0];
            const reader = new FileReader();
            reader.onload = e => this.loadFile(file.name, e.target.result);
            reader.readAsBinaryString(file);
        },
        loadFile(filename, content) {
            this.file.filename = filename;
            this.file.file_content = btoa(content);
        },
        addDocument(e) {
            e.preventDefault();

            const client = APIClient.erm;
            const importData = {
                file: this.file,
                package_id: this.package_id,
                create_linked_biblio: this.create_linked_biblio,
            };
            client.localTitles.import_kbart(importData).then(
                success => {
                    let message = "";
                    if (success.job_ids) {
                        if (success.job_ids.length > 1) {
                            message += `<p style='font-weight: normal; font-size: medium; margin-top: 1em;'>${this.$__(
                                "Your file was too large to process in one job, the file has been split into %s jobs to meet the maximum size limits."
                            ).format(success.job_ids.length)}</p>`;
                        }
                        success.job_ids.forEach((job, i) => {
                            message += `<li>${this.$__(
                                "Job %s for uploaded file has been queued"
                            ).format(
                                i + 1
                            )}, <a href="/cgi-bin/koha/admin/background_jobs.pl?op=view&id=${job}" target="_blank">${this.$__(
                                "see progress"
                            )}</a></li>`;
                        });
                        this.setMessage(message, true);
                    }
                    if (success.warnings.invalid_columns) {
                        message += `<p style='font-weight: normal; font-size: medium; margin-top: 1em;'>${this.$__(
                            "Information:"
                        )}</p>`;
                        message += `<p>${this.$__(
                            "Additional columns were detected in your report, please see the list below:"
                        )}</p>`;
                        success.warnings.invalid_columns.forEach(column => {
                            message += `<li>${column}</li>`;
                        });
                        message += `<p style='margin-top: 0.1em;'>${this.$__(
                            "The data in these columns will not be imported."
                        )}</p>`;
                        this.setMessage(message, true);
                    }
                    if (success.warnings.invalid_filetype) {
                        message += `<p>${this.$__(
                            "The file must be in .tsv or .csv format, please convert your file and try again."
                        )}</p>`;
                        this.setWarning(message);
                    }
                },
                error => {}
            );
            this.clearForm();
        },
        clearForm() {
            this.file = {
                filename: null,
                file_type: null,
                file_content: null,
            };
            this.package_id = null;
            this.create_linked_biblio = false;
            this.$refs.fileLoader.files = null;
            this.$refs.fileLoader.value = null;
        },
    },
    components: {
        ButtonSubmit,
    },
    name: "EHoldingsLocalTitlesKBARTImport",
};
</script>

<style scoped>
label {
    margin: 0px 10px 0px 0px;
}
</style>
