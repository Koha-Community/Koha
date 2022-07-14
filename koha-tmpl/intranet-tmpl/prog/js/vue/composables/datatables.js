import { onBeforeUnmount } from "vue";

export function useDataTable(table_id) {
    onBeforeUnmount(() => {
        if ($.fn.DataTable.isDataTable("#" + table_id)) {
            $("#" + table_id)
                .DataTable()
                .destroy(true);
        }
    });
}
