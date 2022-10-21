<template>
    <div class="page-section" id="agreement_user_roles">
        <legend>{{ $t("Users") }}</legend>
        <fieldset
            class="rows"
            v-for="(user_role, counter) in user_roles"
            v-bind:key="counter"
        >
            <legend>
                {{ $t("Agreement user .counter", { counter: counter + 1 }) }}
                <a href="#" @click.prevent="deleteUser(counter)"
                    ><i class="fa fa-trash"></i> {{ $t("Remove this user") }}</a
                >
            </legend>
            <ol>
                <li>
                    <label :for="`user_id_${counter}`">{{ $t("User") }}:</label>
                    <span class="user">
                        {{ user_role.patron_str }}
                    </span>
                    (<a
                        href="#"
                        @click="selectUser(counter)"
                        class="btn btn-default"
                        >{{ $t("Select user") }}</a
                    >)
                </li>
                <li>
                    <label :for="`user_role_${counter}`"
                        >{{ $t("Role") }}:</label
                    >
                    <v-select
                        :id="`user_role_${counter}`"
                        v-model="user_role.role"
                        label="lib"
                        :reduce="(av) => av.authorised_value"
                        :options="av_agreement_user_roles"
                    >
                        <template #search="{ attributes, events }">
                            <input
                                :required="!user_role.role"
                                class="vs__search"
                                v-bind="attributes"
                                v-on="events"
                            />
                        </template>
                    </v-select>
                    <span class="required">{{ $t("Required") }}</span>
                </li>
            </ol>
        </fieldset>
        <input
            type="hidden"
            name="selected_patron_id"
            id="selected_patron_id"
        />
        <a class="btn btn-default" @click="addUser"
            ><font-awesome-icon icon="plus" /> {{ $t("Add new user") }}</a
        >
    </div>
</template>

<script>
import { fetchPatron } from "../../fetch"

export default {
    name: 'AgreementUserRoles',
    props: {
        av_agreement_user_roles: Array,
        user_roles: Array,
    },
    beforeCreate() {
        this.user_roles.forEach(u => {
            u.patron_str = $patron_to_html(u.patron)
        })
    },
    methods: {
        addUser() {
            this.user_roles.push({
                user_id: null,
                role: null,
                patron_str: '',
            })
        },
        deleteUser(counter) {
            this.user_roles.splice(counter, 1)
        },
        selectUser(counter) {
            let select_user_window = window.open("/cgi-bin/koha/members/search.pl?columns=cardnumber,name,category,branch,action&selection_type=select&filter=erm_users",
                'PatronPopup',
                'width=740,height=450,location=yes,toolbar=no,'
                + 'scrollbars=yes,resize=yes'
            )
            // This is a bit dirty, the "select user" window should be rewritten and be a Vue component
            // but that's not for now...
            select_user_window.addEventListener('beforeunload', this.newUserSelected, false)
            select_user_window.counter = counter
        },
        newUserSelected(e) {
            let c = e.currentTarget.counter
            let selected_patron_id = document.getElementById("selected_patron_id").value
            let patron
            // FIXME We are missing a "loading..."
            fetchPatron(selected_patron_id).then((p) => {
                patron = p
                this.user_roles[c].patron = patron
                this.user_roles[c].patron_str = $patron_to_html(patron)
                this.user_roles[c].user_id = patron.patron_id
            })
        },
    },
}
</script>
