<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else id="institutions_show">
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
            {{ $__("Institution #%s").format(institution.sip_institution_id) }}
        </h2>
        <div>
            <fieldset class="rows">
                <ol>
                    <li>
                        <label>{{ $__("Institution name") }}:</label>
                        <span>
                            {{ institution.name }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $__("Implementation") }}:</label>
                        <span>
                            {{ institution.implementation }}
                        </span>
                    </li>
                </ol>
            </fieldset>
            <h3>{{ $__("Policy") }}</h3>
            <fieldset class="rows">
                <ol>
                    <li>
                        <label>{{ $__("Checkin") }}:</label>
                        <span v-if="institution.checkin">{{ $__("Yes") }}</span>
                        <span v-else>{{ $__("No") }}</span>
                    </li>
                    <li>
                        <label>{{ $__("Checkout") }}:</label>
                        <span v-if="institution.checkout">{{
                            $__("Yes")
                        }}</span>
                        <span v-else>{{ $__("No") }}</span>
                    </li>
                    <li>
                        <label>{{ $__("Renewal") }}:</label>
                        <span v-if="institution.renewal">{{ $__("Yes") }}</span>
                        <span v-else>{{ $__("No") }}</span>
                    </li>
                    <li>
                        <label>{{ $__("Retries") }}:</label>
                        <span>
                            {{ institution.retries }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $__("Status update") }}:</label>
                        <span v-if="institution.status_update">{{
                            $__("Yes")
                        }}</span>
                        <span v-else>{{ $__("No") }}</span>
                    </li>
                    <li>
                        <label>{{ $__("Timeout") }}:</label>
                        <span>
                            {{ institution.timeout }}
                        </span>
                    </li>
                </ol>
            </fieldset>
            <fieldset class="action">
                <router-link
                    :to="{ name: 'SIP2InstitutionsList' }"
                    role="button"
                    class="cancel"
                    >{{ $__("Close") }}</router-link
                >
            </fieldset>
        </div>
    </div>
</template>

<script>
import { inject } from "vue";
import { APIClient } from "../../fetch/api-client.js";
import Toolbar from "../Toolbar.vue";
import ToolbarButton from "../ToolbarButton.vue";
import SIP2InstitutionResource from "./SIP2InstitutionResource.vue";

export default {
    extends: SIP2InstitutionResource,
    setup() {
        const { setConfirmationDialog, setMessage } = inject("mainStore");

        return {
            ...SIP2InstitutionResource.setup(),
            setConfirmationDialog,
            setMessage,
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
            vm.getInstitution(to.params.sip_institution_id);
        });
    },
    methods: {
        async getInstitution(sip_institution_id) {
            const client = APIClient.sip2;
            client.institutions.get(sip_institution_id).then(
                institution => {
                    this.institution = institution;
                    this.initialized = true;
                },
                error => {}
            );
        },
    },
    components: { Toolbar, ToolbarButton },
    name: "SIP2InstitutionsShow",
};
</script>
