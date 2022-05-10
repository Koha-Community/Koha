<template>
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
                <input type="submit" variant="primary" value="Yes, delete" />
                <router-link
                    to="/cgi-bin/koha/erm/agreements"
                    role="button"
                    class="cancel"
                    >No, do not delete</router-link
                >
            </fieldset>
        </form>
    </div>
</template>

<script>
import { useMainStore } from "../../stores/main"
import { fetchAgreement } from "../../fetch"

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
            agreement: {},
        }
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.agreement = vm.getAgreement(to.params.agreement_id)
        })
    },
    methods: {
        async getAgreement(agreement_id) {
            const agreement = await fetchAgreement(agreement_id)
            this.agreement = agreement
        },
        onSubmit(e) {
            e.preventDefault()

            let apiUrl = '/api/v1/erm/agreements/' + this.agreement_id

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
                            this.setMessage("Agreement deleted")
                            this.$router.push("/cgi-bin/koha/erm/agreements")
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
    props: {
        agreement_id: Number
    },
    name: "AgreementsFormConfirmDelete",
}
</script>
