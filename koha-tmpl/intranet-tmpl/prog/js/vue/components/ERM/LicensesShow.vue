<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="licenses_show">
        <h2>
            {{ $__("License #%s").format(license.license_id) }}
            <span class="action_links">
                <router-link
                    :to="`/cgi-bin/koha/erm/licenses/edit/${license.license_id}`"
                    :title="$__('Edit')"
                    ><i class="fa fa-pencil"></i
                ></router-link>
                <a @click="delete_license(license.license_id, license.name)"
                    ><i class="fa fa-trash"></i
                ></a>
            </span>
        </h2>
        <div>
            <fieldset class="rows">
                <ol>
                    <li>
                        <label>{{ $__("License name") }}:</label>
                        <span>
                            {{ license.name }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $__("Vendor") }}:</label>
                        <span v-if="license.vendor_id">
                            <a
                                :href="`/cgi-bin/koha/acqui/booksellers.pl?booksellerid=${license.vendor_id}`"
                            >
                                {{ license.vendor.name }}
                            </a>
                        </span>
                    </li>
                    <li>
                        <label>{{ $__("Description") }}:</label>
                        <span>
                            {{ license.description }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $__("Type") }}:</label>
                        <span>{{
                            get_lib_from_av("av_license_types", license.type)
                        }}</span>
                    </li>
                    <li>
                        <label>{{ $__("Status") }}:</label>
                        <span>{{
                            get_lib_from_av(
                                "av_license_statuses",
                                license.status
                            )
                        }}</span>
                    </li>

                    <li>
                        <label>{{ $__("Started on") }}:</label>
                        <span>{{ format_date(license.started_on) }}</span>
                    </li>

                    <li>
                        <label>{{ $__("Ended on") }}:</label>
                        <span>{{ format_date(license.ended_on) }}</span>
                    </li>
                    <li v-if="license.user_roles.length">
                        <label>{{ $__("Users") }}</label>
                        <table>
                            <thead>
                                <th>{{ $__("Name") }}</th>
                                <th>{{ $__("Role") }}</th>
                            </thead>
                            <tbody>
                                <tr
                                    v-for="(
                                        role, counter
                                    ) in license.user_roles"
                                    v-bind:key="counter"
                                >
                                    <td>{{ patron_to_html(role.patron) }}</td>
                                    <td>
                                        {{
                                            get_lib_from_av(
                                                "av_user_roles",
                                                role.role
                                            )
                                        }}
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </li>
                    <li v-if="license.documents.length">
                        <label>{{ $__("Documents") }}</label>
                        <div id="license_documents">
                            <ul>
                                <li
                                    v-for="document in license.documents"
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
                    </li>
                </ol>
            </fieldset>
            <fieldset class="action">
                <router-link
                    to="/cgi-bin/koha/erm/licenses"
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
        const format_date = $date
        const patron_to_html = $patron_to_html

        const { setConfirmationDialog, setMessage } = inject("mainStore")

        const AVStore = inject("AVStore")
        const { get_lib_from_av } = AVStore

        return {
            format_date,
            patron_to_html,
            get_lib_from_av,
            setConfirmationDialog,
            setMessage,
        }
    },
    data() {
        return {
            license: {
                license_id: null,
                name: "",
                vendor_id: null,
                vendor: null,
                description: "",
                type: "",
                status: "",
                user_roles: [],
                started_on: undefined,
                ended_on: undefined,
            },
            initialized: false,
        }
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.license = vm.getLicense(to.params.license_id)
        })
    },
    methods: {
        async getLicense(license_id) {
            const client = APIClient.erm
            client.licenses.get(license_id).then(
                license => {
                    this.license = license
                    this.initialized = true
                },
                error => {}
            )
        },
        delete_license: function (license_id, license_name) {
            this.setConfirmationDialog(
                {
                    title: this.$__(
                        "Are you sure you want to remove this license?"
                    ),
                    message: license_name,
                    accept_label: this.$__("Yes, delete"),
                    cancel_label: this.$__("No, do not delete"),
                },
                () => {
                    const client = APIClient.erm
                    client.licenses.delete(license_id).then(
                        success => {
                            this.setMessage(
                                this.$__("License %s deleted").format(
                                    license_name
                                )
                            )
                            this.$router.push("/cgi-bin/koha/erm/licenses")
                        },
                        error => {}
                    )
                }
            )
        },
    },
    components: {},
    name: "LicensesShow",
}
</script>
<style scoped>
.action_links a {
    padding-left: 0.2em;
    font-size: 11px;
    cursor: pointer;
}
#license_documents ul {
    padding-left: 0px;
}
</style>
