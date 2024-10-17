<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else-if="erm_package" id="packages_show">
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
            {{ $__("Package #%s").format(erm_package.package_id) }}
        </h2>
        <div>
            <fieldset class="rows">
                <ol>
                    <li>
                        <label>{{ $__("Package name") }}:</label>
                        <span>
                            {{ erm_package.name }}
                        </span>
                    </li>
                    <li v-if="erm_package.vendor">
                        <label>{{ $__("Vendor") }}:</label>
                        <span>
                            <a
                                :href="`/cgi-bin/koha/acqui/booksellers.pl?booksellerid=${erm_package.vendor_id}`"
                                >{{ erm_package.vendor.name }}</a
                            >
                        </span>
                    </li>
                    <li>
                        <label>{{ $__("Package type") }}:</label>
                        <span>{{
                            get_lib_from_av(
                                "av_package_types",
                                erm_package.package_type
                            )
                        }}</span>
                    </li>
                    <li>
                        <label>{{ $__("Content type") }}:</label>
                        <span>{{
                            get_lib_from_av(
                                "av_package_content_types",
                                erm_package.content_type
                            )
                        }}</span>
                    </li>
                    <li>
                        <label>{{ $__("Notes") }}:</label>
                        <span>{{ erm_package.notes }}</span>
                    </li>
                    <li v-if="erm_package.created_on">
                        <label>{{ $__("Created on") }}:</label>
                        <span>{{ format_date(erm_package.created_on) }}</span>
                    </li>
                    <li v-if="erm_package.package_agreements.length">
                        <label>{{ $__("Agreements") }}</label>
                        <div
                            v-for="package_agreement in erm_package.package_agreements"
                            :key="package_agreement.agreement_id"
                        >
                            <router-link
                                :to="{
                                    name: 'AgreementsShow',
                                    params: {
                                        agreement_id:
                                            package_agreement.agreement
                                                .agreement_id,
                                    },
                                }"
                                >{{
                                    package_agreement.agreement.name
                                }}</router-link
                            >
                        </div>
                    </li>
                    <li>
                        <label>{{
                            $__("Titles (%s)").format(
                                erm_package.resources_count
                            )
                        }}</label>
                    </li>
                </ol>
                <div v-if="erm_package.resources_count">
                    <EHoldingsPackageTitlesList
                        :package_id="erm_package.package_id.toString()"
                    />
                </div>
            </fieldset>
            <AdditionalFieldsDisplay
                resource_type="package"
                :additional_field_values="
                    erm_package._strings.additional_field_values
                "
            />
            <fieldset class="action">
                <router-link
                    :to="{ name: 'EHoldingsLocalPackagesList' }"
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
import EHoldingsPackageTitlesList from "./EHoldingsLocalPackageTitlesList.vue";
import { APIClient } from "../../fetch/api-client.js";
import Toolbar from "../Toolbar.vue";
import ToolbarButton from "../ToolbarButton.vue";
import AdditionalFieldsDisplay from "../AdditionalFieldsDisplay.vue";
import EHoldingsLocalPackageResource from "./EHoldingsLocalPackageResource.vue";

export default {
    extends: EHoldingsLocalPackageResource,
    setup() {
        const format_date = $date;

        const ERMStore = inject("ERMStore");
        const { get_lib_from_av } = ERMStore;

        return {
            ...EHoldingsLocalPackageResource.setup(),
            format_date,
            get_lib_from_av,
        };
    },
    data() {
        return {
            erm_package: {
                package_id: null,
                vendor_id: null,
                name: "",
                external_id: "",
                package_type: "",
                content_type: "",
                created_on: null,
                resources: null,
                package_agreements: [],
                extended_attributes: [],
                _strings: [],
            },
            initialized: false,
        };
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getPackage(to.params.package_id);
        });
    },
    beforeRouteUpdate(to, from) {
        this.erm_package = this.getPackage(to.params.package_id);
    },
    methods: {
        getPackage(package_id) {
            const client = APIClient.erm;
            client.localPackages.get(package_id).then(
                erm_package => {
                    this.erm_package = erm_package;
                    this.initialized = true;
                },
                error => {}
            );
        },
    },
    components: {
        EHoldingsPackageTitlesList,
        Toolbar,
        ToolbarButton,
        AdditionalFieldsDisplay,
    },
    name: "EHoldingsLocalPackagesShow",
};
</script>
<style scoped>
fieldset.rows label {
    width: 25rem;
}
</style>
