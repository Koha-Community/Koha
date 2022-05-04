<template>
    <h2 v-if="license.license_id">Edit license</h2>
    <h2 v-else>New license</h2>
    <div>
        <form @submit="onSubmit($event)">
            <fieldset class="rows">
                <ol>
                    <li>
                        <label class="required" for="license_name"
                            >License name:</label
                        >
                        <input
                            id="license_name"
                            v-model="license.name"
                            placeholder="License name"
                            required
                        />
                        <span class="required">Required</span>
                    </li>
                    <li>
                        <label for="license_description">Description: </label>
                        <textarea
                            id="license_description"
                            v-model="license.description"
                            placeholder="Description"
                            rows="10"
                            cols="50"
                            required
                        />
                        <span class="required">Required</span>
                    </li>
                    <li>
                        <label for="license_type">Type: </label>
                        <select
                            id="license_type"
                            v-model="license.type"
                            required
                        >
                            <option value=""></option>
                            <option
                                v-for="type in av_license_types"
                                :key="type.authorised_values"
                                :value="type.authorised_value"
                                :selected="
                                    type.authorised_value == license.type
                                        ? true
                                        : false
                                "
                            >
                                {{ type.lib }}
                            </option>
                        </select>
                        <span class="required">Required</span>
                    </li>
                    <li>
                        <label for="license_status">Status: </label>
                        <select
                            id="license_status"
                            v-model="license.status"
                            required
                        >
                            <option value=""></option>
                            <option
                                v-for="status in av_license_statuses"
                                :key="status.authorised_values"
                                :value="status.authorised_value"
                                :selected="
                                    status.authorised_value == license.status
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
                        <label for="started_on">Start date: </label>
                        <flat-pickr
                            id="started_on"
                            v-model="license.started_on"
                            :config="fp_config"
                            data-date_to="ended_on"
                        />
                    </li>
                    <li>
                        <label for="ended_on">End date: </label>
                        <flat-pickr
                            id="ended_on"
                            v-model="license.ended_on"
                            :config="fp_config"
                        />
                    </li>
                </ol>
            </fieldset>
            <fieldset class="action">
                <input type="submit" value="Submit" />
                <a
                    role="button"
                    class="cancel"
                    @click="$emit('switch-view', 'list')"
                    >Cancel</a
                >
            </fieldset>
        </form>
    </div>
</template>

<script>
import flatPickr from 'vue-flatpickr-component'

export default {
    data() {
        return {
            fp_config: flatpickr_defaults, dates_fixed: 0,

            license: {
                license_id: null,
                name: '',
                description: '',
                type: '',
                status: '',
                started_on: undefined,
                ended_on: undefined,
            }
        }
    },
    beforeUpdate() {
        if (!this.dates_fixed) {
            this.license.started_on = $date(this.license.started_on)
            this.license.ended_on = $date(this.license.ended_on)
            this.dates_fixed = 1
        }
    },
    created() {
        if (!this.license_id) return
        const apiUrl = '/api/v1/erm/licenses/' + this.license_id

        fetch(apiUrl, {
            //headers: {
            //    'x-koha-embed': 'periods,user_roles,user_roles.patron'
            //}
        })
            .then(res => res.json())
            .then(
                (result) => {
                    this.license = result
                },
                (error) => {
                    this.$emit('set-error', error)
                }
            )
    },
    methods: {
        onSubmit(e) {
            e.preventDefault()

            let license = JSON.parse(JSON.stringify(this.license)) // copy
            let apiUrl = '/api/v1/erm/licenses'

            let method = 'POST'
            if (license.license_id) {
                method = 'PUT'
                apiUrl += '/' + license.license_id
            }
            delete license.license_id

            license.started_on = license.started_on ? $date_to_rfc3339(license.started_on) : null
            license.ended_on = license.ended_on ? $date_to_rfc3339(license.ended_on) : null

            const options = {
                method: method,
                body: JSON.stringify(license),
                headers: {
                    'Content-Type': 'application/json;charset=utf-8'
                },
            }

            fetch(apiUrl, options)
                .then(response => {
                    if (response.status == 200) {
                        this.$emit('license-updated')
                    } else if (response.status == 201) {
                        this.$emit('license-created')
                    } else {
                        this.$emit('set-error', response.message || response.statusText)
                    }
                }, (error) => {
                    this.$emit('set-error', error)
                }).catch(e => { console.log(e) })
        },
    },
    emits: ['license-created', 'license-updated', 'set-error', 'switch-view'],
    props: {
        license_id: Number,
        av_license_types: Array,
        av_license_statuses: Array,
    },
    components: {
        flatPickr
    },
    name: "LicensesFormAdd",
}
</script>
