<template>
    <span v-if="loading" class="user">
        {{ $__("Loading...") }}
    </span>
    <span v-else class="user">
        {{ resource.patron_str }}
    </span>
    &nbsp;
    <a
        href="#patron_search_modal"
        @click="selectUser()"
        class="btn btn-default"
        data-bs-toggle="modal"
        ><i class="fa fa-plus"></i> {{ $__("Select user") }}</a
    >
    <input
        v-if="shouldRenderInput"
        type="hidden"
        name="selected_patron_id"
        id="selected_patron_id"
    />
</template>

<script>
import { APIClient } from "../fetch/api-client.js";

export default {
    props: {
        name: String,
        resource: Object,
        label: String,
        required: Boolean,
    },
    data() {
        return {
            loading: false,
        };
    },
    beforeCreate() {
        this.resource.patron_str = $patron_to_html(this.resource.patron);
    },
    computed: {
        shouldRenderInput() {
            return !document.getElementById("selected_patron_id");
        },
    },
    methods: {
        selectUser() {
            this.modalEventListener = () => {
                this.newUserSelected();
                $(document).off(
                    "hidden.bs.modal",
                    "#patron_search_modal",
                    this.modalEventListener
                );
            };
            $(document).on(
                "hidden.bs.modal",
                "#patron_search_modal",
                this.modalEventListener
            );
        },
        newUserSelected(e) {
            this.loading = true;
            let selected_patron_id =
                document.getElementById("selected_patron_id").value;
            let patron;
            const client = APIClient.patron;
            client.patrons.get(selected_patron_id).then(p => {
                patron = p;
                this.resource.patron = patron;
                this.resource.patron_str = $patron_to_html(patron);
                this.resource.user_id = patron.patron_id;
                this.loading = false;
            });
        },
    },
};
</script>

<style></style>
