<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="licenses_confirm_delete">
        <h2>{{ $__("Delete license") }}</h2>
        <div>
            <form @submit="onSubmit($event)">
                <fieldset class="rows">
                    <ol>
                        <li>
                            {{ $__("License name") }}:
                            {{ license.name }}
                        </li>
                        <li>
                            {{ $__("Description") }}:
                            {{ license.description }}
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
                        to="/cgi-bin/koha/erm/licenses"
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
import { APIClient } from "../../fetch/api-client.js"
import { setMessage } from "../../messages"

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
            const client = APIClient.erm
            client.licenses.get(license_id).then(data => {
                this.license = data
                this.initialized = true
            })
        },
        onSubmit(e) {
            e.preventDefault()

            const client = APIClient.erm
            client.licenses.delete(this.license.license_id).then(
                success => {
                    setMessage(this.$__("License deleted"))
                    this.$router.push("/cgi-bin/koha/erm/licenses")
                },
                error => {}
            )
        },
    },
    name: "LicensesFormConfirmDelete",
}
</script>
