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

        const table_id = "vendor_contracts_table";
        useDataTable(table_id);

        return {
            isUserPermitted,
            table_id,
            escape_str,
        };
    },
    methods: {
        buildDatatable() {
            let contracts = this.vendor.contracts;
            let table_id = this.table_id;
            let isUserPermitted = this.isUserPermitted;

            $.fn.dataTable.ext.search = $.fn.dataTable.ext.search.filter(
                search => search.name != "apply_filter"
            );
            $("#" + table_id).dataTable(
                $.extend(true, {}, dataTablesDefaults, {
                    data: contracts,
                    embed: [],
                    ordering: false,
                    dom: '<"top pager"<"table_entries"ilp>>tr<"bottom pager"ip>',
                    aLengthMenu: [
                        [10, 20, 50, 100],
                        [10, 20, 50, 100],
                    ],
                    autoWidth: false,
                    columns: [
                        {
                            title: __("Name"),
                            data: "contractname",
                            searchable: false,
                            orderable: false,
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
                            searchable: false,
                            orderable: false,
                        },
                        {
                            title: __("Start date"),
                            data: "contractstartdate",
                            searchable: false,
                            orderable: false,
                        },
                        {
                            title: __("End date"),
                            data: "contractenddate",
                            searchable: false,
                            orderable: false,
                        },
                        ...(isUserPermitted(
                            "CAN_user_acquisition_contracts_manage"
                        )
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
                })
            );
        },
    },
    mounted() {
        this.buildDatatable();
    },
};
</script>

<style></style>
