<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else-if="resource" id="eholdings_resources_show">
        <h2>
            {{ $__("Resource #%s").format(resource.resource_id) }}
            <span v-if="!updatingIsSelected">
                <a
                    v-if="!resource.is_selected"
                    class="btn btn-default btn-xs"
                    role="button"
                    @click="addToHoldings"
                    ><font-awesome-icon icon="plus" />
                    {{ $__("Add title to holdings") }}</a
                >
                <a
                    v-else
                    class="btn btn-default btn-xs"
                    role="button"
                    id="remove-from-holdings"
                    @click="removeFromHoldings"
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
                                :to="{
                                    name: 'EHoldingsEBSCOTitlesShow',
                                    params: { title_id: resource.title_id },
                                }"
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
                                :to="{
                                    name: 'EHoldingsEBSCOPackagesShow',
                                    params: { package_id: resource.package_id },
                                }"
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
import { ref, onBeforeMount } from "vue";
import { APIClient } from "../../fetch/api-client.js";

export default {
    setup() {
        const format_date = $date;

        const resource = ref({
            resource_id: null,
            title_id: null,
            package_id: null,
            started_on: "",
            ended_on: "",
            proxy: "",
            title: {},
            package: {},
        });
        const initialized = ref(false);
        const updatingIsSelected = ref(false);

        const getResource = resource_id => {
            const client = APIClient.erm;
            client.EBSCOResources.get(resource_id).then(
                resource => {
                    resource.value = resource;
                    initialized.value = true;
                    updatingIsSelected.value = false;
                },
                error => {}
            );
        };
        const editSelected = is_selected => {
            updatingIsSelected.value = true;
            const client = APIClient.erm;
            client.EBSCOResources.patch(resource.value.resource_id, {
                is_selected,
            }).then(
                result => {
                    // Refresh the page. We should not need that actually.
                    getResource(resource.value.resource_id);
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

        onBeforeMount(() => {
            getResource(route.params.resource_id);
        });
        onBeforeRouteUpdate((to, from) => {
            resource.value = getResource(to.params.resource_id);
        });

        return {
            format_date,
            resource,
            initialized,
            updatingIsSelected,
            addToHoldings,
            removeFromHoldings,
        };
    },
    name: "EHoldingsEBSCOResourcesShow",
};
</script>
<style scoped>
fieldset.rows label {
    width: 25rem;
}
</style>
