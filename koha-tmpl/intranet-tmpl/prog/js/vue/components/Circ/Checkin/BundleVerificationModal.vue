<template>
    <div
        v-if="item"
        class="modal modal-lg show d-block audio-alert-action"
        tabindex="-1"
        role="dialog"
        aria-modal="true"
        aria-labelledby="checkin-bundle-verification-title"
        data-bs-backdrop="static"
    >
        <div class="modal-dialog modal-xl">
            <div class="modal-content">
                <div class="modal-header">
                    <h1
                        id="checkin-bundle-verification-title"
                        class="modal-title"
                    >
                        {{ $__("Please confirm bundle contents") }}
                    </h1>
                </div>
                <div class="modal-body">
                    <!-- The bundle being checked in -->
                    <p class="bundle-host">
                        <a
                            v-if="biblioId"
                            :href="`/cgi-bin/koha/catalogue/detail.pl?biblionumber=${biblioId}`"
                            >{{ barcode }}: {{ title }}</a
                        >
                        <span v-else>{{ barcode }}</span>
                    </p>

                    <!-- CircConfirmItemParts: note about the accompanying materials -->
                    <div
                        v-if="item._confirms && item._confirms.item_parts"
                        class="alert alert-info"
                    >
                        {{ item._confirms.item_parts }}
                    </div>

                    <div class="alert alert-info">
                        {{
                            $__(
                                "Scan all barcodes of items found in the bundle. Missing items will be marked as lost."
                            )
                        }}
                    </div>

                    <div
                        class="d-flex justify-content-between align-items-center mb-1"
                    >
                        <h2 class="h6 mb-0">
                            {{ $__("Expected items") }}
                        </h2>
                        <div class="btn-group" role="group">
                            <button
                                type="button"
                                class="btn btn-default btn-xs dropdown-toggle"
                                aria-haspopup="true"
                                :aria-expanded="showExport ? 'true' : 'false'"
                                @click="showExport = !showExport"
                            >
                                <i
                                    class="fa fa-download"
                                    aria-hidden="true"
                                ></i>
                                {{ $__("Export") }}
                            </button>
                            <ul
                                class="dropdown-menu dropdown-menu-end"
                                data-bs-popper="static"
                                :class="{ show: showExport }"
                            >
                                <li>
                                    <button
                                        type="button"
                                        class="dropdown-item bundle-export-copy"
                                        @click="exportAs('copy')"
                                    >
                                        {{ $__("Copy") }}
                                    </button>
                                </li>
                                <li>
                                    <button
                                        type="button"
                                        class="dropdown-item bundle-export-csv"
                                        @click="exportAs('csv')"
                                    >
                                        {{ $__("CSV") }}
                                    </button>
                                </li>
                                <li>
                                    <button
                                        type="button"
                                        class="dropdown-item bundle-export-print"
                                        @click="exportAs('print')"
                                    >
                                        {{ $__("Print") }}
                                    </button>
                                </li>
                            </ul>
                        </div>
                    </div>
                    <table class="table table-condensed table-bordered">
                        <thead>
                            <tr>
                                <th>{{ $__("Title") }}</th>
                                <th>{{ $__("Author") }}</th>
                                <th>{{ $__("Item type") }}</th>
                                <th>{{ $__("Barcode") }}</th>
                                <th>{{ $__("Status") }}</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr
                                v-for="bi in bundleItems"
                                :key="bi.item_id"
                                :class="{
                                    'table-success': verifiedBarcodes.has(
                                        bi.external_id
                                    ),
                                }"
                            >
                                <td>{{ bi.biblio_title }}</td>
                                <td>{{ bi.biblio_author }}</td>
                                <td>{{ bi.item_type_id }}</td>
                                <td>{{ bi.external_id }}</td>
                                <td>
                                    <span
                                        v-if="
                                            verifiedBarcodes.has(bi.external_id)
                                        "
                                        class="text-success"
                                    >
                                        <i class="fa fa-check"></i>
                                        {{ $__("Verified") }}
                                    </span>
                                    <span
                                        v-else-if="bi.lost_status"
                                        class="text-danger"
                                    >
                                        <i class="fa fa-exclamation-circle"></i>
                                        {{ $__("Lost") }}
                                    </span>
                                    <span v-else class="text-muted">
                                        {{ $__("Not verified") }}
                                    </span>
                                </td>
                            </tr>
                        </tbody>
                    </table>

                    <div class="form-group">
                        <label for="bundle-barcodes">
                            {{ $__("Barcodes") }}
                            <span
                                v-if="verifiedBarcodes.size"
                                id="verify-progress"
                            >
                                {{
                                    $__("%s of %s verified")
                                        .replace("%s", verifiedBarcodes.size)
                                        .replace("%s", bundleItems.length)
                                }}
                            </span>
                        </label>
                        <textarea
                            id="bundle-barcodes"
                            ref="barcodeTextarea"
                            v-model="scannedBarcodes"
                            class="form-control"
                            rows="3"
                            :placeholder="
                                $__(
                                    'Scan barcodes of items found in the bundle'
                                )
                            "
                            @input="onBarcodeInput"
                        ></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button
                        type="button"
                        class="btn btn-primary approve"
                        accesskey="y"
                        @click="
                            $emit('confirm', {
                                verify: true,
                                scanned: scannedList(),
                            })
                        "
                    >
                        <i class="fa fa-check"></i>
                        {{ $__("Check in, mark missing lost (Y)") }}
                    </button>
                    <button
                        type="button"
                        class="btn btn-default"
                        accesskey="l"
                        @click="$emit('confirm', { verify: false })"
                    >
                        <i class="fa-regular fa-clock"></i>
                        {{ $__("Check in, verify later (L)") }}
                    </button>
                    <button
                        type="button"
                        class="btn btn-default deny"
                        accesskey="x"
                        @click="$emit('cancel')"
                    >
                        <i class="fa fa-times"></i>
                        {{ $__("Cancel (X)") }}
                    </button>
                </div>
            </div>
        </div>
    </div>
    <div v-if="item" class="modal-backdrop show"></div>
</template>

<script>
import { computed, nextTick, ref, watch } from "vue";
import { $__ } from "@koha-vue/i18n";
import { APIClient } from "../../../fetch/api-client.js";
import { copyTable, downloadCsv, printTable } from "./table-export.js";

export default {
    props: {
        // The check-in waiting for its confirmation, for the bundle
        item: { type: Object, default: null },
    },
    emits: ["confirm", "cancel"],
    setup(props) {
        const bundleItems = ref([]);
        const scannedBarcodes = ref("");
        const verifiedBarcodes = ref(new Set());
        const barcodeTextarea = ref(null);
        const showExport = ref(false);

        const barcode = computed(
            () => props.item?._barcode || props.item?.item?.external_id || ""
        );
        const biblioId = computed(
            () => props.item?.item?.biblio?.biblio_id || null
        );
        const title = computed(() => props.item?.item?.biblio?.title || "");

        // Fetch the bundle items when a bundle is to be confirmed
        watch(
            () => props.item,
            async item => {
                scannedBarcodes.value = "";
                verifiedBarcodes.value = new Set();
                showExport.value = false;
                const itemId = item?.item?.item_id;
                if (!itemId) {
                    bundleItems.value = [];
                    return;
                }
                try {
                    const items =
                        await APIClient.item.bundled_items.getAll(itemId);
                    bundleItems.value = items.map(i => ({
                        item_id: i.item_id,
                        external_id: i.external_id,
                        item_type_id: i.item_type_id,
                        lost_status: i.lost_status,
                        biblio_title: i.biblio?.title || "",
                        biblio_author: i.biblio?.author || "",
                    }));
                } catch (e) {
                    bundleItems.value = [];
                }
                nextTick(() => {
                    if (barcodeTextarea.value) barcodeTextarea.value.focus();
                });
            },
            { immediate: true }
        );

        // All scanned barcodes, including unexpected ones: the server removes
        // items that are not part of this bundle from their bundle
        function scannedList() {
            return [
                ...new Set(
                    scannedBarcodes.value.split(/[\n\r\t\s]+/).filter(Boolean)
                ),
            ];
        }

        function onBarcodeInput() {
            const barcodes = scannedList();
            const expectedBarcodes = new Set(
                bundleItems.value.map(i => i.external_id)
            );
            const verified = new Set();
            for (const bc of barcodes) {
                if (expectedBarcodes.has(bc)) {
                    verified.add(bc);
                }
            }
            verifiedBarcodes.value = verified;
        }

        // The export has the columns of the table, without the status
        function exportAs(format) {
            showExport.value = false;
            const headers = [
                $__("Title"),
                $__("Author"),
                $__("Item type"),
                $__("Barcode"),
            ];
            const rows = bundleItems.value.map(i => [
                i.biblio_title,
                i.biblio_author,
                i.item_type_id,
                i.external_id,
            ]);
            if (format === "csv") {
                downloadCsv(`bundle-${barcode.value}.csv`, headers, rows);
            } else if (format === "print") {
                printTable({
                    title: $__("Contents of bundle %s").replace(
                        "%s",
                        () => barcode.value
                    ),
                    headers,
                    rows,
                });
            } else {
                copyTable(headers, rows);
            }
        }

        return {
            barcode,
            biblioId,
            title,
            bundleItems,
            scannedBarcodes,
            verifiedBarcodes,
            barcodeTextarea,
            showExport,
            onBarcodeInput,
            scannedList,
            exportAs,
        };
    },
};
</script>
