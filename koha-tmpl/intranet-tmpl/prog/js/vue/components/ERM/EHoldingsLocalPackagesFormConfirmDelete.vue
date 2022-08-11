<template>
    <div v-if="!initialized">{{ $t("Loading") }}</div>
    <div v-else id="packages_confirm_delete">
        <h2>{{ $t("Delete package") }}</h2>
        <div>
            <form @submit="onSubmit($event)">
                <fieldset class="rows">
                    <ol>
                        <li>
                            {{ $t("Package name") }}:
                            {{ erm_package.name }}
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
                        to="/cgi-bin/koha/erm/eholdings/local/packages"
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
import { fetchLocalPackage } from "../../fetch"
import { setMessage, setError } from "../../messages"

export default {
    data() {
        return {
            erm_package: {},
            initialized: false,
        }
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getPackage(to.params.package_id)
        })
    },
    methods: {
        async getPackage(package_id) {
            const erm_package = await fetchLocalPackage(package_id)
            this.erm_package = erm_package
            this.initialized = true
        },
        onSubmit(e) {
            e.preventDefault()

            let apiUrl = '/api/v1/erm/eholdings/local/packages/' + this.erm_package.package_id

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
                            setMessage(this.$t("Package deleted"))
                            this.$router.push("/cgi-bin/koha/erm/eholdings/local/packages")
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
    name: "EHoldingsLocalPackagesFormConfirmDelete",
}
</script>
