<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="record_source_edit">
        <h1 v-if="record_source.record_source_id">
            {{
                $__("Edit record source #%s").format(
                    record_source.record_source_id
                )
            }}
        </h1>
        <h1 v-else>{{ $__("Add record source") }}</h1>
        <form @submit="onSubmit($event)">
            <fieldset class="rows">
                <ol>
                    <li>
                        <label class="required" for="name">
                            {{ $__("Name") }}:
                        </label>
                        <input
                            id="name"
                            v-model="record_source.name"
                            required
                        />
                        <span class="required">{{ $__("Required") }}</span>
                    </li>
                    <li>
                        <label for="can_be_edited">
                            {{ $__("Can be edited") }}:
                        </label>
                        <input
                            id="can_be_edited"
                            type="checkbox"
                            v-model="record_source.can_be_edited"
                        />
                    </li>
                </ol>
            </fieldset>
            <fieldset class="action">
                <input
                    type="submit"
                    class="btn btn-primary"
                    :value="$__('Submit')"
                />
                <router-link
                    :to="{ name: 'RecordSourcesList' }"
                    role="button"
                    class="cancel"
                    >{{ $__("Cancel") }}</router-link
                >
            </fieldset>
        </form>
    </div>
</template>

<script>
import { inject } from "vue";
import { setMessage, setError, setWarning } from "../../../messages";
import { APIClient } from "../../../fetch/api-client.js";

export default {
    setup() {
        const { setMessage } = inject("mainStore");
        return {
            setMessage,
        };
    },
    data() {
        return {
            record_source: {
                record_source_id: null,
                name: "",
                can_be_edited: false,
            },
            initialized: false,
        };
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            if (to.params.record_source_id) {
                vm.getRecordSource(to.params.record_source_id);
            } else {
                vm.initialized = true;
            }
        });
    },
    methods: {
        async getRecordSource(record_source_id) {
            const client = APIClient.record_sources;
            client.record_sources.get(record_source_id).then(
                record_source => {
                    this.record_source = record_source;
                    this.record_source_id = record_source_id;
                    this.initialized = true;
                },
                error => {}
            );
        },
        onSubmit(e) {
            e.preventDefault();
            const client = APIClient.record_sources;
            let response;
            // RO attribute
            delete this.record_source.record_source_id;
            if (this.record_source_id) {
                // update
                response = client.record_sources
                    .update(this.record_source, this.record_source_id)
                    .then(
                        success => {
                            setMessage(this.$__("Record source updated!"));
                            this.$router.push({ name: "RecordSourcesList" });
                        },
                        error => {}
                    );
            } else {
                response = client.record_sources
                    .create(this.record_source)
                    .then(
                        success => {
                            setMessage(this.$__("Record source created!"));
                            this.$router.push({ name: "RecordSourcesList" });
                        },
                        error => {}
                    );
            }
        },
    },
};
</script>
