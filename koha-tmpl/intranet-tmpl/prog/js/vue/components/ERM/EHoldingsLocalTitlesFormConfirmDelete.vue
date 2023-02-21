<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="eholdings_confirm_delete">
        <h2>{{ $__("Delete title") }}</h2>
        <div>
            <form @submit="onSubmit($event)">
                <fieldset class="rows">
                    <ol>
                        <li>
                            {{ $__("Title") }}:
                            {{ title.publication_title }}
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
                        to="/cgi-bin/koha/erm/eholdings/local/titles"
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
            title: {},
            initialized: false,
        }
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getTitle(to.params.title_id)
        })
    },
    methods: {
        getTitle(title_id) {
            const client = APIClient.erm
            client.localTitles.get(title_id).then(
                title => {
                    this.title = title
                    this.initialized = true
                },
                error => {}
            )
        },
        onSubmit(e) {
            e.preventDefault()
            const client = APIClient.erm
            client.localTitles.delete(this.title.title_id).then(
                success => {
                    setMessage(this.$__("Title deleted"))
                    this.$router.push(
                        "/cgi-bin/koha/erm/eholdings/local/titles"
                    )
                },
                error => {}
            )
        },
    },
    name: "EHoldingsLocalTitlesFormConfirmDelete",
}
</script>
