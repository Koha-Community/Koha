<template>
    <div v-if="!initialized">{{ $t("Loading") }}</div>
    <div v-else-if="resource" id="eholdings_resources_show">
        <h2>
            {{ $t("Resource .id", { id: resource.resource_id }) }}
        </h2>
        <div>
            <fieldset class="rows">
                <legend>{{ $t("Resource information") }}</legend>
                <ol>
                    <li v-if="resource.resource_id">
                        <label>{{ $t("Resource identifier") }}:</label>
                        <span>
                            {{ resource.resource_id }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Publication title") }}:</label>
                        <span
                            ><router-link
                                :to="`/cgi-bin/koha/erm/eholdings/ebsco/titles/${resource.title_id}`"
                                >{{
                                    resource.title.publication_title
                                }}</router-link
                            ></span
                        >
                    </li>
                    <li>
                        <label>{{ $t("Publisher name") }}:</label>
                        <span>
                            {{ resource.title.publisher_name }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $t("Publication type") }}:</label>
                        <span>
                            {{ resource.title.publication_type }}
                        </span>
                    </li>
                    <li v-if="resource.title.print_identifier">
                        <label>{{ $t("Print-format identifier") }}:</label>
                        <span>
                            {{ resource.title.print_identifier }}
                        </span>
                    </li>
                    <li v-if="resource.title.online_identifier">
                        <label>{{ $t("Online-format identifier") }}:</label>
                        <span>
                            {{ resource.title.online_identifier }}
                        </span>
                    </li>
                </ol>
            </fieldset>

            <fieldset class="rows">
                <ol>
                    <li>
                        <label>{{ $t("Package") }}:</label>
                        <span
                            ><router-link
                                :to="`/cgi-bin/koha/erm/eholdings/ebsco/packages/${resource.package_id}`"
                                >{{ resource.package.name }}</router-link
                            ></span
                        >
                    </li>

                    <li>
                        <label>{{ $t("Vendor") }}:</label>
                        <span v-if="resource.vendor">
                            {{ resource.vendor.name }}
                        </span>
                    </li>
                    <li v-if="resource.package.content_type">
                        <label>{{ $t("Package content type") }}:</label>
                        <span>{{ resource.package.content_type }}</span>
                    </li>
                </ol>
            </fieldset>

            <fieldset class="rows">
                <legend>Resource settings</legend>
                <ol>
                    <li>
                        <label>{{ $t("Coverage dates") }}:</label>
                        <span
                            >{{ format_date(resource.started_on) }}-{{
                                format_date(resource.ended_on)
                            }}</span
                        >
                    </li>
                </ol>
            </fieldset>
        </div>
    </div>
</template>

<script>
import { fetchEBSCOResource } from "../../fetch"
import { useVendorStore } from "../../stores/vendors"
import { storeToRefs } from "pinia"
export default {
    setup() {
        const format_date = $date

        const vendorStore = useVendorStore()
        const { vendors } = storeToRefs(vendorStore)
        return {
            format_date,
            vendors,
        }
    },
    data() {
        return {
            resource: {
                resource_id: null,
                title_id: null,
                package_id: null,
                started_on: '',
                ended_on: '',
                proxy: '',
                title: {},
                package: {},
            },
            initialized: false,
        }
    },

    beforeRouteEnter(to, from, next) {
        next(vm => {
            vm.getResource(to.params.resource_id)
        })
    },
    beforeRouteUpdate(to, from) {
        this.resource = this.getResource(to.params.resource_id)
    },
    methods: {
        async getResource(resource_id) {
            const resource = await fetchEBSCOResource(resource_id)
            this.resource = resource
            this.initialized = true
        },
    },
    name: "EHoldingsEBSCOResourcesShow",
}
</script>
<style scoped>
fieldset.rows label {
    width: 25rem;
}
</style>
