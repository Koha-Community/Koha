<template>
    <div v-if="!this.initialized">Loading...</div>
    <div v-else>
        <h2>Delete license</h2>
        <div>
            <form @submit="onSubmit($event)">
                <fieldset class="rows">
                    <ol>
                        <li>
                            License name:
                            {{ license.name }}
                        </li>
                        <li>
                            Description:
                            {{ license.description }}
                        </li>
                    </ol>
                </fieldset>
                <fieldset class="action">
                    <input
                        type="submit"
                        variant="primary"
                        value="Yes, delete"
                    />
                    <router-link
                        to="/cgi-bin/koha/erm/licenses"
                        role="button"
                        class="cancel"
                        >No, do not delete</router-link
                    >
                </fieldset>
            </form>
        </div>
    </div>
</template>

<script>
import { useMainStore } from "../../stores/main"
import { fetchLicense } from "../../fetch"

export default {
    setup() {
        const mainStore = useMainStore()
        const { setMessage, setError } = mainStore
        return {
            setMessage, setError,
        }
    },
    data() {
        return {
            license: {},
            initialized: false,
        }
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.license = vm.getLicense(to.params.license_id)
            vm.initialized = true
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

            let apiUrl = '/api/v1/erm/licenses/' + this.license_id

            const options = {
                method: 'DELETE',
                headers: {
                    'Content-Type': 'application/json;charset=utf-8'
                },
            }

            fetch(apiUrl, options)
                .then(
                    (response) => {
                        if (response.status == 204) {
                            this.$router.push("/cgi-bin/koha/erm/agreements")
                            this.setMessage("License deleted")
                        } else {
                            this.setError(response.message || response.statusText)
                        }
                    }
                ).catch(
                    (error) => {
                        this.setError(error)
                    }
                )
        }
    },
    name: "LicensesFormConfirmDelete",
}
</script>
