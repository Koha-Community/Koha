<template>
    <div v-if="!this.initialized">{{ $t("Loading") }}</div>
    <div v-else id="agreements_add">
        <h2 v-if="agreement.agreement_id">
            {{ $t("Edit agreement .id", { id: agreement.agreement_id }) }}
        </h2>
        <h2 v-else>{{ $t("New agreement") }}</h2>
        <div>
            <form @submit="onSubmit($event)">
                <fieldset class="rows">
                    <ol>
                        <li>
                            <label class="required" for="agreement_name"
                                >{{ $t("Agreement name") }}:</label
                            >
                            <input
                                id="agreement_name"
                                v-model="agreement.name"
                                :placeholder="$t('Agreement name')"
                                required
                            />
                            <span class="required">{{ $t("Required") }}</span>
                        </li>
                        <li>
                            <label for="agreement_vendor_id"
                                >{{ $t("Vendor") }}:</label
                            >
                            <select
                                id="agreement_vendor_id"
                                v-model="agreement.vendor_id"
                            >
                                <option value=""></option>
                                <option
                                    v-for="vendor in vendors"
                                    :key="vendor.vendor_id"
                                    :value="vendor.id"
                                    :selected="
                                        vendor.id == agreement.vendor_id
                                            ? true
                                            : false
                                    "
                                >
                                    {{ vendor.name }}
                                </option>
                            </select>
                        </li>
                        <li>
                            <label for="agreement_description"
                                >{{ $t("Description") }}:
                            </label>
                            <textarea
                                id="agreement_description"
                                v-model="agreement.description"
                                :placeholder="$t('Description')"
                                rows="10"
                                cols="50"
                                required
                            />
                            <span class="required">{{ $t("Required") }}</span>
                        </li>
                        <li>
                            <label for="agreement_status"
                                >{{ $t("Status") }}:</label
                            >
                            <select
                                id="agreement_status"
                                v-model="agreement.status"
                                @change="onStatusChange($event)"
                                required
                            >
                                <option value=""></option>
                                <option
                                    v-for="status in av_agreement_statuses"
                                    :key="status.authorised_values"
                                    :value="status.authorised_value"
                                    :selected="
                                        status.authorised_value ==
                                        agreement.status
                                            ? true
                                            : false
                                    "
                                >
                                    {{ status.lib }}
                                </option>
                            </select>
                            <span class="required">{{ $t("Required") }}</span>
                        </li>
                        <li>
                            <label for="agreement_closure_reason"
                                >{{ $t("Closure reason") }}:</label
                            >
                            <select
                                id="agreement_closure_reason"
                                v-model="agreement.closure_reason"
                                :disabled="
                                    agreement.status == 'closed' ? false : true
                                "
                            >
                                <option value=""></option>
                                <option
                                    v-for="r in av_agreement_closure_reasons"
                                    :key="r.authorised_values"
                                    :value="r.authorised_value"
                                    :selected="
                                        r.authorised_value ==
                                        agreement.closure_reason
                                            ? true
                                            : false
                                    "
                                >
                                    {{ r.lib }}
                                </option>
                            </select>
                        </li>
                        <li>
                            <label for="agreement_is_perpetual" class="radio"
                                >{{ $t("Is perpetual") }}:</label
                            >
                            <label for="agreement_is_perpetual_yes">
                                <input
                                    type="radio"
                                    name="is_perpetual"
                                    id="agreement_is_perpetual_yes"
                                    :value="true"
                                    v-model="agreement.is_perpetual"
                                />
                                Yes
                            </label>
                            <label for="agreement_is_perpetual_no">
                                <input
                                    type="radio"
                                    name="is_perpetual"
                                    id="agreement_is_perpetual_no"
                                    :value="false"
                                    v-model="agreement.is_perpetual"
                                />
                                No
                            </label>
                        </li>
                        <li>
                            <label for="agreement_renewal_priority"
                                >{{ $t("Renewal priority") }}:</label
                            >
                            <select v-model="agreement.renewal_priority">
                                <option value=""></option>
                                <option
                                    v-for="p in av_agreement_renewal_priorities"
                                    :key="p.authorised_values"
                                    :value="p.authorised_value"
                                    :selected="
                                        p.authorised_value ==
                                        agreement.renewal_priority
                                            ? true
                                            : false
                                    "
                                >
                                    {{ p.lib }}
                                </option>
                            </select>
                        </li>
                        <li>
                            <label for="agreement_license_info"
                                >{{ $t("License info") }}:
                            </label>
                            <textarea
                                id="agreement_license_info"
                                v-model="agreement.license_info"
                                placeholder="License info"
                            />
                        </li>

                        <AgreementPeriods :periods="agreement.periods" />
                        <AgreementUserRoles
                            :user_roles="agreement.user_roles"
                            :av_agreement_user_roles="av_agreement_user_roles"
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
                            :av_agreement_relationships="
                                av_agreement_relationships
                            "
                        />
                        <AgreementDocuments :documents="agreement.documents" />
                    </ol>
                </fieldset>
                <fieldset class="action">
                    <input type="submit" value="Submit" />
                    <router-link
                        to="/cgi-bin/koha/erm/agreements"
                        role="button"
                        class="cancel"
                        >{{ $t("Cancel") }}</router-link
                    >
                </fieldset>
            </form>
        </div>
    </div>
</template>

<script>
import AgreementPeriods from './AgreementPeriods.vue'
import AgreementUserRoles from './AgreementUserRoles.vue'
import AgreementLicenses from './AgreementLicenses.vue'
import AgreementRelationships from './AgreementRelationships.vue'
import AgreementDocuments from './AgreementDocuments.vue'
import { useVendorStore } from "../../stores/vendors"
import { useAVStore } from "../../stores/authorised_values"
import { setMessage, setError, setWarning } from "../../messages"
import { fetchAgreement } from '../../fetch'
import { storeToRefs } from "pinia"

export default {
    setup() {
        const vendorStore = useVendorStore()
        const { vendors } = storeToRefs(vendorStore)
        const AVStore = useAVStore()
        const {
            av_agreement_statuses,
            av_agreement_closure_reasons,
            av_agreement_renewal_priorities,
            av_agreement_user_roles,
            av_agreement_license_statuses,
            av_agreement_license_location,
            av_agreement_relationships,
        } = storeToRefs(AVStore)

        return {
            vendors,
            av_agreement_statuses,
            av_agreement_closure_reasons,
            av_agreement_renewal_priorities,
            av_agreement_user_roles,
            av_agreement_license_statuses,
            av_agreement_license_location,
            av_agreement_relationships,
        }
    },
    data() {
        return {
            agreement: {
                agreement_id: null,
                name: '',
                vendor_id: null,
                description: '',
                status: '',
                closure_reason: '',
                is_perpetual: false,
                renewal_priority: '',
                license_info: '',
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
                vm.agreement = vm.getAgreement(to.params.agreement_id)
            } else {
                vm.initialized = true
            }
        })
    },
    methods: {
        async getAgreement(agreement_id) {
            const agreement = await fetchAgreement(agreement_id)
            this.agreement = agreement
            this.initialized = true
        },
        checkForm(agreement) {
            let errors = []

            let agreement_licenses = agreement.agreement_licenses
            // Do not use al.license.name here! Its name is not the one linked with al.license_id
            // At this point al.license is meaningless, form/template only modified al.license_id
            const license_ids = agreement_licenses.map(al => al.license_id)
            const duplicate_license_ids = license_ids.filter((id, i) => license_ids.indexOf(id) !== i)

            if (duplicate_license_ids.length) {
                errors.push(this.$t("A license is used several times"))
            }

            errors.forEach(function (e) {
                setWarning(e)
            })
            return !errors.length
        },
        onSubmit(e) {
            e.preventDefault()

            //let agreement= Object.assign( {} ,this.agreement); // copy
            let agreement = JSON.parse(JSON.stringify(this.agreement)) // copy

            if (!this.checkForm(agreement)) {
                return false
            }

            let apiUrl = '/api/v1/erm/agreements'

            let method = 'POST'
            if (agreement.agreement_id) {
                method = 'PUT'
                apiUrl += '/' + agreement.agreement_id
            }
            delete agreement.agreement_id
            agreement.is_perpetual = agreement.is_perpetual ? true : false

            if (agreement.vendor_id == "") {
                agreement.vendor_id = null
            }

            agreement.periods.forEach(p => {
                p.started_on = $date_to_rfc3339(p.started_on)
                p.ended_on = p.ended_on ? $date_to_rfc3339(p.ended_on) : null
                p.cancellation_deadline = p.cancellation_deadline ? $date_to_rfc3339(p.cancellation_deadline) : null
            })

            agreement.periods = agreement.periods.map(({ agreement_id, agreement_period_id, ...keepAttrs }) => keepAttrs)

            agreement.user_roles = agreement.user_roles.map(({ patron, patron_str, ...keepAttrs }) => keepAttrs)

            agreement.agreement_licenses = agreement.agreement_licenses.map(({ license, agreement_id, agreement_license_id, ...keepAttrs }) => keepAttrs)

            agreement.agreement_relationships = agreement.agreement_relationships.map(({ related_agreement, ...keepAttrs }) => keepAttrs)

            agreement.documents = agreement.documents.map(({ document_id, ...keepAttrs }) => keepAttrs)

            delete agreement.agreement_packages

            const options = {
                method: method,
                body: JSON.stringify(agreement),
                headers: {
                    'Content-Type': 'application/json;charset=utf-8'
                },
            }

            fetch(apiUrl, options)
                .then(response => {
                    if (response.status == 200) {
                        this.$router.push("/cgi-bin/koha/erm/agreements")
                        setMessage(this.$t("Agreement updated"))
                    } else if (response.status == 201) {
                        this.$router.push("/cgi-bin/koha/erm/agreements")
                        setMessage(this.$t("Agreement created"))
                    } else {
                        setError(response.message || response.statusText)
                    }
                }).catch(
                    (error) => {
                        this.setError(error)
                    }
                )
        },
        onStatusChange(event) {
            if (event.target.value != 'closed') {
                this.agreement.closure_reason = ''
            }
        }
    },
    components: {
        AgreementPeriods,
        AgreementUserRoles,
        AgreementLicenses,
        AgreementRelationships,
        AgreementDocuments,
    },
    name: "AgreementsFormAdd",
}
</script>
