<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="agreements_add">
        <h2 v-if="agreement.agreement_id">
            {{ $__("Edit agreement #%s").format(agreement.agreement_id) }}
        </h2>
        <h2 v-else>{{ $__("New agreement") }}</h2>
        <div>
            <form @submit="onSubmit($event)">
                <fieldset class="rows">
                    <ol>
                        <li>
                            <label for="agreement_name" class="required"
                                >{{ $__("Agreement name") }}:</label
                            >
                            <input
                                id="agreement_name"
                                v-model="agreement.name"
                                :placeholder="$__('Agreement name')"
                                required
                            />
                            <span class="required">{{ $__("Required") }}</span>
                        </li>
                        <li>
                            <label for="agreement_vendor_id"
                                >{{ $__("Vendor") }}:</label
                            >
                            <v-select
                                id="agreement_vendor_id"
                                v-model="agreement.vendor_id"
                                label="display_name"
                                :reduce="vendor => vendor.id"
                                :options="vendors"
                            />
                        </li>
                        <li>
                            <label for="agreement_description"
                                >{{ $__("Description") }}:
                            </label>
                            <textarea
                                id="agreement_description"
                                v-model="agreement.description"
                                :placeholder="$__('Description')"
                                rows="10"
                                cols="50"
                            />
                        </li>
                        <li>
                            <label for="agreement_status" class="required"
                                >{{ $__("Status") }}:</label
                            >
                            <v-select
                                id="agreement_status"
                                v-model="agreement.status"
                                label="description"
                                :reduce="av => av.value"
                                :options="av_agreement_statuses"
                                @option:selected="onStatusChanged"
                                :required="!agreement.status"
                            >
                                <template #search="{ attributes, events }">
                                    <input
                                        :required="!agreement.status"
                                        class="vs__search"
                                        v-bind="attributes"
                                        v-on="events"
                                    />
                                </template>
                            </v-select>
                            <span class="required">{{ $__("Required") }}</span>
                        </li>
                        <li>
                            <label for="agreement_closure_reason"
                                >{{ $__("Closure reason") }}:</label
                            >
                            <v-select
                                id="agreement_closure_reason"
                                v-model="agreement.closure_reason"
                                label="description"
                                :reduce="av => av.value"
                                :options="av_agreement_closure_reasons"
                                :disabled="
                                    agreement.status == 'closed' ? false : true
                                "
                            />
                        </li>
                        <li>
                            <label for="agreement_is_perpetual"
                                >{{ $__("Is perpetual") }}:</label
                            >
                            <label
                                class="radio"
                                for="agreement_is_perpetual_yes"
                                >{{ $__("Yes") }}:
                                <input
                                    type="radio"
                                    name="is_perpetual"
                                    id="agreement_is_perpetual_yes"
                                    :value="true"
                                    v-model="agreement.is_perpetual"
                                />
                            </label>
                            <label class="radio" for="agreement_is_perpetual_no"
                                >{{ $__("No") }}:
                                <input
                                    type="radio"
                                    name="is_perpetual"
                                    id="agreement_is_perpetual_no"
                                    :value="false"
                                    v-model="agreement.is_perpetual"
                                />
                            </label>
                        </li>
                        <li>
                            <label for="agreement_renewal_priority"
                                >{{ $__("Renewal priority") }}:</label
                            >
                            <v-select
                                id="agreement_renewal_priority"
                                v-model="agreement.renewal_priority"
                                label="description"
                                :reduce="av => av.value"
                                :options="av_agreement_renewal_priorities"
                            />
                        </li>
                        <li>
                            <label for="agreement_license_info"
                                >{{ $__("License info") }}:
                            </label>
                            <textarea
                                id="agreement_license_info"
                                v-model="agreement.license_info"
                                placeholder="License info"
                            />
                        </li>
                    </ol>
                </fieldset>
                <AgreementPeriods :periods="agreement.periods" />
                <UserRoles
                    :user_type="$__('Agreement user %s')"
                    :user_roles="agreement.user_roles"
                    :av_user_roles="av_user_roles"
                />
                <AgreementLicenses
                    :agreement_licenses="agreement.agreement_licenses"
                    :av_agreement_license_statuses="
                        av_agreement_license_statuses
                    "
                    :av_agreement_license_location="
                        av_agreement_license_location
                    "
                />
                <AgreementRelationships
                    :agreement_id="agreement.agreement_id"
                    :relationships="agreement.agreement_relationships"
                    :av_agreement_relationships="av_agreement_relationships"
                />
                <Documents :documents="agreement.documents" />
                <fieldset class="action">
                    <ButtonSubmit />
                    <router-link
                        :to="{ name: 'AgreementsList' }"
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
import AgreementPeriods from "./AgreementPeriods.vue"
import UserRoles from "./UserRoles.vue"
import AgreementLicenses from "./AgreementLicenses.vue"
import AgreementRelationships from "./AgreementRelationships.vue"
import Documents from "./Documents.vue"
import ButtonSubmit from "../ButtonSubmit.vue"
import { setMessage, setError, setWarning } from "../../messages"
import { APIClient } from "../../fetch/api-client.js"
import { storeToRefs } from "pinia"

export default {
    setup() {
        const vendorStore = inject("vendorStore")
        const { vendors } = storeToRefs(vendorStore)

        const AVStore = inject("AVStore")
        const {
            av_agreement_statuses,
            av_agreement_closure_reasons,
            av_agreement_renewal_priorities,
            av_user_roles,
            av_agreement_license_statuses,
            av_agreement_license_location,
            av_agreement_relationships,
        } = storeToRefs(AVStore)

        return {
            vendors,
            av_agreement_statuses,
            av_agreement_closure_reasons,
            av_agreement_renewal_priorities,
            av_user_roles,
            av_agreement_license_statuses,
            av_agreement_license_location,
            av_agreement_relationships,
            max_allowed_packet,
        }
    },
    data() {
        return {
            agreement: {
                agreement_id: null,
                name: "",
                vendor_id: null,
                description: "",
                status: "",
                closure_reason: "",
                is_perpetual: false,
                renewal_priority: "",
                license_info: "",
                periods: [],
                user_roles: [],
                agreement_licenses: [],
                agreement_relationships: [],
                documents: [],
            },
            initialized: false,
        }
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            if (to.params.agreement_id) {
                vm.getAgreement(to.params.agreement_id)
            } else {
                vm.initialized = true
            }
        })
    },
    methods: {
        async getAgreement(agreement_id) {
            const client = APIClient.erm
            client.agreements.get(agreement_id).then(
                data => {
                    this.agreement = data
                    this.initialized = true
                },
                error => {}
            )
        },
        checkForm(agreement) {
            let errors = []

            let agreement_licenses = agreement.agreement_licenses
            // Do not use al.license.name here! Its name is not the one linked with al.license_id
            // At this point al.license is meaningless, form/template only modified al.license_id
            const license_ids = agreement_licenses.map(al => al.license_id)
            const duplicate_license_ids = license_ids.filter(
                (id, i) => license_ids.indexOf(id) !== i
            )

            if (duplicate_license_ids.length) {
                errors.push(this.$__("A license is used several times"))
            }

            const related_agreement_ids = agreement.agreement_relationships.map(
                rs => rs.related_agreement_id
            )
            const duplicate_related_agreement_ids =
                related_agreement_ids.filter(
                    (id, i) => related_agreement_ids.indexOf(id) !== i
                )

            if (duplicate_related_agreement_ids.length) {
                errors.push(
                    this.$__(
                        "An agreement is used as relationship several times"
                    )
                )
            }

            if (
                agreement_licenses.filter(al => al.status == "controlling")
                    .length > 1
            ) {
                errors.push(this.$__("Only one controlling license is allowed"))
            }

            if (
                agreement_licenses.filter(al => al.status == "controlling")
                    .length > 1
            ) {
                errors.push(this.$__("Only one controlling license is allowed"))
            }

            let documents_with_uploaded_files = agreement.documents.filter(
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
            agreement.user_roles.forEach((user, i) => {
                if (user.patron_str === "") {
                    errors.push(
                        this.$__("Agreement user %s is missing a user").format(
                            i + 1
                        )
                    )
                }
            })
            setWarning(errors.join("<br>"))
            return !errors.length
        },
        onSubmit(e) {
            e.preventDefault()

            //let agreement= Object.assign( {} ,this.agreement); // copy
            let agreement = JSON.parse(JSON.stringify(this.agreement)) // copy
            let agreement_id = agreement.agreement_id

            if (!this.checkForm(agreement)) {
                return false
            }

            delete agreement.agreement_id
            delete agreement.vendor
            agreement.is_perpetual = agreement.is_perpetual ? true : false

            if (agreement.vendor_id == "") {
                agreement.vendor_id = null
            }

            agreement.periods = agreement.periods.map(
                ({ agreement_id, agreement_period_id, ...keepAttrs }) =>
                    keepAttrs
            )

            agreement.user_roles = agreement.user_roles.map(
                ({ patron, patron_str, ...keepAttrs }) => keepAttrs
            )

            agreement.agreement_licenses = agreement.agreement_licenses.map(
                ({
                    license,
                    agreement_id,
                    agreement_license_id,
                    ...keepAttrs
                }) => keepAttrs
            )

            agreement.agreement_relationships =
                agreement.agreement_relationships.map(
                    ({ related_agreement, ...keepAttrs }) => keepAttrs
                )

            agreement.documents = agreement.documents.map(
                ({ file_type, uploaded_on, ...keepAttrs }) => keepAttrs
            )

            delete agreement.agreement_packages

            const client = APIClient.erm
            if (agreement_id) {
                client.agreements.update(agreement, agreement_id).then(
                    success => {
                        setMessage(this.$__("Agreement updated"))
                        this.$router.push({ name: "AgreementsList" })
                    },
                    error => {}
                )
            } else {
                client.agreements.create(agreement).then(
                    success => {
                        setMessage(this.$__("Agreement created"))
                        this.$router.push({ name: "AgreementsList" })
                    },
                    error => {}
                )
            }
        },
        onStatusChanged(e) {
            if (e.value != "closed") {
                this.agreement.closure_reason = ""
            }
        },
    },
    components: {
        AgreementPeriods,
        UserRoles,
        AgreementLicenses,
        AgreementRelationships,
        Documents,
        ButtonSubmit,
    },
    name: "AgreementsFormAdd",
}
</script>
