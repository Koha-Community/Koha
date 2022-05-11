<template>
    <div v-if="!this.initialized">Loading...</div>
    <div v-else>
        <h2 v-if="license.license_id">
            Edit license #{{ license.license_id }}
        </h2>
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
                            <label for="license_description"
                                >Description:
                            </label>
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
                                        status.authorised_value ==
                                        license.status
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
                    <router-link
                        to="/cgi-bin/koha/erm/licenses"
                        role="button"
                        class="cancel"
                        >Cancel</router-link
                    >
                </fieldset>
            </form>
        </div>
    </div>
</template>

<script>
import flatPickr from 'vue-flatpickr-component'
import { useAVStore } from "../../stores/authorised_values"
import { setMessage, setError } from "../../messages"
import { fetchLicense } from '../../fetch'
import { storeToRefs } from "pinia"

export default {

    setup() {
        const AVStore = useAVStore()
        const {
            av_license_types,
            av_license_statuses,
        } = storeToRefs(AVStore)

        return {
            av_license_types,
            av_license_statuses,
        }
    },
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
            },
            initialized: false,
        }
    },
    beforeUpdate() {
        if (!this.dates_fixed) {
            this.license.started_on = $date(this.license.started_on)
            this.license.ended_on = $date(this.license.ended_on)
            this.dates_fixed = 1
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
            const license = await fetchLicense(license_id)
            this.license = license
            this.initialized = true
        },
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
                        this.$router.push("/cgi-bin/koha/erm/licenses")
                        setMessage('License updated')
                    } else if (response.status == 201) {
                        this.$router.push("/cgi-bin/koha/erm/licenses")
                        setMessage('License created')
                    } else {
                        setError(response.message || response.statusText)
                    }
                }, (error) => {
                    setError(error)
                }).catch(e => { console.log(e) })
        },
    },
    props: {
        license_id: Number,
    },
    components: {
        flatPickr
    },
    name: "LicensesFormAdd",
}
</script>