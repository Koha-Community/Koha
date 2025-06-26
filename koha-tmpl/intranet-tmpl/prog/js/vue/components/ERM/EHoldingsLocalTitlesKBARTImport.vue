<template>
    <h2>{{ $__("Import from a KBART file") }}</h2>
    <div class="page-section" id="files">
        <form @submit="addDocument($event)" class="file_upload">
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
import { ref, inject, useTemplateRef, onBeforeMount } from "vue";
import { $__ } from "@k/i18n";

export default {
    setup() {
        const { setMessage, setWarning } = inject("mainStore");

        const fileLoader = useTemplateRef("fileLoader");

        const file = ref({
            filename: null,
            file_content: null,
        });
        const packages = ref([]);
        const package_id = ref(null);
        const create_linked_biblio = ref(false);

        const selectFile = e => {
            let files = e.target.files;
            if (!files) return;
            let newFile = files[0];
            const reader = new FileReader();
            reader.onload = e => loadFile(newFile.name, e.target.result);
            reader.readAsBinaryString(newFile);
        };
        const loadFile = (filename, content) => {
            file.value.filename = filename;
            file.value.file_content = btoa(content);
        };
        const addDocument = e => {
            e.preventDefault();

            const client = APIClient.erm;
            const importData = {
                file: file.value,
                package_id: package_id.value,
                create_linked_biblio: create_linked_biblio.value,
            };
            client.localTitles.import_kbart(importData).then(
                success => {
                    let message = "";
                    if (success.job_ids) {
                        if (success.job_ids.length > 1) {
                            message += `<p style='font-weight: normal; font-size: medium; margin-top: 1em;'>${$__(
                                "Your file was too large to process in one job, the file has been split into %s jobs to meet the maximum size limits."
                            ).format(success.job_ids.length)}</p>`;
                        }
                        success.job_ids.forEach((job, i) => {
                            message += `<li>${$__(
                                "Job %s for uploaded file has been queued"
                            ).format(
                                i + 1
                            )}, <a href="/cgi-bin/koha/admin/background_jobs.pl?op=view&id=${job}" target="_blank">${$__(
                                "see progress"
                            )}</a></li>`;
                        });
                        setMessage(message, true);
                    }
                    if (success.warnings.invalid_columns) {
                        message += `<p style='font-weight: normal; font-size: medium; margin-top: 1em;'>${$__(
                            "Information:"
                        )}</p>`;
                        message += `<p>${$__(
                            "Additional columns were detected in your report, please see the list below:"
                        )}</p>`;
                        success.warnings.invalid_columns.forEach(column => {
                            message += `<li>${column}</li>`;
                        });
                        message += `<p style='margin-top: 0.1em;'>${$__(
                            "The data in these columns will not be imported."
                        )}</p>`;
                        setMessage(message, true);
                    }
                    if (success.warnings.invalid_filetype) {
                        message += `<p>${this.$__(
                            "Could not detect whether the file is TSV or CSV, please check the file."
                        )}</p>`;
                        setWarning(message);
                    }
                },
                error => {}
            );
            clearForm();
        };
        const clearForm = () => {
            file.value = {
                filename: null,
                file_content: null,
            };
            package_id.value = null;
            create_linked_biblio.value = false;
            fileLoader.files = null;
            fileLoader.value = null;
        };

        onBeforeMount(() => {
            const client = APIClient.erm;
            client.localPackages.getAll().then(
                result => {
                    packages.value = result;
                },
                error => {}
            );
        });
        return {
            setMessage,
            setWarning,
            fileLoader,
            packages,
            package_id,
            create_linked_biblio,
            file,
            selectFile,
            addDocument,
            clearForm,
        };
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
