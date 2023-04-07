<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="processing_show">
        <h2>
            {{ $__("Processing #%s").format(processing.processing_id) }}
            <span class="action_links">
                <router-link
                    :to="`/cgi-bin/koha/preservation/settings/processings/edit/${processing.processing_id}`"
                    :title="$__('Edit')"
                    ><i class="fa fa-pencil"></i
                ></router-link>
                <a @click="doDelete()"><i class="fa fa-trash"></i></a>
            </span>
        </h2>
        <div>
            <fieldset class="rows">
                <ol>
                    <li>
                        <label>{{ $__("Processing name") }}:</label>
                        <span>
                            {{ processing.name }}
                        </span>
                    </li>
                </ol>
            </fieldset>
            <fieldset class="rows">
                <legend>{{ $__("Attributes") }}</legend>
                <ol v-if="processing.attributes.length">
                    <li
                        v-for="(attribute, counter) in processing.attributes"
                        v-bind:key="counter"
                    >
                        <label>{{ attribute.name }}</label>
                        <span v-if="attribute.type == 'authorised_value'">{{
                            $__("Authorized value")
                        }}</span>
                        <span v-else-if="attribute.type == 'free_text'">{{
                            $__("Free text")
                        }}</span>
                        <span v-else-if="attribute.type == 'db_column'">{{
                            $__("Database column")
                        }}</span>
                        <span v-else
                            >{{ $__("Unknown") }} - {{ attribute.type }}</span
                        >
                    </li>
                </ol>
                <span v-else>
                    {{
                        $__(
                            "There are no attributes defined for this processing."
                        )
                    }}
                </span>
            </fieldset>
            <fieldset class="action">
                <router-link
                    to="/cgi-bin/koha/preservation/settings"
                    role="button"
                    class="cancel"
                    >{{ $__("Close") }}</router-link
                >
            </fieldset>
        </div>
    </div>
</template>

<script>
import { inject } from "vue"
import { APIClient } from "../../fetch/api-client.js"

export default {
    setup() {
        const { setConfirmationDialog, setMessage } = inject("mainStore")

        return {
            setConfirmationDialog,
            setMessage,
        }
    },
    data() {
        return {
            processing: {
                processing_id: null,
                name: "",
                attributes: [],
            },
            initialized: false,
        }
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getProcessing(to.params.processing_id)
        })
    },
    beforeRouteUpdate(to, from) {
        this.processing = this.getProcessing(to.params.processing_id)
    },
    methods: {
        async getProcessing(processing_id) {
            const client = APIClient.preservation
            await client.processings.get(processing_id).then(
                processing => {
                    this.processing = processing
                    this.initialized = true
                },
                error => {}
            )
        },
        doDelete: function () {
            this.setConfirmationDialog(
                {
                    title: this.$__(
                        "Are you sure you want to remove this processing?"
                    ),
                    message: this.processing.name,
                    accept_label: this.$__("Yes, delete"),
                    cancel_label: this.$__("No, do not delete"),
                },
                () => {
                    const client = APIClient.preservation
                    client.processings
                        .delete(this.processing.processing_id)
                        .then(
                            success => {
                                this.setMessage(
                                    this.$__("Processing %s deleted").format(
                                        this.processing.name
                                    ),
                                    true
                                )
                                this.$router.push(
                                    "/cgi-bin/koha/preservation/settings"
                                )
                            },
                            error => {}
                        )
                }
            )
        },
    },
    name: "ProcessingsShow",
}
</script>
<style scoped>
.action_links a {
    padding-left: 0.2em;
    font-size: 11px;
    cursor: pointer;
}
</style>
