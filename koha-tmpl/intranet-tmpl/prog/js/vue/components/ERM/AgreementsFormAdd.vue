<template>
    <h2 v-if="agreement.agreement_id">Edit agreement</h2>
    <h2 v-else>New agreement</h2>
    <div>
        <form @submit="onSubmit($event)">
            <fieldset class="rows">
                <ol>
                    <li>
                        <label class="required" for="agreement_name"
                            >Agreement name:</label
                        >
                        <input
                            id="agreement_name"
                            v-model="agreement.name"
                            placeholder="Agreement name"
                            required
                        />
                        <span class="required">Required</span>
                    </li>
                    <li>
                        <label for="agreement_vendor_id">Vendor:</label>
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
                        <label for="agreement_description">Description: </label>
                        <textarea
                            id="agreement_description"
                            v-model="agreement.description"
                            placeholder="Description"
                            rows="10"
                            cols="50"
                            required
                        />
                        <span class="required">Required</span>
                    </li>
                    <li>
                        <label for="agreement_status">Status: </label>
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
                                    status.authorised_value == agreement.status
                                        ? true
                                        : false
                                "
                            >
                                {{ status.lib }}
                            </option>
                        </select>
                        <span class="required">Required</span>
                    </li>
                    <li>
                        <label for="agreement_closure_reason"
                            >Closure reason:</label
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
                            >Is perpetual:</label
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
                            >Renewal priority:</label
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
                            >License info:
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
                </ol>
            </fieldset>
            <fieldset class="action">
                <input type="submit" value="Submit" />
                <router-link
                    to="/cgi-bin/koha/erm/agreements"
                    role="button"
                    class="cancel"
                    >Cancel</router-link
                >
            </fieldset>
        </form>
    </div>
</template>

<script>
import AgreementPeriods from './AgreementPeriods.vue'
import AgreementUserRoles from './AgreementUserRoles.vue'
import AgreementLicenses from './AgreementLicenses.vue'
import { useVendorStore } from "../../stores/vendors"
import { useAVStore } from "../../stores/authorised_values"
import { useMainStore } from "../../stores/main"
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
        } = storeToRefs(AVStore)

        const mainStore = useMainStore()
        const { setMessage, setError, resetMessages } = mainStore

        return {
            vendors,
            av_agreement_statuses,
            av_agreement_closure_reasons,
            av_agreement_renewal_priorities,
            av_agreement_user_roles,
            av_agreement_license_statuses,
            av_agreement_license_location,
            setMessage, setError, resetMessages,
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
            }
        }
    },
    beforeRouteEnter(to, from, next) {
        if (to.params.agreement_id) {
            next(vm => {
                vm.agreement = vm.getAgreement(to.params.agreement_id)
            })
        } else {
            next()
        }
    },
    methods: {
        async getAgreement(agreement_id) {
            const agreement = await fetchAgreement(agreement_id)
            this.agreement = agreement
        },
        onSubmit(e) {
            e.preventDefault()

            //let agreement= Object.assign( {} ,this.agreement); // copy
            let agreement = JSON.parse(JSON.stringify(this.agreement)) // copy
            let apiUrl = '/api/v1/erm/agreements'

            let method = 'POST'
            if (agreement.agreement_id) {
                method = 'PUT'
                apiUrl += '/' + agreement.agreement_id
            }
            delete agreement.agreement_id
            agreement.is_perpetual = agreement.is_perpetual ? true : false

            agreement.periods.forEach(p => {
                p.started_on = $date_to_rfc3339(p.started_on)
                p.ended_on = p.ended_on ? $date_to_rfc3339(p.ended_on) : null
                p.cancellation_deadline = p.cancellation_deadline ? $date_to_rfc3339(p.cancellation_deadline) : null
            })

            agreement.periods = agreement.periods.map(({ agreement_id, agreement_period_id, ...keepAttrs }) => keepAttrs)

            agreement.user_roles = agreement.user_roles.map(({ patron, patron_str, ...keepAttrs }) => keepAttrs)

            agreement.agreement_licenses = agreement.agreement_licenses.map(({ license, agreement_id, agreement_license_id, ...keepAttrs }) => keepAttrs)

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
                        this.setMessage('Agreement updated')
                    } else if (response.status == 201) {
                        this.$router.push("/cgi-bin/koha/erm/agreements")
                        this.setMessage('Agreement created')
                    } else {
                        this.setError(response.message || response.statusText)
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
    props: {
        agreement_id: Number,
    },
    components: {
        AgreementPeriods,
        AgreementUserRoles,
        AgreementLicenses,
    },
    name: "AgreementsFormAdd",
}
</script>
