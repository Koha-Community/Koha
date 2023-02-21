<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else-if="resource" id="eholdings_resources_show">
        <h2>
            {{ $__("Resource #%s").format(resource.resource_id) }}
            <span v-if="!updating_is_selected">
                <a
                    v-if="!resource.is_selected"
                    class="btn btn-default btn-xs"
                    role="button"
                    @click="add_to_holdings"
                    ><font-awesome-icon icon="plus" />
                    {{ $__("Add title to holdings") }}</a
                >
                <a
                    v-else
                    class="btn btn-default btn-xs"
                    role="button"
                    id="remove-from-holdings"
                    @click="remove_from_holdings"
                    ><font-awesome-icon icon="minus" />
                    {{ $__("Remove title from holdings") }}</a
                > </span
            ><span v-else><font-awesome-icon icon="spinner" /></span>
        </h2>
        <div>
            <fieldset class="rows">
                <legend>{{ $__("Resource information") }}</legend>
                <ol>
                    <li v-if="resource.resource_id">
                        <label>{{ $__("Resource identifier") }}:</label>
                        <span>
                            {{ resource.resource_id }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $__("Publication title") }}:</label>
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
                        <label>{{ $__("Publisher name") }}:</label>
                        <span>
                            {{ resource.title.publisher_name }}
                        </span>
                    </li>
                    <li>
                        <label>{{ $__("Publication type") }}:</label>
                        <span>
                            {{ resource.title.publication_type }}
                        </span>
                    </li>
                    <li v-if="resource.title.print_identifier">
                        <label>{{ $__("Print-format identifier") }}:</label>
                        <span>
                            {{ resource.title.print_identifier }}
                        </span>
                    </li>
                    <li v-if="resource.title.online_identifier">
                        <label>{{ $__("Online-format identifier") }}:</label>
                        <span>
                            {{ resource.title.online_identifier }}
                        </span>
                    </li>
                </ol>
            </fieldset>

            <fieldset class="rows">
                <ol>
                    <li>
                        <label>{{ $__("Package") }}:</label>
                        <span
                            ><router-link
                                :to="`/cgi-bin/koha/erm/eholdings/ebsco/packages/${resource.package_id}`"
                                >{{ resource.package.name }}</router-link
                            ></span
                        >
                    </li>

                    <li>
                        <label>{{ $__("Vendor") }}:</label>
                        <span v-if="resource.vendor">
                            {{ resource.vendor.name }}
                        </span>
                    </li>
                    <li v-if="resource.package.content_type">
                        <label>{{ $__("Package content type") }}:</label>
                        <span>{{ resource.package.content_type }}</span>
                    </li>
                </ol>
            </fieldset>

            <fieldset class="rows">
                <legend>Resource settings</legend>
                <ol>
                    <li>
                        <label>{{ $__("Coverage dates") }}:</label>
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
import { inject } from "vue"
import { storeToRefs } from "pinia"
import { APIClient } from "../../fetch/api-client.js"

export default {
    setup() {
        const format_date = $date

        const vendorStore = inject("vendorStore")
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
                started_on: "",
                ended_on: "",
                proxy: "",
                title: {},
                package: {},
            },
            initialized: false,
            updating_is_selected: false,
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
        getResource(resource_id) {
            const client = APIClient.erm
            client.EBSCOResources.get(resource_id).then(
                resource => {
                    this.resource = resource
                    this.initialized = true
                    this.updating_is_selected = false
                },
                error => {}
            )
        },
        edit_selected(is_selected) {
            this.updating_is_selected = true
            const client = APIClient.erm
            client.EBSCOResources.patch(this.resource.resource_id, {
                is_selected,
            }).then(
                result => {
                    // Refresh the page. We should not need that actually.
                    this.getResource(this.resource.resource_id)
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
    },
    name: "EHoldingsEBSCOResourcesShow",
}
</script>
<style scoped>
fieldset.rows label {
    width: 25rem;
}
</style>
