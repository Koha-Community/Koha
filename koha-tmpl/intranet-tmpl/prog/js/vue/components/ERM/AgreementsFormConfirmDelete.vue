<template>
    <div v-if="!this.initialized">Loading...</div>
    <div v-else id="agreements_confirm_delete">
        <h2>Delete agreement</h2>
        <div>
            <form @submit="onSubmit($event)">
                <fieldset class="rows">
                    <ol>
                        <li>
                            Agreement name:
                            {{ agreement.name }}
                        </li>
                        <li>Vendor:{{ agreement.vendor_id }}</li>
                        <li>
                            Description:
                            {{ agreement.description }}
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
                        to="/cgi-bin/koha/erm/agreements"
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
import { fetchAgreement } from "../../fetch"
import { setMessage, setError } from "../../messages"

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
            const agreement = await fetchAgreement(agreement_id)
            this.agreement = agreement
            this.initialized = true
        },
        onSubmit(e) {
            e.preventDefault()

            let apiUrl = '/api/v1/erm/agreements/' + this.agreement.agreement_id

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
                            setMessage("Agreement deleted")
                            this.$router.push("/cgi-bin/koha/erm/agreements")
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
    name: "AgreementsFormConfirmDelete",
}
</script>
