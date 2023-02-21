<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="packages_confirm_delete">
        <h2>{{ $__("Delete package") }}</h2>
        <div>
            <form @submit="onSubmit($event)">
                <fieldset class="rows">
                    <ol>
                        <li>
                            {{ $__("Package name") }}:
                            {{ erm_package.name }}
                        </li>
                    </ol>
                </fieldset>
                <fieldset class="action">
                    <input
                        type="submit"
                        variant="primary"
                        :value="$__('Yes, delete')"
                    />
                    <router-link
                        to="/cgi-bin/koha/erm/eholdings/local/packages"
                        role="button"
                        class="cancel"
                        >{{ $__("No, do not delete") }}</router-link
                    >
                </fieldset>
            </form>
        </div>
    </div>
</template>

<script>
import { setMessage, setError } from "../../messages"
import { APIClient } from "../../fetch/api-client.js"

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
        getPackage(package_id) {
            const client = APIClient.erm
            client.localPackages.get(package_id).then(
                erm_package => {
                    this.erm_package = erm_package
                    this.initialized = true
                },
                error => {}
            )
        },
        onSubmit(e) {
            e.preventDefault()
            const client = APIClient.erm
            client.localPackages.delete(this.erm_package.package_id).then(
                success => {
                    setMessage(this.$__("Package deleted"))
                    this.$router.push(
                        "/cgi-bin/koha/erm/eholdings/local/packages"
                    )
                },
                error => {}
            )
        },
    },
    name: "EHoldingsLocalPackagesFormConfirmDelete",
}
</script>
