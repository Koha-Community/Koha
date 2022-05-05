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
            <a role="button" class="cancel" @click="this.setCurrentView('list')"
                >Close</a
            >
        </fieldset>
    </div>
</template>

<script>
import { useAVStore } from "../../stores/authorised_values"
import { useMainStore } from "../../stores/main"
import { storeToRefs } from "pinia"

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
        const { setError, setCurrentView } = mainStore

        return {
            format_date,
            get_lib_from_av,
            av_license_types,
            av_license_statuses,
            setError, setCurrentView,
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
    created() {
        if (!this.license_id) return
        const apiUrl = '/api/v1/erm/licenses/' + this.license_id

        fetch(apiUrl)
            .then(res => res.json())
            .then(
                (result) => {
                    this.license = result
                },
                (error) => {
                    this.setError(error)
                }
            )
    },
    methods: {
    },
    props: {
        license_id: Number,
    },
    components: {
    },
    name: "LicensesShow",
}
</script>
