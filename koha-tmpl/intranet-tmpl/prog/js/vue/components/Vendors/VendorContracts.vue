<template>
    <h2>{{ $__("Contract(s)") }}</h2>
    <div class="dataTables_wrapper no-footer">
        <table :id="table_id"></table>
    </div>
</template>

<script>
import { inject } from "vue";
import { useDataTable } from "../../composables/datatables";

export default {
    props: {
        vendor: Object,
    },
    setup() {
        const permissionsStore = inject("permissionsStore");
        const { isUserPermitted } = permissionsStore;

        const format_date = $date;

        const table_id = "vendor_contracts_table";
        useDataTable(table_id);

        return {
            isUserPermitted,
            table_id,
            escape_str,
            format_date,
        };
    },
    methods: {
        buildDatatable() {
            let contracts = this.vendor.contracts;
            let table_id = this.table_id;
            let isUserPermitted = this.isUserPermitted;
            let format_date = this.format_date;

            $("#" + table_id).kohaTable({
                data: contracts,
                embed: [],
                dom: '<<"table_entries">>',
                autoWidth: false,
                columns: [
                    {
                        title: __("Name"),
                        data: "contractname",
                        render: function (data, type, row, meta) {
                            return (
                                `<a href="/cgi-bin/koha/admin/aqcontract.pl?op=add_form&booksellerid=${row.booksellerid}&contractnumber=${row.contractnumber}">` +
                                escape_str(row.contractname) +
                                "</a>"
                            );
                        },
                    },
                    {
                        title: __("Description"),
                        data: "contractdescription",
                    },
                    {
                        title: __("Start date"),
                        data: "contractstartdate",
                        render: function (data, type, row, meta) {
                            return type == "sort"
                                ? row.contractstartdate
                                : format_date(row.contractstartdate);
                        },
                    },
                    {
                        title: __("End date"),
                        data: "contractenddate",
                        render: function (data, type, row, meta) {
                            return type == "sort"
                                ? row.contractenddate
                                : format_date(row.contractenddate);
                        },
                    },
                    ...(isUserPermitted("CAN_user_acquisition_contracts_manage")
                        ? [
                              {
                                  title: __("Actions"),
                                  data: "contractnumber",
                                  searchable: false,
                                  orderable: false,
                                  render: function (data, type, row, meta) {
                                      return (
                                          `<a class="btn btn-default btn-xs" href="/cgi-bin/koha/admin/aqcontract.pl?op=add_form&contractnumber=${row.contractnumber}&booksellerid=${row.booksellerid}"><i class="fa-solid fa-pencil" aria-hidden="true"></i>` +
                                          " " +
                                          __("Edit") +
                                          "</a>" +
                                          `<a style="margin-left: 5px;" class="btn btn-default btn-xs" href="/cgi-bin/koha/admin/aqcontract.pl?op=delete_confirm&contractnumber=${row.contractnumber}&booksellerid=${row.booksellerid}"><i class="fa-solid fa-trash-can" aria-hidden="true"></i>` +
                                          " " +
                                          __("Delete") +
                                          "</a>"
                                      );
                                  },
                              },
                          ]
                        : []),
                ],
            });
        },
    },
    mounted() {
        this.buildDatatable();
    },
};
</script>

<style></style>
