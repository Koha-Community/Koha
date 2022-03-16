<template>
    <h2 v-if="agreement.agreement_id">Edit agreement</h2>
    <h2 v-else>New agreement</h2>
    <div>
        <b-form @submit="onSubmit">
            <b-form-group
                id="agreement_name"
                label="Agreement name:"
                label-for="agreement_name"
                label-cols="4"
                label-cols-lg="2"
            >
                <b-form-input
                    id="agreement_name"
                    v-model="agreement.name"
                    placeholder="Agreement name"
                    required
                ></b-form-input>
                <span class="required">Required</span>
            </b-form-group>
            <b-form-group
                id="agreement_vendor_id"
                label="Vendor:"
                label-for="agreement_vendor_id"
                label-cols="4"
                label-cols-lg="2"
            >
                <b-form-select v-model="agreement.vendor_id">
                    <b-form-select-option value=""></b-form-select-option>
                    <b-form-select-option
                        v-for="vendor in vendors"
                        :key="vendor.vendor_id"
                        :value="vendor.id"
                        :selected="
                            vendor.id == agreement.vendor_id ? true : false
                        "
                        >{{ vendor.name }}</b-form-select-option
                    >
                </b-form-select>
            </b-form-group>
            <b-form-group
                id="agreement_description"
                label="Description"
                label-for="agreement_description"
                label-cols="4"
                label-cols-lg="2"
            >
                <b-form-input
                    id="agreement_description"
                    v-model="agreement.description"
                    placeholder="Description"
                    required
                ></b-form-input>
                <span class="required">Required</span>
            </b-form-group>
            <b-form-group
                id="agreement_status"
                label="Status:"
                label-for="agreement_status"
                label-cols="4"
                label-cols-lg="2"
            >
                <b-form-select
                    id="agreement_status"
                    v-model="agreement.status"
                    @change="onStatusChange($event)"
                    required
                >
                    <b-form-select-option value=""></b-form-select-option>
                    <b-form-select-option
                        v-for="status in av_statuses"
                        :key="status.authorised_values"
                        :value="status.authorised_value"
                        :selected="
                            status.authorised_value == agreement.status
                                ? true
                                : false
                        "
                        >{{ status.lib }}</b-form-select-option
                    >
                </b-form-select>
                <span class="required">Required</span>
            </b-form-group>
            <b-form-group
                id="agreement_closure_reason"
                label="Closure reason:"
                label-for="agreement_closure_reason"
                label-cols="4"
                label-cols-lg="2"
            >
                <b-form-select
                    id="agreement_closure_reason"
                    v-model="agreement.closure_reason"
                    :disabled="agreement.status == 'closed' ? true : false"
                >
                    <b-form-select-option value=""></b-form-select-option>
                    <b-form-select-option
                        v-for="r in av_closure_reasons"
                        :key="r.authorised_values"
                        :value="r.authorised_value"
                        :selected="
                            r.authorised_value == agreement.closure_reason
                                ? true
                                : false
                        "
                        >{{ r.lib }}</b-form-select-option
                    >
                </b-form-select>
            </b-form-group>
            <b-form-group
                label="Is perpetual:"
                label-for="agreement_is_perpetual"
                label-cols="4"
                label-cols-lg="2"
            >
                <b-form-radio-group
                    id="agreement_is_perpetual"
                    label="Is perpetual:"
                    label-for="agreement_is_perpetual"
                    label-cols="4"
                    label-cols-lg="2"
                    v-model="agreement.is_perpetual"
                    :options="is_perpetual_options"
                >
                </b-form-radio-group>
            </b-form-group>
            <b-form-group
                id="agreement_renewal_priority"
                label="Renewal priority:"
                label-for="agreement_renewal_priority"
                label-cols="4"
                label-cols-lg="2"
            >
                <b-form-select v-model="agreement.renewal_priority">
                    <b-form-select-option value=""></b-form-select-option>
                    <b-form-select-option
                        v-for="p in av_renewal_priorities"
                        :key="p.authorised_values"
                        :value="p.authorised_value"
                        :selected="
                            p.authorised_value == agreement.renewal_priority
                                ? true
                                : false
                        "
                        >{{ p.lib }}</b-form-select-option
                    >
                </b-form-select>
            </b-form-group>
            <b-form-group
                id="agreement_license_info"
                label="License info:"
                label-for="agreement_license_info"
                label-cols="4"
                label-cols-lg="2"
            >
                <b-form-input
                    id="agreement_license_info"
                    v-model="agreement.license_info"
                    placeholder="License info"
                ></b-form-input>
            </b-form-group>

            <AgreementPeriods :periods="agreement.periods" />
            <AgreementUserRoles
                :user_roles="agreement.user_roles"
                :av_user_roles="av_user_roles"
            />

            <b-button type="submit" variant="primary">Submit</b-button>
            <a href="#" @click="$emit('switch-view', 'list')">Cancel</a>
        </b-form>
    </div>
</template>

<script>
import AgreementPeriods from './AgreementPeriods.vue'
import AgreementUserRoles from './AgreementUserRoles.vue'

export default {
    data() {
        return {
            is_perpetual_options: [{ text: "Yes", value: true }, { text: "No", value: false }],
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
        onSubmit() {

            //let agreement= Object.assign( {} ,this.agreement); // copy
            let agreement = JSON.parse(JSON.stringify(this.agreement)) // copy
            let apiUrl = '/api/v1/erm/agreements'

            const myHeaders = new Headers()
            myHeaders.append('Content-Type', 'application/json')

            let method = 'POST'
            if (agreement.agreement_id) {
                method = 'PUT'
                apiUrl += '/' + agreement.agreement_id
            }
            delete agreement.agreement_id

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
                myHeaders
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
        onStatusChange(status) {
            if (status == 'closed') {
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
