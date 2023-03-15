<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="licenses_add">
        <h2 v-if="license.license_id">
            {{ $__("Edit license %s").format(license.license_id) }}
        </h2>
        <h2 v-else>{{ $__("New license") }}</h2>
        <div>
            <form @submit="onSubmit($event)">
                <div class="page-section">
                    <fieldset class="rows">
                        <ol>
                            <li>
                                <label class="required" for="license_name"
                                    >{{ $__("License name") }}:</label
                                >
                                <input
                                    id="license_name"
                                    v-model="license.name"
                                    :placeholder="$__('License name')"
                                    required
                                />
                                <span class="required">{{
                                    $__("Required")
                                }}</span>
                            </li>
                            <li>
                                <label for="license_vendor_id"
                                    >{{ $__("Vendor") }}:</label
                                >
                                <v-select
                                    id="license_vendor_id"
                                    v-model="license.vendor_id"
                                    label="name"
                                    :reduce="vendor => vendor.id"
                                    :options="vendors"
                                />
                            </li>
                            <li>
                                <label
                                    for="license_description"
                                    class="required"
                                    >{{ $__("Description") }}:
                                </label>
                                <textarea
                                    id="license_description"
                                    v-model="license.description"
                                    :placeholder="$__('Description')"
                                    rows="10"
                                    cols="50"
                                    required
                                />
                                <span class="required">{{
                                    $__("Required")
                                }}</span>
                            </li>
                            <li>
                                <label for="license_type" class="required"
                                    >{{ $__("Type") }}:</label
                                >
                                <v-select
                                    id="license_type"
                                    v-model="license.type"
                                    label="description"
                                    :reduce="av => av.value"
                                    :options="av_license_types"
                                >
                                    <template #search="{ attributes, events }">
                                        <input
                                            :required="!license.type"
                                            class="vs__search"
                                            v-bind="attributes"
                                            v-on="events"
                                        />
                                    </template>
                                </v-select>
                                <span class="required">{{
                                    $__("Required")
                                }}</span>
                            </li>
                            <li>
                                <label for="license_status" class="required"
                                    >{{ $__("Status") }}:</label
                                >
                                <v-select
                                    id="license_status"
                                    v-model="license.status"
                                    :reduce="av => av.value"
                                    :options="av_license_statuses"
                                    label="description"
                                >
                                    <template #search="{ attributes, events }">
                                        <input
                                            :required="!license.status"
                                            class="vs__search"
                                            v-bind="attributes"
                                            v-on="events"
                                        />
                                    </template>
                                </v-select>
                                <span class="required">{{
                                    $__("Required")
                                }}</span>
                            </li>
                            <li>
                                <label for="started_on"
                                    >{{ $__("Start date") }}:</label
                                >
                                <flat-pickr
                                    id="started_on"
                                    v-model="license.started_on"
                                    :config="fp_config"
                                    data-date_to="ended_on"
                                />
                            </li>
                            <li>
                                <label for="ended_on"
                                    >{{ $__("End date") }}:</label
                                >
                                <flat-pickr
                                    id="ended_on"
                                    v-model="license.ended_on"
                                    :config="fp_config"
                                />
                            </li>
                        </ol>
                    </fieldset>
                </div>
                <UserRoles
                    :user_type="$__('License user')"
                    :user_roles="license.user_roles"
                    :av_user_roles="av_user_roles"
                />
                <Documents :documents="license.documents" />
                <fieldset class="action">
                    <input type="submit" :value="$__('Submit')" />
                    <router-link
                        to="/cgi-bin/koha/erm/licenses"
                        role="button"
                        class="cancel"
                        >{{ $__("Cancel") }}</router-link
                    >
                </fieldset>
            </form>
        </div>
    </div>
</template>

<script>
import { inject } from "vue"
import flatPickr from "vue-flatpickr-component"
import UserRoles from "./UserRoles.vue"
import Documents from "./Documents.vue"
import { setMessage, setWarning } from "../../messages"
import { APIClient } from "../../fetch/api-client.js"
import { storeToRefs } from "pinia"

export default {
    setup() {
        const vendorStore = inject("vendorStore")
        const { vendors } = storeToRefs(vendorStore)

        const AVStore = inject("AVStore")
        const { av_license_types, av_license_statuses, av_user_roles } =
            storeToRefs(AVStore)

        return {
            vendors,
            av_license_types,
            av_license_statuses,
            av_user_roles,
            max_allowed_packet,
        }
    },
    data() {
        return {
            fp_config: flatpickr_defaults,
            license: {
                license_id: null,
                name: "",
                vendor_id: null,
                description: "",
                type: "",
                status: "",
                started_on: undefined,
                ended_on: undefined,
                user_roles: [],
                documents: [],
            },
            initialized: false,
        }
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            if (to.params.license_id) {
                vm.license = vm.getLicense(to.params.license_id)
            } else {
                vm.initialized = true
            }
        })
    },
    methods: {
        async getLicense(license_id) {
            const client = APIClient.erm
            client.licenses.get(license_id).then(license => {
                this.license = license
                this.initialized = true
            })
        },
        checkForm(license) {
            let errors = []

            let documents_with_uploaded_files = license.documents.filter(
                doc => typeof doc.file_content !== "undefined"
            )
            if (
                documents_with_uploaded_files.filter(
                    doc => atob(doc.file_content).length >= max_allowed_packet
                ).length >= 1
            ) {
                errors.push(
                    this.$__("File size exceeds maximum allowed: %s MB").format(
                        (max_allowed_packet / (1024 * 1024)).toFixed(2)
                    )
                )
            }
            errors.forEach(function (e) {
                setWarning(e)
            })
            return !errors.length
        },
        onSubmit(e) {
            e.preventDefault()

            let license = JSON.parse(JSON.stringify(this.license)) // copy
            let license_id = license.license_id

            if (!this.checkForm(license)) {
                return false
            }

            let apiUrl = "/api/v1/erm/licenses"

            let method = "POST"
            if (license.license_id) {
                method = "PUT"
                apiUrl += "/" + license.license_id
            }
            delete license.license_id
            delete license.vendor

            if (license.vendor_id == "") {
                license.vendor_id = null
            }

            license.user_roles = license.user_roles.map(
                ({ patron, patron_str, ...keepAttrs }) => keepAttrs
            )

            license.documents = license.documents.map(
                ({ file_type, uploaded_on, ...keepAttrs }) => keepAttrs
            )

            const client = APIClient.erm
            if (license_id) {
                client.licenses.update(license, license_id).then(
                    success => {
                        setMessage(this.$__("License updated"))
                        this.$router.push("/cgi-bin/koha/erm/licenses")
                    },
                    error => {}
                )
            } else {
                client.licenses.create(license).then(
                    success => {
                        setMessage(this.$__("License created"))
                        this.$router.push("/cgi-bin/koha/erm/licenses")
                    },
                    error => {}
                )
            }
        },
    },
    components: {
        flatPickr,
        UserRoles,
        Documents,
    },
    name: "LicensesFormAdd",
}
</script>
