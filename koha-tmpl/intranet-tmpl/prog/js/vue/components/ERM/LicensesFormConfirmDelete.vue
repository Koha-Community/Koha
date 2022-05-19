<template>
    <div v-if="!this.initialized">{{ $t("Loading") }}</div>
    <div v-else id="licenses_confirm_delete">
        <h2>{{ $t("Delete license") }}</h2>
        <div>
            <form @submit="onSubmit($event)">
                <fieldset class="rows">
                    <ol>
                        <li>
                            {{ $t("License name:") }}
                            {{ license.name }}
                        </li>
                        <li>
                            {{ $t("Description:") }}
                            {{ license.description }}
                        </li>
                    </ol>
                </fieldset>
                <fieldset class="action">
                    <input
                        type="submit"
                        variant="primary"
                        :value="$t('Yes, delete')"
                    />
                    <router-link
                        to="/cgi-bin/koha/erm/licenses"
                        role="button"
                        class="cancel"
                        >{{ $t("No, do not delete") }}</router-link
                    >
                </fieldset>
            </form>
        </div>
    </div>
</template>

<script>
import { fetchLicense } from "../../fetch"
import { setMessage, setError } from "../../messages"

export default {
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

            let apiUrl = '/api/v1/erm/licenses/' + this.license.license_id

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
                            this.$router.push("/cgi-bin/koha/erm/licenses")
                            setMessage("License deleted")
                        } else {
                            setError(response.message || response.statusText)
                        }
                    }
                ).catch(
                    (error) => {
                        setError(error)
                    }
                )
        }
    },
    name: "LicensesFormConfirmDelete",
}
</script>
