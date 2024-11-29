<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="agreements_show">
        <Toolbar>
            <ToolbarButton
                action="edit"
                @go-to-edit-resource="goToResourceEdit"
            />
            <ToolbarButton
                action="delete"
                @delete-resource="doResourceDelete"
            />
        </Toolbar>

        <h2>
            {{ $__("Agreement #%s").format(agreement.agreement_id) }}
        </h2>
        <div>
            <fieldset class="rows">
                <ol>
                    <li
                        v-for="(attr, index) in resource_attrs.filter(
                            attr => attr.showElement?.type !== 'relationship'
                        )"
                        v-bind:key="index"
                    >
                        <ShowElement
                            :resource="agreement"
                            :attr="attr"
                            :index="index"
                        />
                    </li>
                </ol>
            </fieldset>
            <template
                v-for="(attr, index) in resource_attrs.filter(
                    attr => attr.showElement?.type === 'relationship'
                )"
                v-bind:key="'rel-' + index"
            >
                <ShowElement :resource="agreement" :attr="attr" />
            </template>
            <fieldset class="action">
                <router-link
                    :to="{ name: 'AgreementsList' }"
                    role="button"
                    class="cancel"
                    >{{ $__("Close") }}</router-link
                >
            </fieldset>
        </div>
    </div>
</template>

<script>
import { APIClient } from "../../fetch/api-client.js";
import Toolbar from "../Toolbar.vue";
import ToolbarButton from "../ToolbarButton.vue";
import AgreementResource from "./AgreementResource.vue";
import ShowElement from "../ShowElement.vue";

export default {
    extends: AgreementResource,
    setup() {
        return {
            ...AgreementResource.setup(),
        };
    },
    data() {
        return {
            agreement: {
                agreement_id: null,
                name: "",
                vendor_id: null,
                vendor: null,
                description: "",
                status: "",
                closure_reason: "",
                is_perpetual: false,
                renewal_priority: "",
                license_info: "",
                periods: [],
                user_roles: [],
                extended_attributes: [],
                _strings: [],
                agreement_packages: [],
            },
            initialized: false,
        };
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getAgreement(to.params.agreement_id);
        });
    },
    beforeRouteUpdate(to, from) {
        this.agreement = this.getAgreement(to.params.agreement_id);
    },
    methods: {
        async getAgreement(agreement_id) {
            const client = APIClient.erm;
            client.agreements.get(agreement_id).then(
                agreement => {
                    this.agreement = agreement;
                    this.initialized = true;
                },
                error => {}
            );
        },
    },
    components: { Toolbar, ToolbarButton, ShowElement },
    name: "AgreementsShow",
};
</script>
<style scoped>
#agreement_documents ul {
    padding-left: 0px;
}
</style>
