<template>
    <div id="title_list_result">
        <div id="filters">
            <a href="#" @click.prevent="toggleFilters($event)"
                ><i class="fa fa-search"></i>

                {{ displayFilters ? $__("Hide filters") : $__("Show filters") }}
            </a>
            <fieldset v-if="displayFilters">
                <ol>
                    <li>
                        <label>{{ $__("Title") }}:</label>
                        <input
                            type="text"
                            id="publication_title_filter"
                            v-model="filters.publication_title"
                            @keyup.enter="filterTable"
                        />
                    </li>
                    <li>
                        <label>{{ $__("Publication type") }}:</label>
                        <select
                            id="publication_type_filter"
                            v-model="filters.publication_type"
                        >
                            <option value="">{{ $__("All") }}</option>
                            <option
                                v-for="type in authorisedValues.av_title_publication_types"
                                :key="type.value"
                                :value="type.value"
                            >
                                {{ type.description }}
                            </option>
                        </select>
                    </li>
                    <li>
                        <label>{{ $__("Selection status") }}:</label>
                        <select
                            id="selection_type_filter"
                            v-model="filters.selection_type"
                        >
                            <option value="0">{{ $__("All") }}</option>
                            <option value="1">{{ $__("Selected") }}</option>
                            <option value="2">{{ $__("Not selected") }}</option>
                        </select>
                    </li>
                </ol>

                <input
                    @click="filterTable"
                    id="filterTable"
                    type="button"
                    :value="$__('Filter')"
                />
            </fieldset>
        </div>
        <KohaTable ref="table" v-bind="tableOptions" @show="doShow"></KohaTable>
    </div>
</template>

<script>
import { inject, ref, reactive, useTemplateRef } from "vue";
import { storeToRefs } from "pinia";
import KohaTable from "../KohaTable.vue";
import { useRoute, useRouter } from "vue-router";
import { $__ } from "@koha-vue/i18n";

export default {
    setup(props) {
        const route = useRoute();
        const router = useRouter();
        const ERMStore = inject("ERMStore");
        const { authorisedValues } = storeToRefs(ERMStore);
        const { get_lib_from_av, map_av_dt_filter } = ERMStore;

        const table = useTemplateRef("table");
        const filters = reactive({
            publication_title: route.query.publication_title || "",
            publication_type: route.query.publication_type || "",
            selection_type: route.query.selection_type || "",
        });

        const doShow = ({ resource_id }, dt, event) => {
            event.preventDefault();
            router.push({
                name: "EHoldingsEBSCOResourcesShow",
                params: { resource_id },
            });
        };
        const filterTable = () => {
            table.redraw(
                "/api/v1/erm/eholdings/ebsco/packages/" +
                    props.package_id +
                    "/resources"
            );
        };
        const toggleFilters = e => {
            displayFilters.value = !displayFilters.value;
        };
        const getTableColumns = () => {
            return [
                {
                    title: $__("Name"),
                    data: "title.publication_title",
                    searchable: false,
                    orderable: false,
                    render: function (data, type, row, meta) {
                        let node =
                            '<a href="/cgi-bin/koha/erm/eholdings/ebsco/resources/' +
                            row.resource_id +
                            '" class="show">' +
                            escape_str(`${row.title.publication_title}`) +
                            "</a>";
                        if (row.is_selected) {
                            node +=
                                " " +
                                '<i class="fa fa-check-square" style="color: green; float: right;" title="' +
                                $__("Is selected") +
                                '" />';
                        }
                        return node;
                    },
                },
                {
                    title: $__("Publication type"),
                    data: "title.publication_type",
                    searchable: false,
                    orderable: false,
                    render: function (data, type, row, meta) {
                        return escape_str(
                            get_lib_from_av(
                                "av_title_publication_types",
                                row.title.publication_type
                            )
                        );
                    },
                },
            ];
        };

        const tableOptions = ref({
            columns: getTableColumns(),
            url:
                "/api/v1/erm/eholdings/ebsco/packages/" +
                props.package_id +
                "/resources",
            options: {
                embed: "title",
                ordering: false,
                dom: '<"top pager"<"table_entries"ilp>>tr<"bottom pager"ip>',
                lengthMenu: [
                    [10, 20, 50, 100],
                    [10, 20, 50, 100],
                ],
            },
            filters_options: {
                publication_type: () =>
                    map_av_dt_filter("av_title_publication_types"),
            },
            actions: { 0: ["show"] },
            default_filters: {
                publication_title: function () {
                    return filters.publication_title.value || "";
                },
                publication_type: function () {
                    return filters.publication_type.value || "";
                },
                selection_type: function () {
                    return filters.selection_type.value || "";
                },
            },
        });
        const displayFilters = ref(false);

        return {
            get_lib_from_av,
            escape_str,
            map_av_dt_filter,
            table,
            tableOptions,
            displayFilters,
            filters,
            doShow,
            filterTable,
            toggleFilters,
            authorisedValues,
        };
    },
    props: {
        package_id: String,
    },
    components: { KohaTable },
    name: "EHoldingsEBSCOPackageTitlesList",
};
</script>

<style scoped>
#filters {
    margin: 0;
}
</style>
