import { defineStore } from "pinia";

export const useReportsStore = defineStore('reports', {
    state: () => ({
        report_url: null,
        time_period_columns: null,
        report_type: null,
        columns: null,
        yearly_filter: null,
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
        query: null
    }),
    actions: {
        setReportURL(url) {
            this.report_url = url
        },
        setTimePeriodColumns(time_period_columns) {
            this.time_period_columns = time_period_columns
        },
        setReportType(report_type) {
            this.report_type = report_type
        },
        setColumns(columns) {
            this.columns = columns
        },
        setYearlyFilter(value) {
            this.yearly_filter = value
        },
        setQuery(query) {
            this.query = query
        },
        getColumns() {
            return this.columns
        },
        getReportURL() {
            return this.report_url
        },
        getTimePeriodColumns() {
            return this.time_period_columns
        },
        getReportType() {
            return this.report_type
        },
        getYearlyFilter() {
            return this.yearly_filter
        },
        getMonthsData() {
            return this.months_data
        },
        getQuery() {
            return this.query
        },
    }
})