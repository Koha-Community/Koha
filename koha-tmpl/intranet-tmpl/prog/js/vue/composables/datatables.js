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

export function build_url_params(filters) {
    return Object.entries(filters)
        .map(([k, v]) => (v ? k + "=" + v : undefined))
        .filter((e) => e !== undefined)
        .join("&");
}
export function build_url(base_url, filters) {
    let params = build_url_params(filters);
    return base_url + (params.length ? "?" + params : "");
}
