<template>
    <div v-if="!initialized">{{ $t("Loading") }}</div>
    <div v-else id="eholdings_confirm_delete">
        <h2>{{ $t("Delete title") }}</h2>
        <div>
            <form @submit="onSubmit($event)">
                <fieldset class="rows">
                    <ol>
                        <li>
                            {{ $t("Title") }}:
                            {{ eholding.publication_title }}
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
                        to="/cgi-bin/koha/erm/eholdings/local/titles"
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
import { fetchLocalTitle } from "../../fetch"
import { setMessage, setError } from "../../messages"

export default {
    data() {
        return {
            eholding: {},
            initialized: false,
        }
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getEHolding(to.params.title_id)
        })
    },
    methods: {
        async getEHolding(title_id) {
            const eholding = await fetchLocalTitle(title_id)
            this.eholding = eholding
            this.initialized = true
        },
        onSubmit(e) {
            e.preventDefault()

            let apiUrl = '/api/v1/erm/eholdings/local/titles/' + this.eholding.title_id

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
                            setMessage(this.$t("Title deleted"))
                            this.$router.push("/cgi-bin/koha/erm/eholdings/local/titles")
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
    name: "EHoldingsLocalTitlesFormConfirmDelete",
}
</script>
