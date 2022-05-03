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
                                v-for="status in av_statuses"
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
                                v-for="r in av_closure_reasons"
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
                                v-for="p in av_renewal_priorities"
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
                        :av_user_roles="av_user_roles"
                    />
                </ol>
            </fieldset>
            <fieldset class="action">
                <input type="submit" value="Submit" />
                <a href="#" class="cancel" @click="$emit('switch-view', 'list')"
                    >Cancel</a
                >
            </fieldset>
        </form>
    </div>
</template>

<script>
import AgreementPeriods from './AgreementPeriods.vue'
import AgreementUserRoles from './AgreementUserRoles.vue'

export default {
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
                }
            )
    },
    methods: {
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
                        this.$emit('agreement-updated')
                    } else if (response.status == 201) {
                        this.$emit('agreement-created')
                    } else {
                        this.$emit('set-error', response.message || response.statusText)
                    }
                }).catch(
                    (error) => {
                        this.$emit('set-error', error)
                    }
                )
        },
        onStatusChange(event) {
            if (event.target.value != 'closed') {
                this.agreement.closure_reason = ''
            }
        }
    },
    emits: ['agreement-created', 'agreement-updated', 'set-error', 'switch-view'],
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
    name: "AgreementsFormAdd",
}
</script>
