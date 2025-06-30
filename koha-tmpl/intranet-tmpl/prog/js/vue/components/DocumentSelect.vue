<template>
    <div class="file_information">
        <span v-if="!document.file_name">
            {{ $__("Select a file") }}
            <input
                type="file"
                @change="selectFile($event, counter)"
                :id="`file_${counter}`"
                :name="`file_${counter}`"
            />
        </span>
        <span v-else>
            {{ $__("Update file") }}
            <input
                type="file"
                @change="selectFile($event, counter)"
                :id="`file_${counter}`"
                :name="`file_${counter}`"
            />
        </span>
        <ol>
            <li v-show="document.file_name">
                {{ $__("File name") }}:
                <span>{{ document.file_name }}</span>
            </li>
            <li v-show="document.file_type">
                {{ $__("File type") }}:
                <span>{{ document.file_type }}</span>
            </li>
            <li v-show="document.file_name">
                {{ $__("File description") }}:
                <input
                    :id="`file_description_${counter}`"
                    type="text"
                    class="file_description"
                    :name="`file_description_${counter}`"
                    v-model="document.file_description"
                    :placeholder="$__('File description')"
                />
            </li>
            <li v-show="document.uploaded_on">
                {{ $__("Uploaded on") }}:
                <span>{{ format_date(document.uploaded_on) }}</span>
            </li>
        </ol>
    </div>
</template>

<script>
export default {
    props: {
        counter: String,
        document: Object,
    },
    setup(props) {
        const format_date = $date;
        const loadFile = (filename, content, i) => {
            props.document.file_name = filename;
            props.document.file_content = btoa(content);
        };
        const selectFile = (e, i) => {
            let files = e.target.files;
            if (!files) return;
            let file = files[0];
            const reader = new FileReader();
            reader.onload = e => loadFile(file.name, e.target.result, i);
            reader.readAsBinaryString(file);
        };

        return { format_date, loadFile, selectFile };
    },
};
</script>

<style></style>
