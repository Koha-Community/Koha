<template>
    <fieldset class="rows" id="agreement_documents">
        <legend>Documents</legend>
        <fieldset
            :id="`agreement_period_${counter}`"
            class="rows"
            v-for="(document, counter) in documents"
            v-bind:key="counter"
        >
            <legend>
                Document {{ counter + 1 }}
                <a href="#" @click.prevent="deleteDocument(counter)"
                    ><i class="fa fa-trash"></i> Remove this document</a
                >
            </legend>
            <ol>
                <li>
                    <label>File:</label>
                    <div class="file_information">
                        <span v-if="!document.file_name">
                            Select a file
                            <input
                                type="file"
                                @change="selectFile($event, counter)"
                                :id="`file_${counter}`"
                                :name="`file_${counter}`"
                            />
                        </span>
                        <span v-else>
                            Update file
                            <input
                                type="file"
                                @change="selectFile($event, counter)"
                                :id="`file_${counter}`"
                                :name="`file_${counter}`"
                            />
                        </span>
                        <ol>
                            <li v-show="document.file_name">
                                File name: <span>{{ document.file_name }}</span>
                            </li>
                            <li v-show="document.file_type">
                                File type: <span>{{ document.file_type }}</span>
                            </li>
                            <li v-show="document.file_name">
                                File description:
                                <input
                                    :id="`file_description_${counter}`"
                                    type="text"
                                    class="file_description"
                                    :name="`file_description_${counter}`"
                                    v-model="document.file_description"
                                    placeholder="File description"
                                />
                            </li>
                            <li v-show="document.uploaded_on">
                                Uploaded on:
                                <span>{{
                                    format_date(document.uploaded_on)
                                }}</span>
                            </li>
                        </ol>
                    </div>
                </li>
                <li>
                    <label :for="`physical_location_${counter}`"
                        >Physical location:
                    </label>
                    <input
                        :id="`physical_location_${counter}`"
                        type="text"
                        class="physical_location"
                        :name="`physical_location_${counter}`"
                        v-model="document.physical_location"
                        placeholder="Physical location"
                    />
                </li>
                <li>
                    <label :for="`uri_${counter}`">URI:</label>
                    <input
                        :id="`uri_${counter}`"
                        v-model="document.uri"
                        placeholder="URI"
                    />
                </li>
                <li>
                    <label :for="`notes_${counter}`">Notes: </label>
                    <input
                        :id="`notes_${counter}`"
                        type="text"
                        class="notes"
                        :name="`notes_${counter}`"
                        v-model="document.notes"
                        placeholder="Notes"
                    />
                </li>
            </ol>
        </fieldset>
        <a class="btn btn-default" @click="addDocument"
            ><font-awesome-icon icon="plus" /> Add new document</a
        >
    </fieldset>
</template>

<script>
export default {
    setup() {
        const format_date = $date
        return { format_date }
    },
    methods: {
        selectFile(e, i) {
            let files = e.target.files
            if (!files) return
            let file = files[0]
            const reader = new FileReader()
            reader.onload = e => this.loadFile(file.name, e.target.result, i)
            reader.readAsBinaryString(file)
        },
        loadFile(filename, content, i) {
            this.documents[i].file_name = filename
            this.documents[i].file_content = btoa(content)
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
            })
        },
        deleteDocument(counter) {
            this.documents.splice(counter, 1)
        }
    },
    name: 'AgreementDocuments',
    props: {
        documents: Array
    },

}
</script>

<style scoped>
.file_information {
    margin: 0 10rem;
}
</style>