<template>
    <div class="page-section" id="files">
        <form @submit="addDocument($event)" class="file_upload">
            <h2>{{ $__("Manual upload:") }}</h2>
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
import { inject, onBeforeMount, ref } from "vue";
import ButtonSubmit from "../ButtonSubmit.vue";
import { APIClient } from "../../fetch/api-client.js";
import { $__ } from "../../i18n";
import { useRoute } from "vue-router";

export default {
    setup() {
        const { setMessage } = inject("mainStore");

        const file = ref({
            filename: null,
            usage_data_provider_id: null,
            file_type: null,
            file_content: null,
            date: null,
            date_uploaded: null,
        });

        const selectFile = e => {
            let files = e.target.files;
            if (!files) return;
            let file = files[0];
            const reader = new FileReader();
            reader.onload = e => loadFile(file.name, e.target.result);
            reader.readAsBinaryString(file);
        };
        const route = useRoute();
        const loadFile = (filename, content) => {
            file.value.filename = filename;
            file.value.file_content = btoa(content);
            getDataProvider(route.params.erm_usage_data_provider_id);
        };
        const addDocument = e => {
            e.preventDefault();
            const client = APIClient.erm;
            client.usage_data_providers
                .process_COUNTER_file(file.value.usage_data_provider_id, {
                    usage_data_provider_id: file.value.usage_data_provider_id,
                    filename: file.value.filename,
                    file_content: file.value.file_content,
                })
                .then(
                    success => {
                        let message = "";
                        success.jobs.forEach((job, i) => {
                            message +=
                                "<li>" +
                                $__("Job for uploaded file has been queued") +
                                '. <a href="/cgi-bin/koha/admin/background_jobs.pl?op=view&id=' +
                                job.job_id +
                                '" target="_blank">' +
                                $__("Check job progress") +
                                ".</a></li>";
                        });
                        setMessage(message, true);
                    },
                    error => {}
                );
        };
        const clearForm = e => {
            e.preventDefault();

            file.value = {
                filename: null,
                usage_data_provider_id: null,
                file_type: null,
                file_content: null,
                date: null,
                date_uploaded: null,
            };
        };

        const getDataProvider = async usage_data_provider_id => {
            const client = APIClient.erm;
            await client.usage_data_providers.get(usage_data_provider_id).then(
                usage_data_provider => {
                    file.value.usage_data_provider_id =
                        usage_data_provider.erm_usage_data_provider_id;
                },
                error => {}
            );
        };

        onBeforeMount(() => {
            getDataProvider(route.params.erm_usage_data_provider_id);
        });
        return {
            setMessage,
            file,
            selectFile,
            addDocument,
            clearForm,
        };
    },
    components: {
        ButtonSubmit,
    },
    name: "UsageStatisticsDataProvidersFileImport",
};
</script>

<style scoped>
label {
    margin: 0px 10px 0px 0px;
}
</style>
