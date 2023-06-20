import { defineStore } from "pinia";

export const useReportsStore = defineStore('reports', {
    state: () => ({
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
                column: {
                    title: __("Publisher"),
                    data: "publisher",
                    searchable: true,
                    orderable: true,
                },
            },
            3: {
                id: 3,
                name: "Publisher ID",
                active: false,
                column: {
                    title: __("Publisher ID"),
                    data: "publisher_id",
                    searchable: true,
                    orderable: true,
                },
            },
            4: {
                id: 4,
                name: "Online ISSN",
                active: false,
                column: {
                    title: __("Online ISSN"),
                    data: "online_issn",
                    searchable: true,
                    orderable: true,
                },
            },
            5: {
                id: 5,
                name: "Print ISSN",
                active: false,
                column: {
                    title: __("Print ISSN"),
                    data: "print_issn",
                    searchable: true,
                    orderable: true,
                },
            },
            6: {
                id: 6,
                name: "DOI",
                active: false,
                column: {
                    title: __("DOI"),
                    data: "title_doi",
                    searchable: true,
                    orderable: true,
                },
            },
            7: {
                id: 7,
                name: "URI",
                active: false,
                column: {
                    title: __("URI"),
                    data: "title_uri",
                    searchable: true,
                    orderable: true,
                },
            },
        },
    }),
    actions: {
        getMonthsData() {
            return this.months_data
        },
        getColumnOptions() {
            return this.title_property_column_options
        }
    }
})