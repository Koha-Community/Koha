<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else :id="`${instancedResource.resourceNamePlural}_list`">
        <slot name="toolbar" :componentPropData="{ ...$props, ...$data }" />
        <template v-if="resourceCount > 0">
            <slot name="filters" :table="table" />
        </template>
        <div v-if="resourceCount > 0" class="page-section">
            <KohaTable
                ref="table"
                v-bind="tableOptionsWithColumns"
                :searchable_additional_fields="searchable_additional_fields"
                :searchable_av_options="searchable_av_options"
                v-on="tableEventList"
            ></KohaTable>
        </div>
        <div v-else class="alert alert-info">
            {{ instancedResource.i18n.emptyListMessage }}
        </div>
    </div>
</template>

<script>
import Toolbar from "./Toolbar.vue";
import { ref, inject } from "vue";
import { APIClient } from "../fetch/api-client.js";
import KohaTable from "./KohaTable.vue";

export default {
    inheritAttrs: false,
    setup(props) {
        const table = ref();

        const AVStore = inject("AVStore");
        const { get_lib_from_av } = AVStore;

        return {
            table,
            get_lib_from_av,
        };
    },
    props: {
        instancedResource: Object,
    },
    data() {
        return {
            resourceCount: 0,
            initialized: false,
            searchable_additional_fields: [],
            searchable_av_options: [],
            tableEvents: {
                show: this.instancedResource.goToResourceShow,
                edit: this.instancedResource.goToResourceEdit,
                delete: this.instancedResource.doResourceDelete,
                select: this.instancedResource.doResourceSelect,
            },
        };
    },
    created() {
        if (this.instancedResource.embedded) {
            this.getResourceCount().then(
                () => (this.instancedResource.initialized = true)
            );
        } else {
            this.getResourceCount().then(() => {
                if (this.instancedResource.hasAdditionalFields) {
                    this.getSearchableAdditionalFields().then(() =>
                        this.getSearchableAVOptions().then(
                            () => (this.initialized = true)
                        )
                    );
                } else {
                    this.initialized = true;
                }
            });
        }
    },
    methods: {
        async getResourceCount() {
            await this.instancedResource.apiClient.count().then(
                count => {
                    this.resourceCount = count;
                },
                error => {}
            );
        },
        async getSearchableAdditionalFields() {
            const client = APIClient.additional_fields;
            await client.additional_fields
                .getAll(this.instancedResource.extendedAttributesResourceType)
                .then(
                    searchable_additional_fields => {
                        this.searchable_additional_fields =
                            searchable_additional_fields.filter(
                                field => field.searchable
                            );
                    },
                    error => {}
                );
        },
        async getSearchableAVOptions() {
            const client_av = APIClient.authorised_values;
            let av_cat_array = this.searchable_additional_fields
                .filter(field => field.authorised_value_category_name)
                .map(field => field.authorised_value_category_name);

            await client_av.values
                .getCategoriesWithValues([
                    ...new Set(av_cat_array.map(av_cat => '"' + av_cat + '"')),
                ]) // unique
                .then(av_categories => {
                    av_cat_array.forEach(av_cat => {
                        let av_match = av_categories.find(
                            element => element.category_name == av_cat
                        );
                        this.searchable_av_options[av_cat] =
                            av_match.authorised_values.map(av => ({
                                value: av.value,
                                label: av.description,
                            }));
                    });
                });
        },
        getTableColumns(resourceAttrs) {
            let get_lib_from_av = this.instancedResource.get_lib_from_av;
            let thisResource = this.instancedResource;

            const columns = resourceAttrs.reduce((acc, attr, i) => {
                if (
                    attr.hasOwnProperty("hideIn") &&
                    attr.hideIn.includes("List")
                )
                    return acc;
                if (
                    attr.hasOwnProperty("tableColumnDefinition") &&
                    attr.tableColumnDefinition
                ) {
                    acc.push(attr.tableColumnDefinition);
                    return acc;
                }
                if (attr.name === this.instancedResource.idAttr) {
                    acc.push({
                        title: attr.label,
                        data: attr.name,
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row, meta) {
                            return (
                                '<a href="' +
                                thisResource.getResourceShowURL(
                                    row[thisResource.idAttr]
                                ) +
                                '" class="show">' +
                                escape_str(row[thisResource.idAttr]) +
                                "</a>"
                            );
                        },
                    });
                    return acc;
                }
                if (attr.name === this.instancedResource.nameAttr) {
                    acc.push({
                        title: attr.label,
                        data: attr.name,
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row, meta) {
                            return (
                                '<a href="' +
                                thisResource.getResourceShowURL(
                                    row[thisResource.idAttr]
                                ) +
                                '" class="show">' +
                                escape_str(row[attr.name]) +
                                "</a>"
                            );
                        },
                    });
                    return acc;
                }
                if (attr.type === "vendor") {
                    acc.push({
                        title: attr.label,
                        data: attr.name,
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row, meta) {
                            return row.vendor_id != undefined
                                ? '<a href="/cgi-bin/koha/acquisition/vendors/' +
                                      row.vendor_id +
                                      '">' +
                                      escape_str(row.vendor.name) +
                                      "</a>"
                                : "";
                        },
                    });
                    return acc;
                }
                if (attr.type === "select" && attr.avCat) {
                    acc.push({
                        title: attr.label,
                        data: attr.name,
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row, meta) {
                            return get_lib_from_av(
                                attr.avCat,
                                row[`${attr.name}`]
                            );
                        },
                    });
                    return acc;
                }
                if (attr.type === "date") {
                    acc.push({
                        title: attr.label,
                        data: attr.name,
                        type: "date",
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row, meta) {
                            return $date(row[`${attr.name}`]);
                        },
                    });
                    return acc;
                }
                if (attr.type === "boolean" || attr.type === "checkbox") {
                    acc.push({
                        title: attr.label,
                        data: attr.name,
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row, meta) {
                            return escape_str(
                                row[`${attr.name}`] ? __("Yes") : __("No")
                            );
                        },
                    });
                    return acc;
                }
                acc.push({
                    title: attr.label,
                    data: attr.name,
                    searchable: true,
                    orderable: true,
                });
                return acc;
            }, []);
            return columns;
        },
    },
    computed: {
        tableOptionsWithColumns() {
            this.instancedResource.tableOptions.columns = this.getTableColumns(
                this.instancedResource.resourceAttrs
            );
            return this.instancedResource.tableOptions;
        },
        tableEventList() {
            const actionButtons = this.instancedResource.tableOptions.actions[
                "-1"
            ].reduce((acc, curr) => {
                if (typeof curr === "object") {
                    const actionName = Object.keys(curr)[0];
                    acc[actionName] = curr[actionName].callback;
                }
                return acc;
            }, {});
            return { ...this.tableEvents, ...actionButtons };
        },
    },
    components: { Toolbar, KohaTable },
    name: "ResourcesList",
};
</script>
