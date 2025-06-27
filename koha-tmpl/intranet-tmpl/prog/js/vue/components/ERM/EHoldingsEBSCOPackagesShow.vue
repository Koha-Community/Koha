<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else-if="ermPackage" id="packages_show">
        <h2>
            {{ $__("Package #%s").format(ermPackage.package_id) }}
            <span v-if="!updatingIsSelected">
                <a
                    v-if="!ermPackage.is_selected"
                    class="btn btn-default btn-xs"
                    role="button"
                    @click="addToHoldings"
                    ><font-awesome-icon icon="plus" />
                    {{ $__("Add package to holdings") }}</a
                >
                <a
                    v-else
                    class="btn btn-default btn-xs"
                    role="button"
                    id="remove-from-holdings"
                    @click="removeFromHoldings"
                    ><font-awesome-icon icon="minus" />
                    {{ $__("Remove package from holdings") }}</a
                > </span
            ><span v-else><font-awesome-icon icon="spinner" /></span>
        </h2>
        <div>
            <fieldset class="rows">
                <ol>
                    <li>
                        <label>{{ $__("Package name") }}:</label>
                        <span>
                            {{ ermPackage.name }}
                        </span>
                    </li>
                    <li v-if="ermPackage.vendor">
                        <label>{{ $__("Vendor") }}:</label>
                        <span>{{ ermPackage.vendor.name }}</span>
                    </li>
                    <li v-if="false">
                        <label>{{ $__("External ID") }}:</label>
                        <span>
                            <span v-if="false"
                                >FIXME - Does not replace this v-if with an HTML
                                comment, it breaks xgettext</span
                            >
                            <span v-if="false"
                                >FIXME - Create a syspref to store the URL</span
                            >
                            <a
                                :href="`https://replace_with_syspref_value_here.folio.ebsco.com/eholdings/packages/${ermPackage.vendor.external_id}-${ermPackage.external_id}`"
                            >
                                {{ ermPackage.vendor.external_id }}-{{
                                    ermPackage.external_id
                                }}
                            </a>
                        </span>
                    </li>
                    <li>
                        <label>{{ $__("Package type") }}:</label>
                        <span>{{
                            get_lib_from_av(
                                "av_package_types",
                                ermPackage.package_type
                            )
                        }}</span>
                    </li>
                    <li>
                        <label>{{ $__("Content type") }}:</label>
                        <span>{{
                            get_lib_from_av(
                                "av_package_content_types",
                                ermPackage.content_type
                            )
                        }}</span>
                    </li>
                    <li v-if="ermPackage.created_on">
                        <label>{{ $__("Created on") }}:</label>
                        <span>{{ format_date(ermPackage.created_on) }}</span>
                    </li>

                    <li>
                        <label>Agreements</label>
                        <EHoldingsPackageAgreements
                            :erm_package="ermPackage"
                            @refresh-agreements="refreshAgreements"
                        />
                    </li>

                    <li>
                        <label>{{
                            $__("Titles (%s)").format(
                                ermPackage.resources_count
                            )
                        }}</label>
                    </li>
                </ol>
                <div v-if="ermPackage.resources_count">
                    <EHoldingsPackageTitlesList
                        :package_id="ermPackage.package_id.toString()"
                    />
                </div>
            </fieldset>
            <fieldset class="action">
                <router-link
                    :to="{ name: 'EHoldingsEBSCOPackagesList' }"
                    role="button"
                    class="cancel"
                    >{{ $__("Close") }}</router-link
                >
            </fieldset>
        </div>
    </div>
</template>

<script>
import { inject, onBeforeMount, ref } from "vue";
import EHoldingsPackageAgreements from "./EHoldingsEBSCOPackageAgreements.vue";
import EHoldingsPackageTitlesList from "./EHoldingsEBSCOPackageTitlesList.vue";
import { APIClient } from "../../fetch/api-client.js";
import { onBeforeRouteUpdate, useRoute } from "vue-router";

export default {
    setup() {
        const route = useRoute();
        const format_date = $date;

        const ERMStore = inject("ERMStore");
        const { get_lib_from_av } = ERMStore;

        const ermPackage = ref({
            package_id: null,
            vendor_id: null,
            name: "",
            external_id: "",
            provider: "",
            package_type: "",
            content_type: "",
            created_on: null,
            resources: null,
            package_agreements: [],
        });
        const initialized = ref(false);
        const updatingIsSelected = ref(false);

        const getPackage = package_id => {
            const client = APIClient.erm;
            client.EBSCOPackages.get(package_id).then(
                result => {
                    ermPackage.value = result;
                    initialized.value = true;
                    updatingIsSelected.value = false;
                },
                error => {}
            );
        };
        const editSelected = is_selected => {
            updatingIsSelected.value = true;
            const client = APIClient.erm;
            client.EBSCOPackages.patch(ermPackage.value.package_id, {
                is_selected,
            }).then(
                result => {
                    // Refresh the page. We should not need that actually.
                    getPackage(ermPackage.value.package_id);
                },
                error => {}
            );
        };
        const addToHoldings = () => {
            editSelected(true);
        };
        const removeFromHoldings = () => {
            editSelected(false);
        };
        const refreshAgreements = () => {
            // FIXME We could GET /erm/eholdings/packages/$package_id/agreements instead
            initialized.value = false;
            getPackage(ermPackage.value.package_id);
        };

        onBeforeMount(() => {
            getPackage(route.params.package_id);
        });
        onBeforeRouteUpdate((to, from) => {
            ermPackage.value = getPackage(to.params.package_id);
        });
        return {
            format_date,
            get_lib_from_av,
            ermPackage,
            initialized,
            updatingIsSelected,
            addToHoldings,
            removeFromHoldings,
            refreshAgreements,
        };
    },
    components: {
        EHoldingsPackageAgreements,
        EHoldingsPackageTitlesList,
    },
    name: "EHoldingsEBSCOPackagesShow",
};
</script>
<style scoped>
fieldset.rows label {
    width: 25rem;
}
</style>
