<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else-if="erm_package" id="packages_show">
        <h2>
            {{ $__("Package #%s").format(erm_package.package_id) }}
            <span v-if="!updating_is_selected">
                <a
                    v-if="!erm_package.is_selected"
                    class="btn btn-default btn-xs"
                    role="button"
                    @click="add_to_holdings"
                    ><font-awesome-icon icon="plus" />
                    {{ $__("Add package to holdings") }}</a
                >
                <a
                    v-else
                    class="btn btn-default btn-xs"
                    role="button"
                    id="remove-from-holdings"
                    @click="remove_from_holdings"
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
                            {{ erm_package.name }}
                        </span>
                    </li>
                    <li v-if="erm_package.vendor">
                        <label>{{ $__("Vendor") }}:</label>
                        <span>{{ erm_package.vendor.name }}</span>
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
                                :href="`https://replace_with_syspref_value_here.folio.ebsco.com/eholdings/packages/${erm_package.vendor.external_id}-${erm_package.external_id}`"
                            >
                                {{ erm_package.vendor.external_id }}-{{
                                    erm_package.external_id
                                }}
                            </a>
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
                    <li v-if="erm_package.created_on">
                        <label>{{ $__("Created on") }}:</label>
                        <span>{{ format_date(erm_package.created_on) }}</span>
                    </li>

                    <li>
                        <label>Agreements</label>
                        <EHoldingsPackageAgreements
                            :erm_package="erm_package"
                            @refresh-agreements="refreshAgreements"
                        />
                    </li>

                    <li>
                        <label
                            >Titles ({{ erm_package.resources_count }})</label
                        >
                        <div v-if="erm_package.resources_count">
                            <EHoldingsPackageTitlesList
                                :package_id="erm_package.package_id.toString()"
                            />
                        </div>
                    </li>

                    <li></li>
                </ol>
            </fieldset>
            <fieldset class="action">
                <router-link
                    to="/cgi-bin/koha/erm/eholdings/ebsco/packages"
                    role="button"
                    class="cancel"
                    >{{ $__("Close") }}</router-link
                >
            </fieldset>
        </div>
    </div>
</template>

<script>
import { inject } from "vue"
import EHoldingsPackageAgreements from "./EHoldingsEBSCOPackageAgreements.vue"
import EHoldingsPackageTitlesList from "./EHoldingsEBSCOPackageTitlesList.vue"
import { APIClient } from "../../fetch/api-client.js"

export default {
    setup() {
        const format_date = $date

        const AVStore = inject("AVStore")
        const { get_lib_from_av } = AVStore

        return {
            format_date,
            get_lib_from_av,
        }
    },
    data() {
        return {
            erm_package: {
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
            },
            initialized: false,
            updating_is_selected: false,
        }
    },
    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getPackage(to.params.package_id)
        })
    },
    beforeRouteUpdate(to, from) {
        this.erm_package = this.getPackage(to.params.package_id)
    },
    methods: {
        getPackage(package_id) {
            const client = APIClient.erm
            client.EBSCOPackages.get(package_id).then(
                erm_package => {
                    this.erm_package = erm_package
                    this.initialized = true
                    this.updating_is_selected = false
                },
                error => {}
            )
        },
        edit_selected(is_selected) {
            this.updating_is_selected = true
            const client = APIClient.erm
            client.EBSCOPackages.patch(this.erm_package.package_id, {
                is_selected,
            }).then(
                result => {
                    // Refresh the page. We should not need that actually.
                    this.getPackage(this.erm_package.package_id)
                },
                error => {}
            )
        },
        add_to_holdings() {
            this.edit_selected(true)
        },
        remove_from_holdings() {
            this.edit_selected(false)
        },
        refreshAgreements() {
            // FIXME We could GET /erm/eholdings/packages/$package_id/agreements instead
            this.initialized = false
            this.getPackage(this.erm_package.package_id)
        },
    },
    components: {
        EHoldingsPackageAgreements,
        EHoldingsPackageTitlesList,
    },
    name: "EHoldingsEBSCOPackagesShow",
}
</script>
<style scoped>
fieldset.rows label {
    width: 25rem;
}
</style>
