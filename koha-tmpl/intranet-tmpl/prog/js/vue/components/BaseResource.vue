<template>
    <ResourceList
        v-if="routeAction === 'list'"
        :instancedResource="instancedResource"
        @select-resource="$emit('select-resource', $event)"
    >
        <template #toolbar="{ resource, componentPropData }">
            <Toolbar
                v-if="!optionalResourceProps.embedded"
                :toolbarButtons="instancedResource.toolbarButtons"
                component="list"
                :resource="resource"
                :i18n="instancedResource.i18n"
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
    >
        <template #toolbar="{ resource, componentPropData }">
            <Toolbar
                :toolbarButtons="instancedResource.toolbarButtons"
                component="show"
                :resource="resource"
                :i18n="instancedResource.i18n"
                :componentPropData="componentPropData"
            />
        </template>
    </ResourceShow>
    <ResourceFormAdd
        v-if="['add', 'edit'].includes(routeAction)"
        :instancedResource="instancedResource"
    />
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
            ...props,
            ...(typeof logged_in_user !== "undefined" && { logged_in_user }),
        };
    },
    data() {
        const optionalResourceProps = {
            embedded: this.instancedResource.embedded || false,
            extendedAttributesResourceType:
                this.instancedResource.extendedAttributesResourceType || null,
            addFiltersToList: this.instancedResource.addFiltersToList || null,
            formGroupsDisplayMode:
                this.instancedResource.formGroupsDisplayMode || null,
            appendToShow: this.instancedResource.appendToShow || (() => []),
            nameAttr: this.instancedResource.nameAttr || null,
            idAttr: this.instancedResource.idAttr || null,
        };
        return {
            optionalResourceProps,
            refreshTemplate: false,
        };
    },
    name: "BaseResource",
};
</script>
