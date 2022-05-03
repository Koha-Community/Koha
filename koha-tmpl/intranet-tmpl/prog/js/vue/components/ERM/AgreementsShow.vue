<template>
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
                        get_lib_from_av(av_statuses, agreement.status)
                    }}</span>
                </li>
                <li>
                    <label>Closure reason:</label>
                    <span>{{
                        get_lib_from_av(
                            av_closure_reasons,
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
                            av_renewal_priorities,
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
                                v-for="(period, counter) in agreement.periods"
                                v-bind:key="counter"
                            >
                                <td>{{ format_date(period.started_on) }}</td>
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
                                v-for="(role, counter) in agreement.user_roles"
                                v-bind:key="counter"
                            >
                                <td>{{ patron_to_html(role.patron) }}</td>
                                <td>
                                    {{
                                        av_user_roles.find(
                                            (r) =>
                                                r.authorised_value == role.role
                                        ).lib
                                    }}
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </li>
            </ol>
        </fieldset>
        <fieldset class="action">
            <a
                role="button"
                class="cancel"
                @click="$emit('switch-view', 'list')"
                >Close</a
            >
        </fieldset>
    </div>
</template>

<script>
import AgreementPeriods from './AgreementPeriods.vue'
import AgreementUserRoles from './AgreementUserRoles.vue'

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
        return {
            format_date,
            patron_to_html,
            get_lib_from_av
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
            }
        }
    },
    created() {
        if (!this.agreement_id) return
        const apiUrl = '/api/v1/erm/agreements/' + this.agreement_id

        fetch(apiUrl, {
            headers: {
                'x-koha-embed': 'periods,user_roles,user_roles.patron'
            }
        })
            .then(res => res.json())
            .then(
                (result) => {
                    this.agreement = result
                },
                (error) => {
                    this.$emit('set-error', error)
                }
            )
    },
    methods: {
    },
    emits: ['set-error', 'switch-view'],
    props: {
        agreement_id: Number,
        vendors: Array,
        av_statuses: Array,
        av_closure_reasons: Array,
        av_renewal_priorities: Array,
        av_user_roles: Array,
    },
    components: {
        AgreementPeriods,
        AgreementUserRoles
    },
    name: "AgreementsShow",
}
</script>
