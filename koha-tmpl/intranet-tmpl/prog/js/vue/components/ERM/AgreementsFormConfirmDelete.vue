<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="agreements_confirm_delete">
        <h2>{{ $__("Delete agreement") }}</h2>
        <div>
            <form @submit="onSubmit($event)">
                <fieldset class="rows">
                    <ol>
                        <li>
                            {{ $__("Agreement name") }}:
                            {{ agreement.name }}
                        </li>
                        <li>{{ $__("Vendor") }}: {{ agreement.vendor_id }}</li>
                        <li>
                            {{ $__("Description") }}:
                            {{ agreement.description }}
                        </li>
                    </ol>
                </fieldset>
                <fieldset class="action">
                    <ButtonSubmit :text="$__('Yes, delete')"/>
                    <router-link
                        to="/cgi-bin/koha/erm/agreements"
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
import ButtonSubmit from "../ButtonSubmit.vue"

export default {
    data() {
        return {
            agreement: {},
            initialized: false,
        }
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getAgreement(to.params.agreement_id)
        })
    },
    methods: {
        async getAgreement(agreement_id) {
            const client = APIClient.erm
            client.agreements.get(agreement_id).then(data => {
                this.agreement = data
                this.initialized = true
            })
        },
        onSubmit(e) {
            e.preventDefault()

            const client = APIClient.erm
            client.agreements.delete(this.agreement.agreement_id).then(
                success => {
                    setMessage(this.$__("Agreement deleted"))
                    this.$router.push("/cgi-bin/koha/erm/agreements")
                },
                error => {}
            )
        },
    },
    components: {
        ButtonSubmit,
    },
    name: "AgreementsFormConfirmDelete",
}
</script>
