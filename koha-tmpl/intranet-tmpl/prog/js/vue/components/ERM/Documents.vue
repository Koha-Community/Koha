<template>
    <fieldset class="rows" id="documents">
        <fieldset
            :id="`document_${counter}`"
            class="rows"
            v-for="(document, counter) in documents"
            v-bind:key="counter"
        >
            <legend>
                {{ $__("Document %s").format(counter + 1) }}
                <a href="#" @click.prevent="deleteDocument(counter)"
                    ><i class="fa fa-trash"></i>
                    {{ $__("Remove this document") }}</a
                >
            </legend>
            <ol>
                <li v-for="(attr, index) in subFields" v-bind:key="index">
                    <FormElement
                        :resource="document"
                        :attr="attr"
                        :index="counter"
                    />
                </li>
            </ol>
        </fieldset>
        <a class="btn btn-default" @click="addDocument"
            ><font-awesome-icon icon="plus" /> {{ $__("Add new document") }}</a
        >
    </fieldset>
</template>

<script>
import FormElement from "../FormElement.vue";
export default {
    components: { FormElement },
    setup() {
        const format_date = $date;
        return { format_date };
    },
    methods: {
        selectFile(e, i) {
            let files = e.target.files;
            if (!files) return;
            let file = files[0];
            const reader = new FileReader();
            reader.onload = e => this.loadFile(file.name, e.target.result, i);
            reader.readAsBinaryString(file);
        },
        loadFile(filename, content, i) {
            this.documents[i].file_name = filename;
            this.documents[i].file_content = btoa(content);
        },
        addDocument() {
            this.documents.push({
                file_name: null,
                file_type: null,
                file_description: null,
                file_content: null,
                physical_location: null,
                uri: null,
                notes: null,
            });
        },
        deleteDocument(counter) {
            this.documents.splice(counter, 1);
        },
    },
    name: "Documents",
    props: {
        documents: Array,
        subFields: Array,
    },
};
</script>
