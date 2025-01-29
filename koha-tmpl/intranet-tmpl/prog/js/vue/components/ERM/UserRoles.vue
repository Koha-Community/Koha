<template>
    <fieldset class="rows" id="user_roles">
        <fieldset
            class="rows"
            v-for="(user_role, counter) in user_roles"
            v-bind:key="counter"
        >
            <legend>
                {{ user_type.format(counter + 1) }}
                <a href="#" @click.prevent="deleteUser(counter)"
                    ><i class="fa fa-trash"></i>
                    {{ $__("Remove this user") }}</a
                >
            </legend>
            <ol>
                <li v-for="(attr, index) in subFields" v-bind:key="index">
                    <FormElement
                        :resource="user_role"
                        :attr="attr"
                        :index="counter"
                    />
                </li>
            </ol>
        </fieldset>
        <input
            type="hidden"
            name="selected_patron_id"
            id="selected_patron_id"
        />
        <a class="btn btn-default" @click="addUser"
            ><font-awesome-icon icon="plus" /> {{ $__("Add new user") }}</a
        >
    </fieldset>
</template>

<script>
import { APIClient } from "../../fetch/api-client.js";
import FormElement from "../FormElement.vue";

export default {
    components: { FormElement },
    name: "UserRoles",
    props: {
        user_type: String,
        av_user_roles: Array,
        user_roles: Array,
        subFields: Array,
    },
    beforeCreate() {
        this.user_roles.forEach(u => {
            u.patron_str = $patron_to_html(u.patron);
        });
    },
    methods: {
        addUser() {
            this.user_roles.push({
                user_id: null,
                role: null,
                patron_str: "",
            });
        },
        deleteUser(counter) {
            this.user_roles.splice(counter, 1);
        },
        selectUser(counter) {
            // This is a bit dirty, the "select user" window should be rewritten and be a Vue component
            // but that's not for now...
            $(document).on(
                "hidden.bs.modal",
                "#patron_search_modal",
                this.newUserSelected
            );
            this.selected_user_counter = counter;
        },
        newUserSelected(e) {
            let c = this.selected_user_counter;
            let selected_patron_id =
                document.getElementById("selected_patron_id").value;
            let patron;
            const client = APIClient.patron;
            // FIXME We are missing a "loading..."
            client.patrons.get(selected_patron_id).then(p => {
                patron = p;
                this.user_roles[c].patron = patron;
                this.user_roles[c].patron_str = $patron_to_html(patron);
                this.user_roles[c].user_id = patron.patron_id;
            });
        },
    },
};
</script>
