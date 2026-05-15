$(document).ready(function () {
    let table = $("#table_readingrec").kohaTable(
        {
            pagingType: "full",
            order: [[column_sort, "desc"]],
        },
        table_settings
    );
    if (table) {
        let table_dt = table.DataTable();
        $("#tabs a[data-bs-toggle='tab']").on("shown.bs.tab", function (e) {
            active_tab = $(this).attr("href");
            let pattern = "";
            if (active_tab == "#tab_checkout_panel") {
                pattern = "standard_checkout";
            } else if (active_tab == "#tab_onsite_checkout_panel") {
                pattern = "onsite_checkout";
            }
            table_dt.columns(0).search(pattern).draw();
        });
    }
});
