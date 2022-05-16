<template>
    <div v-if="!this.initialized">Loading...</div>
    <div v-else id="agreements_show">
        <h2>Agreement #{{ agreement.agreement_id }}</h2>
        <div>
            <fieldset class="rows">
                <ol>
                    <li>
                        <label>Agreement name:</label>
                        <span>
                            {{ agreement.name }}
                        </span>
                    </li>
                    <li>
                        <label>Vendor:</label>
                        <span v-if="agreement.vendor_id">
                            {{
                                vendors.find((e) => e.id == agreement.vendor_id)
                                    .name
                            }}
                        </span>
                    </li>
                    <li>
                        <label>Description: </label>
                        <span>
                            {{ agreement.description }}
                        </span>
                    </li>
                    <li>
                        <label>Status: </label>
                        <span>{{
                            get_lib_from_av(
                                av_agreement_statuses,
                                agreement.status
                            )
                        }}</span>
                    </li>
                    <li>
                        <label>Closure reason:</label>
                        <span>{{
                            get_lib_from_av(
                                av_agreement_closure_reasons,
                                agreement.closure_reason
                            )
                        }}</span>
                    </li>
                    <li>
                        <label>Is perpetual:</label>
                        <span v-if="agreement.is_perpetual">Yes</span>
                        <span v-else>No</span>
                    </li>
                    <li>
                        <label>Renewal priority:</label>
                        <span>{{
                            get_lib_from_av(
                                av_agreement_renewal_priorities,
                                agreement.renewal_priority
                            )
                        }}</span>
                    </li>
                    <li>
                        <label>License info: </label>
                        <span>{{ agreement.license_info }}</span>
                    </li>

                    <li>
                        <label>Periods</label>
                        <table>
                            <thead>
                                <th>Period start</th>
                                <th>Period end</th>
                                <th>Cancellation deadline</th>
                                <th>Period note</th>
                            </thead>
                            <tbody>
                                <tr
                                    v-for="(
                                        period, counter
                                    ) in agreement.periods"
                                    v-bind:key="counter"
                                >
                                    <td>
                                        {{ format_date(period.started_on) }}
                                    </td>
                                    <td>{{ format_date(period.ended_on) }}</td>
                                    <td>
                                        {{
                                            format_date(
                                                period.cancellation_deadline
                                            )
                                        }}
                                    </td>
                                    <td>{{ period.notes }}</td>
                                </tr>
                            </tbody>
                        </table>
                    </li>

                    <li>
                        <label>Users</label>
                        <table>
                            <thead>
                                <th>Name</th>
                                <th>Role</th>
                            </thead>
                            <tbody>
                                <tr
                                    v-for="(
                                        role, counter
                                    ) in agreement.user_roles"
                                    v-bind:key="counter"
                                >
                                    <td>{{ patron_to_html(role.patron) }}</td>
                                    <td>
                                        {{
                                            get_lib_from_av(
                                                av_agreement_user_roles,
                                                role.role
                                            )
                                        }}
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </li>

                    <li>
                        <label>Licenses</label>
                        <table>
                            <thead>
                                <th>Name</th>
                                <th>Status</th>
                                <th>Physical location</th>
                                <th>Notes</th>
                                <th>URI</th>
                            </thead>
                            <tbody>
                                <tr
                                    v-for="(
                                        agreement_license, counter
                                    ) in agreement.agreement_licenses"
                                    v-bind:key="counter"
                                >
                                    <td>
                                        <router-link
                                            :to="`/cgi-bin/koha/erm/licenses/${agreement_license.license_id}`"
                                        >
                                            {{ agreement_license.license.name }}
                                        </router-link>
                                    </td>
                                    <td>
                                        {{
                                            get_lib_from_av(
                                                av_agreement_license_statuses,
                                                agreement_license.status
                                            )
                                        }}
                                    </td>
                                    <td>
                                        {{
                                            get_lib_from_av(
                                                av_agreement_license_location,
                                                agreement_license.physical_location
                                            )
                                        }}
                                    </td>
                                    <td>{{ agreement_license.notes }}</td>
                                    <td>{{ agreement_license.uri }}</td>
                                </tr>
                            </tbody>
                        </table>
                    </li>

                    <li>
                        <label>Related agreements</label>
                        <div
                            v-for="relationship in agreement.agreement_relationships"
                            v-bind:key="relationship.related_agreement_id"
                        >
                            <span
                                ><router-link
                                    :to="`/cgi-bin/koha/erm/agreements/${relationship.related_agreement.agreement_id}`"
                                    >{{
                                        relationship.related_agreement.name
                                    }}</router-link
                                ></span
                            >
                            {{
                                get_lib_from_av(
                                    av_agreement_relationships,
                                    relationship.relationship
                                )
                            }}
                            {{ agreement.name }}
                        </div>
                    </li>
                </ol>
            </fieldset>
            <fieldset class="action">
                <router-link
                    to="/cgi-bin/koha/erm/agreements"
                    role="button"
                    class="cancel"
                    >Close</router-link
                >
            </fieldset>
        </div>
    </div>
</template>

<script>
import AgreementPeriods from './AgreementPeriods.vue'
import AgreementUserRoles from './AgreementUserRoles.vue'
import { useVendorStore } from "../../stores/vendors"
import { useAVStore } from "../../stores/authorised_values"
import { fetchAgreement } from "../../fetch"
import { storeToRefs } from "pinia"

export default {
    setup() {
        const format_date = $date
        const patron_to_html = $patron_to_html
        const get_lib_from_av = function (arr, av) {
            let o = arr.find(
                (e) => e.authorised_value == av
            )
            return o ? o.lib : ""
        }
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
            format_date,
            patron_to_html,
            get_lib_from_av,
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
                vendor: null,
                description: '',
                status: '',
                closure_reason: '',
                is_perpetual: false,
                renewal_priority: '',
                license_info: '',
                periods: [],
                user_roles: [],
            },
            initialized: false,
        }
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getAgreement(to.params.agreement_id)
        })
    },
    beforeRouteUpdate(to, from) {
        this.agreement = this.getAgreement(to.params.agreement_id)
    },
    methods: {
        async getAgreement(agreement_id) {
            const agreement = await fetchAgreement(agreement_id)
            this.agreement = agreement
            this.initialized = true
        },
    },
    components: {
        AgreementPeriods,
        AgreementUserRoles
    },
    name: "AgreementsShow",
}
</script>
