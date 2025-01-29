<template>
    <span class="user">
        {{ resource.patron_str }}
    </span>
    &nbsp;
    <a
        href="#patron_search_modal"
        @click="selectUser(counter)"
        class="btn btn-default"
        data-bs-toggle="modal"
        ><i class="fa fa-plus"></i> {{ $__("Select user") }}</a
    >
    <input type="hidden" name="selected_patron_id" id="selected_patron_id" />
</template>

<script>
import { APIClient } from "../fetch/api-client.js";

export default {
    props: {
        name: String,
        resource: Object,
        counter: String,
        label: String,
        required: Boolean,
    },
    beforeCreate() {
        this.resource.patron_str = $patron_to_html(this.resource.patron);
    },
    methods: {
        selectUser(counter) {
            // This is a bit dirty, the "select user" window should be rewritten and be a Vue component
            // but that's not for now...
            $(document).on(
                "hidden.bs.modal",
                "#patron_search_modal",
                this.newUserSelected
            );
        },
        newUserSelected(e) {
            let selected_patron_id =
                document.getElementById("selected_patron_id").value;
            let patron;
            const client = APIClient.patron;
            // FIXME We are missing a "loading..."
            client.patrons.get(selected_patron_id).then(p => {
                patron = p;
                this.resource.patron = patron;
                this.resource.patron_str = $patron_to_html(patron);
                this.resource.user_id = patron.patron_id;
            });
        },
    },
};
</script>

<style></style>
