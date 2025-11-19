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
import { ref, onBeforeMount, computed } from "vue";
import { APIClient } from "../fetch/api-client.js";
import KohaTable from "./KohaTable.vue";
import { $__ } from "@koha-vue/i18n";
import { useBaseElement } from "../composables/base-element.js";

export default {
    inheritAttrs: false,
    setup(props) {
        const table = ref();
        const resourceCount = ref(0);
        const initialized = ref(false);
        const searchable_additional_fields = ref([]);
        const searchable_av_options = ref([]);
        const tableEvents = ref({
            show: props.instancedResource.goToResourceShow,
            edit: props.instancedResource.goToResourceEdit,
            delete: props.instancedResource.doResourceDelete,
            select: props.instancedResource.doResourceSelect,
        });

        const { accessNestedProperty } = useBaseElement();

        const getResourceCount = async () => {
            await props.instancedResource.apiClient.count().then(
                count => {
                    resourceCount.value = count;
                },
                error => {}
            );
        };
        const getSearchableAdditionalFields = async () => {
            const client = APIClient.additional_fields;
            await client.additional_fields
                .getAll(props.instancedResource.extendedAttributesResourceType)
                .then(
                    response => {
                        searchable_additional_fields.value = response.filter(
                            field => field.searchable
                        );
                    },
                    error => {}
                );
        };
        const getSearchableAVOptions = async () => {
            const client_av = APIClient.authorised_values;
            let av_cat_array = searchable_additional_fields.value
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
                        searchable_av_options.value[av_cat] =
                            av_match.authorised_values.map(av => ({
                                value: av.value,
                                label: av.description,
                            }));
                    });
                });
        };
        const handleShowField = (row, attr, thisResource) => {
            if (!props.instancedResource.components.show) {
                return row[attr.name];
            }
            return (
                '<a href="' +
                thisResource.getResourceShowURL(row[thisResource.idAttr]) +
                '" class="show">' +
                escape_str(row[attr.name]) +
                "</a>"
            );
        };
        const assignShowEvent = (columnActions, i) => {
            if (!props.instancedResource.components.show) return;
            if (!columnActions[i]) {
                columnActions[i] = ["show"];
            }
            if (columnActions[i] && !columnActions[i].includes("show")) {
                columnActions[i].push("show");
            }
        };
        const getTableColumns = resourceAttrs => {
            let get_lib_from_av = props.instancedResource.get_lib_from_av;
            let thisResource = props.instancedResource;
            let columnActions = thisResource.tableOptions.actions;

            const columns = resourceAttrs.reduce((acc, attr, i) => {
                const shouldFieldBeHidden = attr.hideIn && typeof attr.hideIn === "function" ? attr.hideIn() : attr.hideIn
                if (
                    shouldFieldBeHidden && shouldFieldBeHidden.includes("List")
                )
                    return acc;
                if (
                    attr.hasOwnProperty("tableColumnDefinition") &&
                    attr.tableColumnDefinition
                ) {
                    acc.push(attr.tableColumnDefinition);
                    return acc;
                }
                if (attr.name === thisResource.idAttr) {
                    assignShowEvent(columnActions, i);
                    acc.push({
                        title: attr.label,
                        data: attr.name,
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row, meta) {
                            return handleShowField(row, attr, thisResource);
                        },
                    });
                    return acc;
                }
                if (attr.name === thisResource.nameAttr) {
                    assignShowEvent(columnActions, i);
                    acc.push({
                        title: attr.label,
                        data: attr.tableDataSearchFields
                            ? attr.tableDataSearchFields
                            : attr.name,
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row, meta) {
                            return handleShowField(row, attr, thisResource);
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
                if (attr.type === "relationshipSelect") {
                    acc.push({
                        title: attr.label,
                        data: attr.name,
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row, meta) {
                            if (attr.showElement) {
                                const relationshipDisplayAttr =
                                    accessNestedProperty(
                                        attr.showElement.value,
                                        row
                                    );
                                let href = "#";
                                if (
                                    attr.showElement.link?.href &&
                                    attr.showElement.link.slug
                                ) {
                                    href =
                                        attr.showElement.link.href +
                                        `/${row[attr.showElement.link.slug]}`;
                                }
                                return (
                                    '<a href="' +
                                    href +
                                    '">' +
                                    relationshipDisplayAttr +
                                    "</a>"
                                );
                            }
                            return accessNestedProperty(
                                attr.relationshipDisplayAttr,
                                row
                            );
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
                                row[`${attr.name}`] ? $__("Yes") : $__("No")
                            );
                        },
                    });
                    return acc;
                }
                if (attr.type === "radio") {
                    acc.push({
                        title: attr.label,
                        data: attr.name,
                        searchable: true,
                        orderable: true,
                        render: function (data, type, row, meta) {
                            return escape_str(
                                attr.options.find(
                                    o => o.value == row[attr.name]
                                ).description
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
        };

        const tableOptionsWithColumns = computed(() => {
            props.instancedResource.tableOptions.columns = getTableColumns(
                props.instancedResource.resourceAttrs
            ).map(col => {
                const filterOptions =
                    props.instancedResource.tableOptions.filters_options;
                const filterRequired =
                    filterOptions &&
                    Object.keys(filterOptions).includes(col.data);
                if (filterRequired) {
                    col.dataFilter = col.data;
                }
                return col;
            });
            return props.instancedResource.tableOptions;
        });

        const tableEventList = computed(() => {
            const actionButtons = props.instancedResource.tableOptions.actions[
                "-1"
            ].reduce((acc, curr) => {
                if (typeof curr === "object") {
                    const actionName = Object.keys(curr)[0];
                    if (!curr[actionName].callback) return acc;
                    acc[actionName] = curr[actionName].callback;
                }
                return acc;
            }, {});
            return { ...tableEvents.value, ...actionButtons };
        });
        onBeforeMount(() => {
            if (props.instancedResource.embedded) {
                getResourceCount().then(() => (initialized.value = true));
            } else {
                getResourceCount().then(() => {
                    if (props.instancedResource.hasAdditionalFields) {
                        getSearchableAdditionalFields().then(() =>
                            getSearchableAVOptions().then(
                                () => (initialized.value = true)
                            )
                        );
                    } else {
                        initialized.value = true;
                    }
                });
            }
        });
        return {
            table,
            resourceCount,
            initialized,
            searchable_additional_fields,
            searchable_av_options,
            tableEventList,
            getTableColumns,
            tableOptionsWithColumns,
        };
    },
    props: {
        instancedResource: Object,
    },
    components: { Toolbar, KohaTable },
    name: "ResourcesList",
};
</script>
