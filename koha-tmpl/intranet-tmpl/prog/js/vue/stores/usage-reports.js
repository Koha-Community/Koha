import { defineStore } from "pinia";
import { reactive, toRefs } from "vue";

export const useReportsStore = defineStore("reports", () => {
    const store = reactive({
        months_data: [
            { short: "Jan", description: "January", value: 1, active: true },
            { short: "Feb", description: "February", value: 2, active: true },
            { short: "Mar", description: "March", value: 3, active: true },
            { short: "Apr", description: "April", value: 4, active: true },
            { short: "May", description: "May", value: 5, active: true },
            { short: "Jun", description: "June", value: 6, active: true },
            { short: "Jul", description: "July", value: 7, active: true },
            { short: "Aug", description: "August", value: 8, active: true },
            { short: "Sep", description: "September", value: 9, active: true },
            { short: "Oct", description: "October", value: 10, active: true },
            { short: "Nov", description: "November", value: 11, active: true },
            { short: "Dec", description: "December", value: 12, active: true },
        ],
        query: null,
        title_property_column_options: {
            1: {
                id: 1,
                name: "Provider name",
                active: true,
                used_by: ["title", "item", "database", "platform"],
                column: {
                    title: __("Data provider"),
                    data: "provider_name",
                    searchable: true,
                    orderable: true,
                },
            },
            2: {
                id: 2,
                name: "Publisher",
                active: false,
                used_by: ["title", "item", "database"],
                column: {
                    title: __("Publisher"),
                    data: "publisher",
                    searchable: true,
                    orderable: true,
                },
            },
            3: {
                id: 3,
                name: "Platform",
                active: false,
                used_by: ["item", "database", "platform"],
                column: {
                    title: __("Platform"),
                    data: "platform",
                    searchable: true,
                    orderable: true,
                },
            },
            4: {
                id: 4,
                name: "Publisher ID",
                active: false,
                used_by: ["title", "database"],
                column: {
                    title: __("Publisher ID"),
                    data: "publisher_id",
                    searchable: true,
                    orderable: true,
                },
            },
            5: {
                id: 5,
                name: "Online ISSN",
                active: false,
                used_by: ["title"],
                column: {
                    title: __("Online ISSN"),
                    data: "online_issn",
                    searchable: true,
                    orderable: true,
                },
            },
            6: {
                id: 6,
                name: "Print ISSN",
                active: false,
                used_by: ["title"],
                column: {
                    title: __("Print ISSN"),
                    data: "print_issn",
                    searchable: true,
                    orderable: true,
                },
            },
            7: {
                id: 7,
                name: "DOI",
                active: false,
                used_by: ["title"],
                column: {
                    title: __("DOI"),
                    data: "title_doi",
                    searchable: true,
                    orderable: true,
                },
            },
            8: {
                id: 8,
                name: "URI",
                active: false,
                used_by: ["title"],
                column: {
                    title: __("URI"),
                    data: "title_uri",
                    searchable: true,
                    orderable: true,
                },
            },
        },
        report_type_map: {
            TR_B1: ["YOP", "ISBN"],
            TR_B2: ["YOP", "ISBN"],
            TR_B3: ["YOP", "Access_Type", "ISBN"],
            TR_J3: ["Access_Type"],
            TR_J4: ["YOP"],
        },
    });
    const actions = {
        getMonthsData() {
            return this.months_data;
        },
        getColumnOptions() {
            return this.title_property_column_options;
        },
        checkReportColumns(report_type, column) {
            if (!this.report_type_map.hasOwnProperty(report_type)) return false;
            return this.report_type_map[report_type].includes(column);
        },
    };

    return { ...toRefs(store), ...actions };
});
