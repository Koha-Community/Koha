<template>
    <label>{{ $__("Documents") }}</label>
    <div id="resource_documents">
        <ul>
            <li
                v-for="document in resource.documents"
                v-bind:key="document.document_id"
            >
                <div v-if="document.file_name">
                    <span v-if="document.file_description"
                        >{{ document.file_description }} -
                    </span>
                    <a
                        download
                        :href="`/api/v1/erm/documents/${document.document_id}/file/content`"
                    >
                        {{ document.file_name }}
                        <i class="fa fa-download"></i>
                    </a>
                    ({{ document.file_type }}) Uploaded on:
                    {{ format_date(document.uploaded_on) }}
                </div>
                <div v-if="document.physical_location">
                    {{ $__("Physical location") }}:
                    {{ document.physical_location }}
                </div>
                <div v-if="document.uri">
                    {{ $__("URI") }}: {{ document.uri }}
                </div>
                <div v-if="document.notes">
                    {{ $__("Notes") }}: {{ document.notes }}
                </div>
            </li>
        </ul>
    </div>
</template>

<script>
export default {
    props: {
        resource: Object,
    },
    setup() {
        const format_date = $date;

        return {
            format_date,
        };
    },
};
</script>

<style></style>
