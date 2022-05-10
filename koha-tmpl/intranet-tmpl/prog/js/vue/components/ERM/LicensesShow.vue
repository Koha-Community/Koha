<template>
    <h2>License #{{ license.license_id }}</h2>
    <div>
        <fieldset class="rows">
            <ol>
                <li>
                    <label>License name:</label>
                    <span>
                        {{ license.name }}
                    </span>
                </li>
                <li>
                    <label>Description: </label>
                    <span>
                        {{ license.description }}
                    </span>
                </li>
                <li>
                    <label>Type: </label>
                    <span>{{
                        get_lib_from_av(av_license_types, license.type)
                    }}</span>
                </li>
                <li>
                    <label>Status: </label>
                    <span>{{
                        get_lib_from_av(av_license_statuses, license.status)
                    }}</span>
                </li>

                <li>
                    <label>Started on:</label>
                    <span>{{ format_date(license.started_on) }}</span>
                </li>

                <li>
                    <label>Ended on:</label>
                    <span>{{ format_date(license.ended_on) }}</span>
                </li>
            </ol>
        </fieldset>
        <fieldset class="action">
            <router-link
                to="/cgi-bin/koha/erm/licenses"
                role="button"
                class="cancel"
                >Close</router-link
            >
        </fieldset>
    </div>
</template>

<script>
import { useAVStore } from "../../stores/authorised_values"
import { useMainStore } from "../../stores/main"
import { storeToRefs } from "pinia"
import { fetchLicense } from "../../fetch"

export default {
    setup() {
        const format_date = $date
        const get_lib_from_av = function (arr, av) {
            let o = arr.find(
                (e) => e.authorised_value == av
            )
            return o ? o.lib : ""
        }

        const AVStore = useAVStore()
        const {
            av_license_types,
            av_license_statuses,
        } = storeToRefs(AVStore)

        const mainStore = useMainStore()
        const { setError } = mainStore

        return {
            format_date,
            get_lib_from_av,
            av_license_types,
            av_license_statuses,
            setError,
        }
    },
    data() {
        return {
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
    beforeRouteEnter(to, from, next) {
        if (to.params.license_id) {
            next(vm => {
                vm.license = vm.getLicense(to.params.license_id)
            })
        } else {
            next()
        }
    },
    methods: {
        async getLicense(license_id) {
            const license = await fetchLicense(license_id)
            this.license = license
        },
    },
    components: {
    },
    name: "LicensesShow",
}
</script>
