<template>
    <TableControls
        v-if="checkins.length"
        :columns="columnList"
        :is-visible="isColumnVisible"
        :export-data="tableData"
        export-name="checked-in-items"
        :export-title="$__('Checked-in items')"
        :configure="{
            module: 'circ',
            page: 'returns',
            table: 'checkedintable',
        }"
        @toggle-column="setColumnVisible"
    />
    <table
        v-if="checkins.length"
        ref="tableEl"
        class="table table-striped"
        id="checkins-table"
    >
        <thead>
            <tr>
                <th v-if="isColumnVisible('due_date')">
                    {{ $__("Due date") }}
                </th>
                <th v-if="isColumnVisible('title')">
                    {{ $__("Title") }}
                </th>
                <th v-if="isColumnVisible('author')">
                    {{ $__("Author") }}
                </th>
                <th v-if="isColumnVisible('barcode')">
                    {{ $__("Barcode") }}
                </th>
                <th v-if="isColumnVisible('homelibrary')">
                    {{ $__("Home library") }}
                </th>
                <th v-if="isColumnVisible('transferlibrary')">
                    {{ $__("Transfer to") }}
                </th>
                <th v-if="isColumnVisible('transferreason')">
                    {{ $__("Transfer reason") }}
                </th>
                <th v-if="isColumnVisible('location')">
                    {{ $__("Shelving location") }}
                </th>
                <th v-if="isColumnVisible('itemcallnumber')">
                    {{ $__("Call number") }}
                </th>
                <th v-if="isColumnVisible('dateaccessioned')">
                    {{ $__("Date acquired") }}
                </th>
                <th v-if="isColumnVisible('record_type')">
                    {{ $__("Record-level itemtype") }}
                </th>
                <th v-if="isColumnVisible('itype')">
                    {{ $__("Item type") }}
                </th>
                <th v-if="isColumnVisible('ccode')">
                    {{ $__("Collection") }}
                </th>
                <th v-if="isColumnVisible('borrower')">
                    {{ $__("Patron") }}
                </th>
                <th v-if="isColumnVisible('itemnote')">
                    {{ $__("Note") }}
                </th>
                <th>{{ $__("Status / Messages") }}</th>
            </tr>
        </thead>
        <tbody>
            <tr
                v-for="(checkin, index) in checkins"
                :key="checkin._key"
                :class="rowClass(checkin)"
            >
                <!-- Due date -->
                <td
                    v-if="isColumnVisible('due_date')"
                    v-html="formatDueDate(checkin)"
                ></td>

                <!-- Title -->
                <td v-if="isColumnVisible('title')">
                    <a
                        v-if="checkin.item && checkin.item.biblio"
                        :href="`/cgi-bin/koha/catalogue/detail.pl?biblionumber=${checkin.item.biblio.biblio_id}`"
                    >
                        {{ checkin.item.biblio.title }}
                    </a>
                    <span v-else>&mdash;</span>
                </td>

                <!-- Author -->
                <td v-if="isColumnVisible('author')">
                    {{
                        checkin.item && checkin.item.biblio
                            ? checkin.item.biblio.author
                            : ""
                    }}
                </td>

                <!-- Barcode -->
                <td v-if="isColumnVisible('barcode')">
                    <a
                        v-if="checkin.item && checkin.item.biblio"
                        :href="`/cgi-bin/koha/catalogue/moredetail.pl?biblionumber=${checkin.item.biblio.biblio_id}&itemnumber=${checkin.item.item_id}#item${checkin.item.item_id}`"
                        >{{ checkin.item.external_id }}</a
                    >
                    <span v-else>{{
                        checkin.item
                            ? checkin.item.external_id
                            : checkin._barcode || ""
                    }}</span>
                </td>

                <!-- Home library -->
                <td v-if="isColumnVisible('homelibrary')">
                    {{
                        checkin.item
                            ? libraryName(checkin.item.home_library_id)
                            : ""
                    }}
                </td>

                <!-- Transfer to -->
                <td v-if="isColumnVisible('transferlibrary')">
                    {{ transferToLibrary(checkin) }}
                </td>

                <!-- Transfer reason -->
                <td v-if="isColumnVisible('transferreason')">
                    {{ transferReason(checkin) }}
                </td>

                <!-- Shelving location -->
                <td v-if="isColumnVisible('location')">
                    {{ itemString(checkin, "location") }}
                </td>

                <!-- Call number -->
                <td v-if="isColumnVisible('itemcallnumber')">
                    {{ checkin.item ? checkin.item.callnumber || "" : "" }}
                </td>

                <!-- Date acquired -->
                <td v-if="isColumnVisible('dateaccessioned')">
                    {{
                        checkin.item && checkin.item.acquisition_date
                            ? formatDate(checkin.item.acquisition_date)
                            : ""
                    }}
                </td>

                <!-- Record-level itemtype -->
                <td v-if="isColumnVisible('record_type')">
                    {{
                        checkin.item && checkin.item.biblio
                            ? checkin.item.biblio.item_type_id || ""
                            : ""
                    }}
                </td>

                <!-- Item type -->
                <td v-if="isColumnVisible('itype')">
                    {{ itemString(checkin, "item_type_id") }}
                </td>

                <!-- Collection -->
                <td v-if="isColumnVisible('ccode')">
                    {{ itemString(checkin, "collection_code") }}
                </td>

                <!-- Patron -->
                <td v-if="isColumnVisible('borrower')">
                    <template v-if="!isAnonymized(checkin)">
                        <span
                            v-if="patronDisplay(checkin)"
                            v-html="patronDisplay(checkin)"
                        ></span>
                        <span
                            v-if="checkin.checkout?.patron?.checkouts_count"
                            class="results_summary nowrap"
                        >
                            <span class="label">{{ $__("Checkouts:") }}</span>
                            <span class="badge bg-info-subtle">
                                <a
                                    :href="`/cgi-bin/koha/circ/circulation.pl?borrowernumber=${checkin.checkout.patron_id}`"
                                    >{{
                                        checkin.checkout.patron.checkouts_count
                                    }}</a
                                >
                            </span>
                        </span>
                    </template>
                    <button
                        v-if="showPrintSlipButton(checkin)"
                        class="btn btn-xs btn-outline-secondary ms-1"
                        :title="$__('Print checkin slip')"
                        @click="printCheckinSlip(checkin.checkout.patron_id)"
                    >
                        <i class="fa fa-print"></i>
                        {{ $__("Print checkin slip") }}
                    </button>
                </td>

                <!-- Note -->
                <td v-if="isColumnVisible('itemnote')">
                    <p
                        v-if="
                            !isAnonymized(checkin) &&
                            checkin.checkout?.patron?.staff_notes
                        "
                    >
                        <span class="circ-hlt patron-note">
                            {{ checkin.checkout.patron.staff_notes }}
                        </span>
                    </p>
                    <p v-if="checkin.checkout?.note">
                        <span class="circ-hlt checkout-note">
                            {{ $__("Patron note") }}:
                            {{ checkin.checkout.note }}
                        </span>
                    </p>
                    <p v-if="checkin.item?.public_notes">
                        <span class="circ-hlt item-note-public">
                            {{ checkin.item.public_notes }}
                        </span>
                    </p>
                    <p v-if="checkin.item?.internal_notes">
                        <span class="circ-hlt item-note-nonpublic">
                            {{ checkin.item.internal_notes }}
                        </span>
                    </p>
                </td>

                <!-- Status / Messages (always visible) -->
                <td>
                    <!-- Status indicator for pending items -->
                    <span
                        v-if="checkin._status === 'pending_confirmation'"
                        class="badge text-bg-warning"
                    >
                        <i class="fa fa-exclamation-triangle"></i>
                        {{ $__("Not checked in") }}
                    </span>
                    <span
                        v-else-if="checkin._status === 'needs_action'"
                        class="badge text-bg-warning"
                    >
                        <i class="fa fa-hand-paper"></i>
                        {{ actionLabel(checkin) }}
                    </span>
                    <span
                        v-else-if="checkin._status === 'blocked'"
                        class="badge text-bg-danger"
                    >
                        <i class="fa fa-ban"></i>
                        {{ $__("Blocked") }}
                    </span>
                    <span
                        v-else-if="checkin._status === 'dismissed'"
                        class="badge text-bg-secondary"
                    >
                        <i class="fa fa-times"></i>
                        {{ $__("Not checked in") }}
                    </span>

                    <!-- An action that was declined, ignored or cancelled: the
                         row says so, and it can be reopened to decide again -->
                    <template v-if="checkin._declined">
                        <span class="badge text-bg-warning declined-badge">
                            <i class="fa fa-times"></i>
                            {{ declinedLabel(checkin._declined) }}
                        </span>
                        <button
                            type="button"
                            class="btn btn-xs btn-outline-primary ms-1 reopen-action"
                            :title="$__('Decide again')"
                            @click="$emit('reopen', checkin)"
                        >
                            <i class="fa-solid fa-rotate-left"></i>
                            {{ $__("Reopen") }}
                        </button>
                    </template>

                    <!-- Confirmation details for pending items -->
                    <template v-if="checkin._status === 'pending_confirmation'">
                        <span
                            v-if="checkin._confirms.item_parts"
                            class="text-muted ms-2"
                        >
                            {{ $__("Materials:") }}
                            {{ checkin._confirms.item_parts }}
                        </span>
                    </template>

                    <!-- Action details for needs_action items -->
                    <template v-if="checkin._status === 'needs_action'">
                        <span
                            v-if="transferDestination(checkin)"
                            class="text-muted ms-2"
                        >
                            &rarr; {{ transferDestination(checkin) }}
                        </span>
                    </template>

                    <!-- Inline action buttons (visible when no modal is showing for this item) -->
                    <div
                        v-if="
                            checkin._status === 'pending_confirmation' ||
                            checkin._status === 'needs_action'
                        "
                        class="mt-1"
                    >
                        <button
                            v-if="checkin._action_type === 'claim'"
                            class="btn btn-xs btn-outline-primary"
                            :title="$__('Resolve claim')"
                            @click="$emit('resolve-claim', checkin)"
                        >
                            <i class="fa fa-gavel"></i>
                            {{ $__("Resolve claim") }}
                        </button>
                        <button
                            v-else
                            class="btn btn-xs btn-outline-primary"
                            :title="$__('Resolve')"
                            @click="$emit('show-modal', checkin)"
                        >
                            <i class="fa fa-arrow-right"></i>
                            {{ $__("Resolve") }}
                        </button>
                    </div>

                    <!-- Regular messages for successful checkins -->
                    <template v-if="checkin._status === 'success'">
                        <span
                            v-for="msg in displayMessages(checkin)"
                            :key="msg.message"
                            class="badge ms-1"
                            :class="badgeClass(msg)"
                        >
                            {{ formatMessage(msg) }}
                        </span>
                    </template>

                    <!-- Audio alert trigger -->
                    <span
                        v-if="audioAlertClass(checkin) && index === 0"
                        :class="audioAlertClass(checkin)"
                        style="display: none"
                    ></span>
                </td>
            </tr>
        </tbody>
    </table>
    <p v-else class="text-muted">
        {{ $__("No items have been checked in yet.") }}
    </p>
</template>

<script>
import { ref } from "vue";
import TableControls from "../../TableControls.vue";
import { $__ } from "@koha-vue/i18n";
import { printCheckinSlip } from "./slip-printer.js";
import { useCheckinStore } from "../../../stores/checkin.js";

export default {
    components: { TableControls },
    props: {
        checkins: {
            type: Array,
            required: true,
        },
    },
    emits: ["show-modal", "resolve-claim", "reopen"],
    setup() {
        const store = useCheckinStore();

        /**
         * Check if a column is visible based on tableSettings.
         * Columns default to visible if not found in settings.
         */
        const columnList = [
            { name: "due_date", label: $__("Due date") },
            { name: "title", label: $__("Title") },
            { name: "author", label: $__("Author") },
            { name: "barcode", label: $__("Barcode") },
            { name: "homelibrary", label: $__("Home library") },
            { name: "transferlibrary", label: $__("Transfer to") },
            { name: "transferreason", label: $__("Transfer reason") },
            { name: "location", label: $__("Shelving location") },
            { name: "itemcallnumber", label: $__("Call number") },
            { name: "dateaccessioned", label: $__("Date acquired") },
            { name: "record_type", label: $__("Record-level itemtype") },
            { name: "itype", label: $__("Item type") },
            { name: "ccode", label: $__("Collection") },
            { name: "borrower", label: $__("Patron") },
            { name: "itemnote", label: $__("Note") },
        ];

        // The columns the librarian shows or hides for now, over the
        // defaults of the table settings; remembered in this browser
        const STORAGE_KEY = "koha_checkin_columns";
        const overrides = ref({});
        try {
            overrides.value =
                JSON.parse(localStorage.getItem(STORAGE_KEY)) || {};
        } catch (e) {
            overrides.value = {};
        }

        function isColumnVisible(columnname) {
            if (columnname in overrides.value) {
                return !!overrides.value[columnname];
            }
            const columns = store.tableSettings?.columns;
            if (!columns || !Array.isArray(columns)) return true;
            const col = columns.find(c => c.columnname === columnname);
            if (!col) return true;
            return !col.is_hidden || col.is_hidden === "0";
        }

        function setColumnVisible(columnname, visible) {
            overrides.value = { ...overrides.value, [columnname]: visible };
            try {
                localStorage.setItem(
                    STORAGE_KEY,
                    JSON.stringify(overrides.value)
                );
            } catch (e) {
                // Not remembered, still applies to this page
            }
        }

        const tableEl = ref(null);

        // The table as shown: visible columns, without the controls
        function tableData() {
            const table = tableEl.value;
            const text = cell => {
                const node = cell.cloneNode(true);
                node.querySelectorAll(".no-export, button, .btn").forEach(n =>
                    n.remove()
                );
                return node.textContent.replace(/\s+/g, " ").trim();
            };
            const headers = [...table.querySelectorAll("thead th")].map(text);
            const rows = [...table.querySelectorAll("tbody tr")].map(tr =>
                [...tr.children].map(text)
            );
            return { headers, rows };
        }

        function libraryName(branchcode) {
            if (!branchcode) return "";
            return store.libraries[branchcode] || branchcode;
        }

        // Description of a coded item field (from the +strings embed),
        // falling back to the code
        function itemString(checkin, field) {
            const item = checkin.item;
            if (!item) return "";
            return item._strings?.[field]?.str || item[field] || "";
        }

        function formatDueDate(checkin) {
            if (!checkin.checkout || !checkin.checkout.due_date)
                return "\u2014";
            const dueDate = new Date(checkin.checkout.due_date);
            const formatted = $date(checkin.checkout.due_date, {
                as_due_date: true,
            });
            const now = new Date();
            if (dueDate < now) {
                return `<span class="overdue">${formatted} (${$__("overdue")})</span>`;
            }
            return formatted;
        }

        function formatDate(dateStr) {
            if (!dateStr) return "";
            return $date(dateStr);
        }

        function audioAlertClass(checkin) {
            if (!store.policy.global?.audio_alerts) return null;
            if (
                checkin._status === "blocked" ||
                checkin._status === "dismissed"
            ) {
                return "audio-alert-warning";
            }
            if (checkin._status === "success") {
                return "audio-alert-success";
            }
            return null;
        }

        function rowClass(checkin) {
            switch (checkin._status) {
                case "pending_confirmation":
                    return "table-warning";
                case "needs_action":
                    return "table-warning";
                case "blocked":
                    return "table-danger";
                case "dismissed":
                    return "table-secondary";
                default:
                    // Successful checkin - highlight overdue
                    if (checkin.messages?.some(m => m.type === "warning")) {
                        return "table-info";
                    }
                    return "";
            }
        }

        // With privacy "Never" the returned checkout is anonymized: it now
        // belongs to the AnonymousPatron, which must not be shown as the
        // patron who returned the item.
        function isAnonymized(checkin) {
            const anonymous = store.policy.anonymous_patron_id;
            return (
                !!anonymous &&
                String(checkin.checkout?.patron_id) === String(anonymous)
            );
        }

        // Patron link as HTML (escaped by $patron_to_html)
        function patronDisplay(checkin) {
            if (!checkin.checkout?.patron_id) return "";
            // If patron data is embedded
            if (checkin.checkout?.patron) {
                return $patron_to_html(checkin.checkout.patron, {
                    invert_name: true,
                    display_cardnumber: true,
                    url: true,
                });
            }
            return "";
        }

        /**
         * Show print slip button only if:
         * - checkin was successful
         * - checkout and patron data exist
         * - patron privacy is not 2 ("Never") - graceful fallback if not embedded
         */
        function showPrintSlipButton(checkin) {
            if (checkin._status !== "success") return false;
            if (isAnonymized(checkin)) return false;
            if (
                !checkin.checkout ||
                !checkin.checkout.patron_id ||
                !checkin.checkout.patron
            )
                return false;
            const privacy = checkin.checkout.patron.privacy;
            // If privacy data is available and is 2, hide the button
            if (privacy !== undefined && privacy !== null && privacy >= 2)
                return false;
            return true;
        }

        function actionLabel(checkin) {
            switch (checkin._action_type) {
                case "hold":
                    return $__("Hold found");
                case "transfer":
                    return $__("Transfer needed");
                case "recall":
                    return $__("Recall found");
                case "claim":
                    return $__("Claimed returned");
                default:
                    return $__("Action needed");
            }
        }

        function transferDestination(checkin) {
            const msg = (checkin.messages || []).find(
                m =>
                    m.message === "needs_transfer" ||
                    m.message === "transferred" ||
                    m.message === "wrong_transfer"
            );
            return msg?.payload?.to_library || "";
        }

        /**
         * Get transfer-to library name for the Transfer to column.
         */
        function transferToLibrary(checkin) {
            const dest = transferDestination(checkin);
            if (!dest) return "";
            return libraryName(dest);
        }

        /**
         * Get the transfer reason for the Transfer reason column.
         */
        function transferReason(checkin) {
            const msg = (checkin.messages || []).find(
                m =>
                    m.message === "needs_transfer" ||
                    m.message === "transferred" ||
                    m.message === "wrong_transfer"
            );
            if (!msg?.payload?.trigger) return "";
            return formatTransferTrigger(msg.payload.trigger);
        }

        function formatTransferTrigger(trigger) {
            const triggers = {
                Manual: $__("Manual"),
                StockrotationAdvance: $__("Stock rotation advance"),
                StockrotationRepatriation: $__("Stock rotation repatriation"),
                ReturnToHome: $__("Return to home library"),
                ReturnToHolding: $__("Return to holding library"),
                RotatingCollection: $__("Rotating collection"),
                Reserve: $__("Hold"),
                LostReserve: $__("Lost hold"),
                CancelReserve: $__("Cancelled hold"),
                TransferCancellation: $__(
                    "Transfer was cancelled whilst in transit"
                ),
                Recall: $__("Recall"),
                RecallCancellation: $__("Cancelled recall"),
            };
            return triggers[trigger] || trigger;
        }

        function displayMessages(checkin) {
            // Filter out messages that are already shown via action_type
            // was_returned is set on every return, the legacy page never showed it
            const actionMsgs = [
                "hold_found",
                "needs_transfer",
                "wrong_transfer",
                "recall_found",
                "was_returned",
            ];
            return (checkin.messages || []).filter(
                m => !actionMsgs.includes(m.message)
            );
        }

        function badgeClass(msg) {
            if (msg.type === "warning") return "text-bg-warning";
            if (msg.type === "error") return "text-bg-danger";
            return "text-bg-info";
        }

        function formatMessage(msg) {
            const labels = {
                not_issued: $__("Not checked out"),
                local_use: $__("Local use"),
                hold_cancelled: $__("Hold cancelled"),
                was_lost: $__("Was lost"),
                withdrawn: $__("Withdrawn"),
                transferred: $__("Transferred"),
                transfer_arrived: $__("Transfer arrived"),
                debarred: $__("Patron restricted"),
                previously_debarred: $__("Patron was restricted"),
                indefinitely_debarred: $__("Patron restricted indefinitely"),
                lost_item_fee_refunded: $__("Lost fee refunded"),
                lost_item_fee_charged: $__("Lost fee charged"),
                lost_item_fee_restored: $__("Lost fee restored"),
                processing_fee_refunded: $__("Processing fee refunded"),
                return_claim: $__("Claimed returned"),
                claim_auto_resolved: $__("Claim resolved"),
                hold_auto_filled: $__("Hold filled"),
                hold_auto_fill_failed: $__("Hold not filled"),
                not_for_loan_status_updated: $__("Not for loan status updated"),
                not_for_loan_status_notice: $__("Not for loan status"),
                item_location_updated: $__("Shelving location updated"),
                in_bundle: $__("Belongs to a bundle"),
                bundle_missing_items: $__("Bundle had missing items"),
                bundle_unexpected_items: $__("Bundle had unexpected items"),
                item_type_checkinmsg: $__("Item type message"),
            };
            return labels[msg.message] || msg.message.replace(/_/g, " ");
        }

        // What the row says when an action was declined, ignored or cancelled
        function declinedLabel(declined) {
            const labels = {
                transfer: {
                    declined: $__("Transfer declined"),
                    cancelled: $__("Transfer cancelled"),
                    ignored: $__("Transfer left as it is"),
                },
                hold: { ignored: $__("Hold ignored") },
                recall: { ignored: $__("Recall ignored") },
                claim: { ignored: $__("Claim not resolved") },
            };
            return labels[declined.type]?.[declined.kind] || $__("Declined");
        }

        return {
            declinedLabel,
            isColumnVisible,
            setColumnVisible,
            columnList,
            tableData,
            tableEl,
            formatDueDate,
            formatDate,
            itemString,
            audioAlertClass,
            libraryName,
            rowClass,
            patronDisplay,
            isAnonymized,
            showPrintSlipButton,
            actionLabel,
            transferDestination,
            transferToLibrary,
            transferReason,
            displayMessages,
            badgeClass,
            formatMessage,
            printCheckinSlip,
        };
    },
};
</script>

<style scoped>
.btn-xs {
    padding: 0.125rem 0.375rem;
    font-size: 0.75rem;
}
</style>
