<template>
    <div
        v-if="visible"
        class="modal modal-lg show d-block"
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
                        {{
                            $__(
                                "Please confirm bundle contents for %s"
                            ).replace("%s", barcode)
                        }}
                    </h1>
                </div>
                <div class="modal-body">
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
                        <div class="help-block">
                            {{
                                $__(
                                    "Scan all barcodes of items found in the bundle. Missing items will be marked as lost."
                                )
                            }}
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button
                        type="button"
                        class="btn btn-primary"
                        @click="
                            $emit('confirm', {
                                verify: true,
                                scanned: scannedList(),
                            })
                        "
                    >
                        <i class="fa fa-check"></i>
                        {{
                            $__(
                                "Confirm checkin and mark missing items as lost"
                            )
                        }}
                    </button>
                    <button
                        type="button"
                        class="btn btn-default"
                        @click="$emit('confirm', { verify: false })"
                    >
                        <i class="fa fa-check"></i>
                        {{
                            $__(
                                "Confirm checkin without verifying bundle contents"
                            )
                        }}
                    </button>
                    <button
                        type="button"
                        class="btn btn-default"
                        @click="$emit('cancel')"
                    >
                        <i class="fa fa-times"></i>
                        {{ $__("Cancel") }}
                    </button>
                </div>
            </div>
        </div>
    </div>
    <div v-if="visible" class="modal-backdrop show"></div>
</template>

<script>
import { computed, nextTick, onMounted, ref, watch } from "vue";
import { $__ } from "@koha-vue/i18n";
import { APIClient } from "../../../fetch/api-client.js";

export default {
    props: {
        visible: { type: Boolean, default: false },
        itemId: { type: Number, default: null },
        barcode: { type: String, default: "" },
    },
    emits: ["confirm", "cancel"],
    setup(props) {
        const bundleItems = ref([]);
        const scannedBarcodes = ref("");
        const verifiedBarcodes = ref(new Set());
        const barcodeTextarea = ref(null);

        // Fetch bundle items when visible
        watch(
            () => props.visible,
            async visible => {
                if (visible && props.itemId) {
                    try {
                        const items = await APIClient.item.bundled_items.getAll(
                            props.itemId
                        );
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
                    // Focus textarea
                    nextTick(() => {
                        if (barcodeTextarea.value)
                            barcodeTextarea.value.focus();
                    });
                }
            }
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

        return {
            bundleItems,
            scannedBarcodes,
            verifiedBarcodes,
            barcodeTextarea,
            onBarcodeInput,
            scannedList,
        };
    },
};
</script>
