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
                <router-link
                    :to="`/cgi-bin/koha/erm/licenses/delete/${license.license_id}`"
                    :title="$__('Delete')"
                    ><i class="fa fa-trash"></i
                ></router-link>
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
import { inject } from 'vue'
import { fetchLicense } from "../../fetch"

export default {
    setup() {
        const format_date = $date

        const AVStore = inject('AVStore')
        const { get_lib_from_av } = AVStore

        return {
            format_date,
            get_lib_from_av,
        }
    },
    data() {
        return {
            license: {
                license_id: null,
                name: '',
                vendor_id: null,
                vendor: null,
                description: '',
                type: '',
                status: '',
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
            const license = await fetchLicense(license_id)
            this.license = license
            this.initialized = true
        },
    },
    components: {
    },
    name: "LicensesShow",
}
</script>
<style scoped>
.action_links a {
    padding-left: 0.2em;
    font-size: 11px;
}
#license_documents ul {
    padding-left: 0px;
}
</style>
