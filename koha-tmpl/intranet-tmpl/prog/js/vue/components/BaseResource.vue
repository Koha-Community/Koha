<template>
    <div>
        <ResourceList
            v-if="routeAction === 'list'"
            :instancedResource="instancedResource"
            :key="instancedResource.refreshTemplate"
            @select-resource="$emit('select-resource', $event)"
        >
            <template #toolbar="{ resource, componentPropData }">
                <Toolbar
                    v-if="!instancedResource.embedded"
                    :toolbarButtons="instancedResource.toolbarButtons"
                    component="list"
                    :resource="resource"
                    :componentPropData="componentPropData"
                />
            </template>
            <template #filters="{ table }">
                <ResourceListFilters
                    v-if="instancedResource.addFiltersToList"
                    :instancedResource="instancedResource"
                    :table="table"
                />
            </template>
        </ResourceList>
        <ResourceShow
            v-if="routeAction === 'show'"
            :instancedResource="instancedResource"
            :key="instancedResource.refreshTemplate"
        >
            <template #toolbar="{ resource, componentPropData }">
                <Toolbar
                    :toolbarButtons="instancedResource.toolbarButtons"
                    component="show"
                    :resource="resource"
                    :componentPropData="componentPropData"
                />
            </template>
        </ResourceShow>
        <ResourceFormAdd
            v-if="['add', 'edit'].includes(routeAction)"
            :instancedResource="instancedResource"
            :key="instancedResource.refreshTemplate"
        >
            <template #toolbar="{ resource, componentPropData }">
                <Toolbar
                    :toolbarButtons="instancedResource.toolbarButtons"
                    component="form"
                    :resource="resource"
                    :componentPropData="componentPropData"
                    :sticky="
                        instancedResource.stickyToolbar &&
                        instancedResource.stickyToolbar.includes('Form')
                    "
                />
            </template>
        </ResourceFormAdd>
    </div>
</template>

<script>
import ResourceListFilters from "./ResourceListFilters.vue";
import ResourceShow from "./ResourceShow.vue";
import ResourceFormAdd from "./ResourceFormAdd.vue";
import ResourceList from "./ResourceList.vue";
import Toolbar from "./Toolbar.vue";

export default {
    props: {
        routeAction: String,
        instancedResource: Object,
    },
    components: {
        ResourceListFilters,
        ResourceShow,
        ResourceFormAdd,
        ResourceList,
        Toolbar,
    },
    setup(props) {
        return {
            ...(typeof logged_in_user !== "undefined" && { logged_in_user }),
        };
    },
    name: "BaseResource",
};
</script>

<style>
fieldset.rows ol table {
    display: table;
    font-size: 100%;
}
</style>
