<template>
    <div v-if="!this.initialized">{{ $t("Loading") }}</div>
    <div v-else id="agreements_show">
        <h2>
            {{ $t("Agreement .id", { id: agreement.agreement_id }) }}
            <span class="action_links">
                <router-link
                    :to="`/cgi-bin/koha/erm/agreements/edit/${agreement.agreement_id}`"
                    :title="$t('Edit')"
                    ><i class="fa fa-pencil"></i
                ></router-link>

                <router-link
                    :to="`/cgi-bin/koha/erm/agreements/delete/${agreement.agreement_id}`"
                    :title="$t('Delete')"
                    ><i class="fa fa-trash"></i
                ></router-link>
            </span>
        </h2>
        <div>
            <fieldset class="rows">
                <ol>
                    <li>
                        <label>{{ $t("Agreement name") }}:</label>
                        <span>
                            {{ agreement.name }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Vendor") }}:</label>
                        <span v-if="agreement.vendor_id">
                            {{
                                vendors.find((e) => e.id == agreement.vendor_id)
                                    .name
                            }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Description") }}:</label>
                        <span>
                            {{ agreement.description }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Status") }}:</label>
                        <span>{{
                            get_lib_from_av(
                                "av_agreement_statuses",
                                agreement.status
                            )
                        }}</span>
                    </li>
                    <li>
                        <label>{{ $t("Closure reason") }}:</label>
                        <span>{{
                            get_lib_from_av(
                                "av_agreement_closure_reasons",
                                agreement.closure_reason
                            )
                        }}</span>
                    </li>
                    <li>
                        <label>{{ $t("Is perpetual") }}:</label>
                        <span v-if="agreement.is_perpetual">Yes</span>
                        <span v-else>No</span>
                    </li>
                    <li>
                        <label>{{ $t("Renewal priority") }}:</label>
                        <span>{{
                            get_lib_from_av(
                                "av_agreement_renewal_priorities",
                                agreement.renewal_priority
                            )
                        }}</span>
                    </li>
                    <li>
                        <label>{{ $t("License info") }}:</label>
                        <span>{{ agreement.license_info }}</span>
                    </li>

                    <li>
                        <label>{{ $t("Periods") }}</label>
                        <table>
                            <thead>
                                <th>{{ $t("Period start") }}</th>
                                <th>{{ $t("Period end") }}</th>
                                <th>{{ $t("Cancellation deadline") }}</th>
                                <th>{{ $t("Period note") }}</th>
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
                        <label>{{ $t("Users") }}</label>
                        <table>
                            <thead>
                                <th>{{ $t("Name") }}</th>
                                <th>{{ $t("Role") }}</th>
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
                                                "av_agreement_user_roles",
                                                role.role
                                            )
                                        }}
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </li>

                    <li>
                        <label>{{ $t("Licenses") }}</label>
                        <table>
                            <thead>
                                <th>{{ $t("Name") }}</th>
                                <th>{{ $t("Status") }}</th>
                                <th>{{ $t("Physical location") }}</th>
                                <th>{{ $t("Notes") }}</th>
                                <th>{{ $t("URI") }}</th>
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
                                                "av_agreement_license_statuses",
                                                agreement_license.status
                                            )
                                        }}
                                    </td>
                                    <td>
                                        {{
                                            get_lib_from_av(
                                                "av_agreement_license_location",
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
                        <label>{{ $t("Related agreements") }}</label>
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
                                    "av_agreement_relationships",
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
                    >{{ $t("Close") }}</router-link
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

        const vendorStore = useVendorStore()
        const { vendors } = storeToRefs(vendorStore)

        const AVStore = useAVStore()
        const { get_lib_from_av } = AVStore

        return {
            format_date,
            patron_to_html,
            get_lib_from_av,
            vendors,
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
<style scoped>
.action_links a {
    padding-left: 0.2em;
    font-size: 11px;
}
</style>