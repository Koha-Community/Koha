<template>
    <div v-if="!initialized">{{ $__("Loading") }}</div>
    <div v-else :id="`${resourceNamePlural}_list`">
        <Toolbar v-if="!embedded">
            <ToolbarButton
                action="add"
                @go-to-add-resource="goToResourceAdd"
                :title="$__('New %s').format(i18n.displayNameLowerCase)"
            />
            <ToolbarButton
                v-for="(button, i) in getToolbarButtons()"
                v-bind:key="i"
                :to="button.to"
                :icon="button.icon"
                :title="button.title"
            />
        </Toolbar>
        <template v-if="resourceCount > 0">
            <slot name="filters" :table="table" />
        </template>
        <div v-if="resourceCount > 0" class="page-section">
            <KohaTable
                ref="table"
                v-bind="tableOptionsWithColumns"
                :searchable_additional_fields="searchable_additional_fields"
                :searchable_av_options="searchable_av_options"
                @show="goToResourceShow"
                @edit="goToResourceEdit"
                @delete="doResourceDelete"
                @select="doResourceSelect"
            ></KohaTable>
        </div>
        <div v-else class="alert alert-info">
            {{ $__("There are no %s defined").format(i18n.displayNamePlural) }}
        </div>
    </div>
</template>

<script>
import Toolbar from "./Toolbar.vue";
import ToolbarButton from "./ToolbarButton.vue";
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
        embedded: Boolean,
        apiClient: Object,
        i18n: Object,
        tableOptions: Object,
        goToResourceShow: Function,
        goToResourceEdit: Function,
        doResourceDelete: Function,
        goToResourceAdd: Function,
        doResourceSelect: Function,
        resourceName: String,
        resourceNamePlural: String,
        hasAdditionalFields: { type: Boolean, default: false },
        extendedAttributesResourceType: String,
        resourceAttrs: Array,
        nameAttr: String,
        idAttr: String,
        getToolbarButtons: {
            type: Function,
            default: () => [],
        },
    },
    data() {
        return {
            resourceCount: 0,
            initialized: false,
            searchable_additional_fields: [],
            searchable_av_options: [],
            filters: this.getFilters ? this.getFilters(this.$route.query) : {},
        };
    },
    created() {
        if (this.embedded) {
            this.getResourceCount().then(() => (this.initialized = true));
        } else {
            this.getResourceCount().then(() => {
                if (this.hasAdditionalFields) {
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
            await this.apiClient.count().then(
                count => {
                    this.resourceCount = count;
                },
                error => {}
            );
        },
        async getSearchableAdditionalFields() {
            const client = APIClient.additional_fields;
            await client.additional_fields
                .getAll(this.extendedAttributesResourceType)
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
            let get_lib_from_av = this.get_lib_from_av;

            const columns = resourceAttrs
                ?.filter(attr => attr.showInTable)
                .reduce((acc, attr, i) => {
                    if (typeof attr.showInTable === "object") {
                        acc.push(attr.showInTable);
                        return acc;
                    }
                    if (attr.name === this.idAttr) {
                        acc.push({
                            title: attr.label,
                            data: attr.name,
                            searchable: true,
                            orderable: true,
                            render: function (data, type, row, meta) {
                                return (
                                    '<a role="button" class="show">' +
                                    escape_str(row[attr.name]) +
                                    "</a>"
                                );
                            },
                        });
                        return acc;
                    }
                    if (attr.name === this.nameAttr) {
                        acc.push({
                            title: attr.label,
                            data: attr.name,
                            searchable: true,
                            orderable: true,
                            render: function (data, type, row, meta) {
                                return (
                                    '<a role="button" class="show">' +
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
            this.tableOptions.columns = this.getTableColumns(
                this.resourceAttrs
            );
            return this.tableOptions;
        },
    },
    components: { Toolbar, ToolbarButton, KohaTable },
    name: "ResourcesList",
};
</script>
