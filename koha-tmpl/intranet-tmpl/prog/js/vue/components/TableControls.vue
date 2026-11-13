<template>
    <div
        class="koha-table-controls"
        role="toolbar"
        :aria-label="$__('Table controls')"
    >
        <div v-if="columns.length" class="koha-table-control">
            <button
                type="button"
                class="koha-table-button columns_controls"
                :title="$__('Columns settings')"
                aria-haspopup="true"
                :aria-expanded="open === 'columns' ? 'true' : 'false'"
                @click="toggle('columns')"
            >
                <i class="fa fa-lg fa-gear" aria-hidden="true"></i>
                <span class="koha-table-button-text">{{ $__("Columns") }}</span>
            </button>
            <ul v-if="open === 'columns'" class="koha-table-menu columns-menu">
                <li v-for="col in columns" :key="col.name">
                    <button
                        type="button"
                        class="koha-table-menu-item column-toggle"
                        :data-colname="col.name"
                        :aria-pressed="isVisible(col.name) ? 'true' : 'false'"
                        @click="
                            $emit(
                                'toggle-column',
                                col.name,
                                !isVisible(col.name)
                            )
                        "
                    >
                        <span>{{ col.label }}</span>
                        <i
                            v-if="isVisible(col.name)"
                            class="fa fa-check"
                            aria-hidden="true"
                        ></i>
                    </button>
                </li>
            </ul>
        </div>

        <div v-if="exportData" class="koha-table-control">
            <button
                type="button"
                class="koha-table-button export_controls"
                :title="$__('Export or print')"
                aria-haspopup="true"
                :aria-expanded="open === 'export' ? 'true' : 'false'"
                @click="toggle('export')"
            >
                <i class="fa fa-lg fa-download" aria-hidden="true"></i>
                <span class="koha-table-button-text">{{ $__("Export") }}</span>
            </button>
            <ul v-if="open === 'export'" class="koha-table-menu export-menu">
                <li>
                    <button
                        type="button"
                        class="koha-table-menu-item export-csv"
                        @click="exportAs('csv')"
                    >
                        <i class="fa fa-table" aria-hidden="true"></i>
                        {{ $__("CSV") }}
                    </button>
                </li>
                <li>
                    <button
                        type="button"
                        class="koha-table-menu-item export-copy"
                        @click="exportAs('copy')"
                    >
                        <i class="fa fa-copy" aria-hidden="true"></i>
                        {{ $__("Copy") }}
                    </button>
                </li>
                <li>
                    <button
                        type="button"
                        class="koha-table-menu-item export-print"
                        @click="exportAs('print')"
                    >
                        <i class="fa fa-print" aria-hidden="true"></i>
                        {{ $__("Print") }}
                    </button>
                </li>
            </ul>
        </div>

        <a
            v-if="configureUrl"
            class="koha-table-button dt_button_configure_table"
            :title="$__('Configure table')"
            :href="configureUrl"
        >
            <i class="fa fa-lg fa-wrench" aria-hidden="true"></i>
            <span class="koha-table-button-text">{{ $__("Configure") }}</span>
        </a>
    </div>
</template>

<script>
/**
 * The Columns, Export and Configure menu of the tables, for tables that
 * Vue renders itself (KohaTable has its own, from the DataTables buttons).
 * Each control is there when what it needs is given:
 *
 * - Columns: `columns` ([{ name, label }]), `isVisible(name)`, and the
 *   `toggle-column` event (name, visible) to act on
 * - Export: `exportData`, a function that returns { headers, rows } as the
 *   table is shown. Copy, CSV and Print are done here
 * - Configure: `configure` ({ module, page, table }); the link is only there
 *   for who can configure the columns
 */
import { computed, onBeforeUnmount, onMounted, ref } from "vue";
import { copyTable, downloadCsv, printTable } from "../utils/table-export.js";

export default {
    name: "TableControls",
    props: {
        columns: { type: Array, default: () => [] },
        isVisible: { type: Function, default: () => true },
        exportData: { type: Function, default: null },
        exportName: { type: String, default: "table" },
        exportTitle: { type: String, default: "" },
        configure: { type: Object, default: null },
    },
    emits: ["toggle-column"],
    setup(props) {
        const open = ref(null);

        const configureUrl = computed(() => {
            const c = props.configure;
            const allowed =
                typeof CAN_user_parameters_manage_column_config !==
                    "undefined" && !!CAN_user_parameters_manage_column_config;
            if (!c || !allowed) return null;
            return `/cgi-bin/koha/admin/columns_settings.pl?module=${encodeURIComponent(c.module)}&page=${encodeURIComponent(c.page)}&table=${encodeURIComponent(c.table)}`;
        });

        function toggle(which) {
            open.value = open.value === which ? null : which;
        }

        function closeMenus(e) {
            if (!e.target.closest?.(".koha-table-control")) open.value = null;
        }
        onMounted(() => document.addEventListener("click", closeMenus));
        onBeforeUnmount(() =>
            document.removeEventListener("click", closeMenus)
        );

        function exportAs(format) {
            open.value = null;
            const { headers, rows } = props.exportData();
            if (format === "csv") {
                downloadCsv(`${props.exportName}.csv`, headers, rows);
            } else if (format === "print") {
                printTable({
                    title: props.exportTitle || props.exportName,
                    headers,
                    rows,
                });
            } else {
                copyTable(headers, rows);
            }
        }

        return { open, configureUrl, toggle, exportAs };
    },
};
</script>

<style>
/* As the buttons of the DataTables of the other pages: on the right,
   without outlines until hovered */
.koha-table-controls {
    display: flex;
    flex-wrap: wrap;
    justify-content: flex-end;
}

.koha-table-control {
    position: relative;
}

.koha-table-button {
    background: transparent none;
    border: 1px solid transparent;
    color: inherit;
    cursor: pointer;
    font-size: 0.9rem;
    padding: 0.5rem 1rem;
    text-decoration: none;
}

.koha-table-button:hover,
.koha-table-button:focus-visible,
.koha-table-button[aria-expanded="true"] {
    background: #eee none;
    border-color: #666;
    color: inherit;
    text-decoration: none;
}

.koha-table-button .fa {
    margin-right: 0.25rem;
}

@media only screen and (min-width: 950px) and (max-width: 1525px) {
    .koha-table-button-text {
        display: none;
    }
}

.koha-table-menu {
    background: #fff;
    border: 1px solid #ccc;
    box-shadow: 0 2px 6px rgba(0, 0, 0, 0.2);
    list-style: none;
    margin: 0;
    min-width: 12rem;
    padding: 0.25rem 0;
    position: absolute;
    right: 0;
    top: 100%;
    z-index: 1000;
}

.koha-table-menu-item {
    align-items: center;
    background: #fff none;
    border: 0;
    cursor: pointer;
    display: flex;
    gap: 0.5rem;
    justify-content: space-between;
    padding: 0.4rem 0.9rem;
    text-align: left;
    width: 100%;
}

.koha-table-menu-item:hover,
.koha-table-menu-item:focus-visible {
    background: #eee none;
}

.export-menu .koha-table-menu-item {
    font-size: 1.1em;
    justify-content: flex-start;
}

.export-menu .koha-table-menu-item .fa {
    color: #00829a;
    width: 1em;
}

.columns-menu .koha-table-menu-item .fa-check {
    color: #006100;
}
</style>
