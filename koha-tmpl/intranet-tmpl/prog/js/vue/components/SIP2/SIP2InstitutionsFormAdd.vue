<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="sip2_institutions_add">
        <h2 v-if="institution.sip_institution_id">
            {{
                $__("Edit institution #%s").format(
                    institution.sip_institution_id
                )
            }}
        </h2>
        <h2 v-else>{{ $__("New institution") }}</h2>
        <div>
            <form @submit="onSubmit($event)">
                <fieldset class="rows">
                    <ol>
                        <li
                            v-for="(attr, index) in resourceAttrs.filter(
                                attr => attr.type !== 'relationship'
                            )"
                            v-bind:key="index"
                        >
                            <FormElement
                                :resource="institution"
                                :attr="attr"
                                :index="index"
                            />
                        </li>
                    </ol>
                </fieldset>
                <fieldset class="action">
                    <ButtonSubmit />
                    <router-link
                        :to="{ name: 'SIP2InstitutionsList' }"
                        role="button"
                        class="cancel"
                        >{{ $__("Cancel") }}</router-link
                    >
                </fieldset>
            </form>
        </div>
    </div>
</template>

<script>
import FormElement from "../FormElement.vue";
import ButtonSubmit from "../ButtonSubmit.vue";
import { setMessage, setError, setWarning } from "../../messages";
import { APIClient } from "../../fetch/api-client.js";
import SIP2InstitutionResource from "./SIP2InstitutionResource.vue";

export default {
    extends: SIP2InstitutionResource,
    setup() {
        return {
            ...SIP2InstitutionResource.setup(),
        };
    },
    data() {
        return {
            institution: {
                sip_institution_id: null,
                name: "",
                implementation: "",
                checkin: false,
                checkout: false,
                renewal: false,
                retries: 5,
                status_update: false,
                timeout: 100,
            },
            initialized: false,
        };
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            if (to.params.sip_institution_id) {
                vm.getSIP2Institution(to.params.sip_institution_id);
            } else {
                vm.initialized = true;
            }
        });
    },
    methods: {
        async getSIP2Institution(sip_institution_id) {
            const client = APIClient.sip2;
            client.institutions.get(sip_institution_id).then(
                data => {
                    this.institution = data;
                    this.initialized = true;
                },
                error => {}
            );
        },
        onSubmit(e) {
            e.preventDefault();

            let institution = JSON.parse(JSON.stringify(this.institution)); // copy
            let sip_institution_id = institution.sip_institution_id;

            delete institution.sip_institution_id;

            const client = APIClient.sip2;
            if (sip_institution_id) {
                client.institutions
                    .update(institution, sip_institution_id)
                    .then(
                        success => {
                            setMessage(this.$__("Institution updated"));
                            this.$router.push({ name: "SIP2InstitutionsList" });
                        },
                        error => {}
                    );
            } else {
                client.institutions.create(institution).then(
                    success => {
                        setMessage(this.$__("Institution created"));
                        this.$router.push({ name: "SIP2InstitutionsList" });
                    },
                    error => {}
                );
            }
        },
    },
    components: {
        ButtonSubmit,
        FormElement,
    },
    name: "SIP2InstitutionsFormAdd",
};
</script>
