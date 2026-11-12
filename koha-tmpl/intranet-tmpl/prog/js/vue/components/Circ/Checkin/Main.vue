<template>
    <div id="checkin-app">
        <div
            v-if="lastError"
            class="alert alert-danger audio-alert-warning"
            role="alert"
        >
            {{ lastError }}
        </div>

        <div class="page-section checkin-card">
            <h1>{{ $__("Check in") }}</h1>

            <BarcodeInput
                ref="barcodeInputRef"
                :disabled="isInputBlocked"
                :dropbox-mode="checkinOptions.dropbox_mode"
                :exempt-fine="checkinOptions.exempt_fine"
                @submit="onBarcodeScan"
                @toggle-options="showOptions = !showOptions"
            />

            <!-- Active settings indicators (visible when panel is collapsed) -->
            <div
                v-if="!showOptions && hasActiveSettings"
                class="checkin-active-settings mt-1"
            >
                <span
                    v-if="checkinOptions.exempt_fine"
                    class="badge text-bg-warning me-1"
                >
                    <i class="fa fa-check"></i> {{ $__("Fines forgiven") }}
                </span>
                <span
                    v-if="checkinOptions.dropbox_mode"
                    class="badge text-bg-warning me-1"
                >
                    <i class="fa fa-check"></i> {{ $__("Book drop mode") }}
                    <span v-if="dropboxDate">
                        ({{
                            $__("Effective checkin date is %s").replace(
                                "%s",
                                dropboxDate
                            )
                        }})
                    </span>
                </span>
                <span
                    v-if="checkinOptions.return_date"
                    class="badge text-bg-warning me-1"
                >
                    <i class="fa fa-check"></i> {{ $__("Return date:") }}
                    {{ formatDateTime(checkinOptions.return_date) }}
                </span>
            </div>

            <CheckinOptions
                v-show="showOptions"
                ref="checkinOptionsRef"
                @update:options="onOptionsUpdate"
            />
        </div>

        <!-- Detailed messages for the last checkin -->
        <div
            v-if="lastCheckinMessages.length"
            class="mt-3"
            @click="onMessagesClick"
        >
            <div
                v-for="msg in lastCheckinMessages"
                :key="msg.message"
                class="alert"
                :class="msg.alertClass"
            >
                <p class="mb-0" v-html="msg.text"></p>
            </div>
        </div>

        <!-- Pending items count indicator -->
        <div
            v-if="pendingItems.length > 1"
            class="alert alert-warning mt-3"
            role="alert"
        >
            <i class="fa fa-exclamation-triangle"></i>
            {{
                $__("%s items require attention").replace(
                    "%s",
                    pendingItems.length
                )
            }}
        </div>

        <div class="mt-3" :class="{ 'page-section': checkins.length }">
            <h2 v-if="checkins.length">{{ $__("Checked-in items") }}</h2>
            <CheckedInItems
                :checkins="checkins"
                @show-modal="showModalFor"
                @resolve-claim="onResolveClaim"
            />
        </div>

        <!-- Confirmation panel - shows one pending item at a time -->
        <ConfirmationModal
            :item="confirmationModalItem"
            :confirming="processing"
            @close="onClose"
            @confirm="onConfirm"
            @dismiss="onDismiss"
            @ignore="onIgnore"
            @resolve="onResolve"
            @resolve-claim="onResolveClaim"
            @open-cancel-hold="onOpenCancelHold"
        />

        <HoldCancellationModal
            :visible="showHoldCancellationModal"
            :hold-group="holdCancellationGroup"
            :cancelling="processing"
            @confirm="onConfirmHoldCancellation"
            @close="showHoldCancellationModal = false"
        />

        <ResolveClaimModal
            :claim-id="activeClaimId"
            :visible="showClaimModal"
            @resolved="onClaimResolved"
            @close="onClaimModalClose"
        />

        <BundleVerificationModal
            :item="bundleModalItem"
            @confirm="onBundleConfirm"
            @cancel="onBundleCancel"
        />
    </div>
</template>

<script>
import {
    computed,
    nextTick,
    onBeforeUnmount,
    onMounted,
    reactive,
    ref,
    watch,
} from "vue";
import { storeToRefs } from "pinia";
import { useCheckinStore } from "../../../stores/checkin.js";
import { APIClient } from "../../../fetch/api-client.js";
import BarcodeInput from "./BarcodeInput.vue";
import CheckedInItems from "./CheckedInItems.vue";
import CheckinOptions from "./CheckinOptions.vue";
import ConfirmationModal from "./ConfirmationModal.vue";
import HoldCancellationModal from "./HoldCancellationModal.vue";
import ResolveClaimModal from "./ResolveClaimModal.vue";
import BundleVerificationModal from "./BundleVerificationModal.vue";
import { printTable } from "./table-export.js";
import { $__ } from "@koha-vue/i18n";
import { printHoldSlip } from "./slip-printer.js";

// Values interpolated into the v-html alert boxes must be escaped
function escapeHtml(value) {
    return String(value ?? "")
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#39;");
}

function formatDate(value) {
    if (!value) return "";
    return typeof $date === "function" ? $date(value) : value;
}

function formatDateTime(value) {
    if (!value) return "";
    return typeof $date === "function"
        ? $date(value, { withtime: true })
        : value;
}

export default {
    components: {
        BarcodeInput,
        CheckedInItems,
        CheckinOptions,
        ConfirmationModal,
        HoldCancellationModal,
        ResolveClaimModal,
        BundleVerificationModal,
    },
    setup() {
        const store = useCheckinStore();
        const {
            checkins,
            processing,
            lastError,
            pendingItems,
            nextModalItem,
            policy,
        } = storeToRefs(store);
        const barcodeInputRef = ref(null);
        const checkinOptionsRef = ref(null);
        const activeModalItem = ref(null);
        const showOptions = ref(false);
        const showClaimModal = ref(false);
        const activeClaimId = ref(null);
        // A bundle to check in is confirmed in its own modal, which also asks
        // for the contents: there is no confirmation before it
        const bundleModalItem = computed(() => {
            const active = activeModalItem.value;
            return active &&
                active._status === "pending_confirmation" &&
                active._confirms?.items_bundle
                ? active
                : null;
        });
        const confirmationModalItem = computed(() =>
            bundleModalItem.value ? null : activeModalItem.value
        );
        const showHoldCancellationModal = ref(false);
        const holdCancellationItem = ref(null);
        const holdCancellationGroup = ref(false);
        // Items removed from their bundle from the "in bundle" alert
        const removedFromBundle = ref(new Set());

        // Effective return date used in book drop mode
        const dropboxDate = computed(() =>
            formatDate(policy.value.dropbox_date)
        );

        const checkinOptions = reactive({
            dropbox_mode: false,
            exempt_fine: false,
            forgive_hold_fees: false,
            return_date: null,
        });

        function onOptionsUpdate(options) {
            Object.assign(checkinOptions, options);
        }

        // Async mode: staff can keep scanning while modals are showing.
        // Items needing attention queue as yellow rows and modals show
        // one at a time. The exception is a transfer modal when
        // TransfersBlockCirc is set: it must be acted on first.
        const isInputBlocked = computed(
            () =>
                activeModalItem.value?._action_type === "transfer" &&
                !!policy.value.transfers_block
        );

        watch(isInputBlocked, blocked => {
            if (!blocked) nextTick(() => refocusInput());
        });

        const hasActiveSettings = computed(
            () =>
                checkinOptions.exempt_fine ||
                checkinOptions.dropbox_mode ||
                checkinOptions.return_date
        );

        // Detailed messages for the most recent checkin (shown as alert boxes)
        const lastCheckinMessages = computed(() => {
            if (!checkins.value.length) return [];
            const latest = checkins.value[0];
            if (latest._status !== "success") return [];
            const messages = latest.messages || [];
            const detailed = [];
            const feeMessages = {
                lost_item_fee_refunded: {
                    text: $__(
                        "A refund for the lost item charge has been applied to the borrowing patron's account."
                    ),
                    alertClass: "alert-info",
                },
                lost_item_fee_charged: {
                    text: $__(
                        "A refund for the lost item charge has been applied to the borrowing patron's account, and new overdue charge has been calculated and applied."
                    ),
                    alertClass: "alert-info",
                },
                lost_item_fee_restored: {
                    text: $__(
                        "A refund for the lost item charge has been applied to the borrowing patron's account and if an overdue fine was forgiven when the item was marked as lost, it has been reverted."
                    ),
                    alertClass: "alert-info",
                },
                lost_item_payment_not_refunded: {
                    text: $__(
                        "The payment for the lost item is older than the refund threshold. No refund applied."
                    ),
                    alertClass: "alert-warning",
                },
                processing_fee_refunded: {
                    text: $__(
                        "A refund for the lost item processing charge has been applied to the borrowing patron's account."
                    ),
                    alertClass: "alert-info",
                },
                lost_item_fee_remains: {
                    text: $__(
                        "Any lost item fees for this item will remain on the patron's account."
                    ),
                    alertClass: "alert-warning",
                },
                processing_fee_remains: {
                    text: $__(
                        "Any processing fees for this item will remain on the patron's account."
                    ),
                    alertClass: "alert-warning",
                },
                was_lost: {
                    text: $__("Item was lost, now found."),
                    alertClass: "alert-info",
                },
                indefinitely_debarred: {
                    text: $__(
                        "Reminder: Patron has an indefinite restriction."
                    ),
                    alertClass: "alert-warning",
                },
            };
            // Only one lost item fee outcome is shown, like the legacy page.
            // A refund can come along with a new overdue charge or a restored
            // fine, whose texts already mention the refund, so they go first.
            const lostFeeOutcomes = [
                "lost_item_fee_charged",
                "lost_item_fee_restored",
                "lost_item_fee_refunded",
                "lost_item_payment_not_refunded",
            ];
            const lostFeeOutcome = lostFeeOutcomes.find(code =>
                messages.some(m => m.message === code)
            );
            // Patron note recorded on the checkout (issues.note)
            if (latest.checkout?.note) {
                detailed.push({
                    text:
                        `<h4>${escapeHtml($__("Patron note"))}</h4>` +
                        (latest.checkout.note_date
                            ? `<p>${escapeHtml(formatDate(latest.checkout.note_date))}</p>`
                            : "") +
                        `<p>${escapeHtml(latest.checkout.note)}</p>`,
                    alertClass: "alert-info issue-note",
                });
            }
            // Restriction end dates, formatted like the legacy page
            const restrictionMessages = {
                debarred: [
                    $__("Patron is now restricted until %s."),
                    $__("Patron is now restricted."),
                ],
                previously_debarred: [
                    $__("Reminder: Patron was earlier restricted until %s."),
                    $__("Reminder: Patron was earlier restricted."),
                ],
            };
            for (const msg of messages) {
                if (restrictionMessages[msg.message]) {
                    const [withDate, withoutDate] =
                        restrictionMessages[msg.message];
                    const until = msg.payload?.until;
                    detailed.push({
                        text: until
                            ? withDate.replace(
                                  "%s",
                                  escapeHtml(formatDate(until))
                              )
                            : withoutDate,
                        alertClass: "alert-warning",
                    });
                }
                if (
                    feeMessages[msg.message] &&
                    (!lostFeeOutcomes.includes(msg.message) ||
                        msg.message === lostFeeOutcome)
                ) {
                    detailed.push(feeMessages[msg.message]);
                }
                if (
                    msg.message === "in_bundle" &&
                    msg.payload &&
                    !removedFromBundle.value.has(latest.checkin_id)
                ) {
                    // The markup is kept out of the translatable strings, and
                    // the values are inserted with a function so '$' sequences
                    // in them are not interpreted by String.replace
                    const bundleLink = `<a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=${encodeURIComponent(msg.payload.host_biblio_id)}">${escapeHtml(msg.payload.host_external_id)}</a>`;
                    const removeButton = `<button type="button" class="btn btn-default btn-xs remove-from-bundle" data-checkin-id="${escapeHtml(latest.checkin_id)}" data-item-id="${escapeHtml(latest.item?.item_id)}" data-host-item-id="${escapeHtml(msg.payload.host_item_id)}"><i class="fa fa-minus" aria-hidden="true"></i> ${escapeHtml($__("Remove from bundle"))}</button>`;
                    detailed.push({
                        text:
                            escapeHtml(
                                $__("This item belongs to a bundle: %s")
                            ).replace("%s", () => bundleLink) +
                            " " +
                            removeButton,
                        alertClass: "alert-warning",
                    });
                }
                if (
                    (msg.message === "bundle_missing_items" ||
                        msg.message === "bundle_unexpected_items") &&
                    msg.payload
                ) {
                    const heading =
                        msg.message === "bundle_missing_items"
                            ? $__(
                                  "Bundle had missing items, they have been marked as lost:"
                              )
                            : $__(
                                  "Bundle had unexpected items, they have been removed from the bundle. Please place them to one side:"
                              );
                    const items = (msg.payload.items || [])
                        .map(
                            i =>
                                `<li>${escapeHtml(i.title)} - ${escapeHtml(i.external_id)}</li>`
                        )
                        .join("");
                    // The list of the missing items can be printed, to look for
                    // them: legacy offered it in a printable modal
                    const printButton =
                        msg.message === "bundle_missing_items"
                            ? `<button type="button" class="btn btn-default btn-xs print-missing-items" data-checkin-id="${escapeHtml(latest.checkin_id)}"><i class="fa fa-print" aria-hidden="true"></i> ${escapeHtml($__("Print list"))}</button>`
                            : "";
                    detailed.push({
                        text: `<strong>${escapeHtml(heading)}</strong><ul>${items}</ul>${printButton}`,
                        alertClass: "alert-warning",
                    });
                }
                if (msg.message === "hold_auto_filled" && msg.payload) {
                    // Already escaped by $patron_to_html
                    const holdPatron = $patron_to_html(latest.hold?.patron, {
                        invert_name: true,
                    });
                    const destination =
                        store.libraries[msg.payload.library_id] ||
                        msg.payload.library_id;
                    const transfer =
                        msg.payload.library_id !== latest.library_id;
                    detailed.push({
                        text:
                            `<strong>${escapeHtml($__("Hold filled for:"))}</strong> ${holdPatron}<br>` +
                            `<strong>${escapeHtml(transfer ? $__("Transfer to:") : $__("Hold at"))}</strong> ${escapeHtml(destination)} ` +
                            `<button type="button" class="btn btn-default btn-xs print-hold-slip" data-reserve-id="${escapeHtml(msg.payload.reserve_id)}"><i class="fa fa-print"></i> ${escapeHtml($__("Print"))}</button>`,
                        alertClass: "alert-info hold-auto-filled",
                    });
                }
                if (msg.message === "hold_auto_fill_failed") {
                    detailed.push({
                        text: escapeHtml(
                            msg.payload?.error_code === "item_checked_out"
                                ? $__(
                                      "The hold could not be filled automatically: the item has been checked out in the meantime. The hold remains pending."
                                  )
                                : $__(
                                      "The hold could not be filled automatically: it no longer exists."
                                  )
                        ),
                        alertClass: "alert-warning hold-auto-fill-failed",
                    });
                }
                if (
                    msg.message === "not_for_loan_status_updated" &&
                    msg.payload
                ) {
                    detailed.push({
                        text: escapeHtml(
                            $__(
                                "Not for loan status updated. Old value: %s. New value: %s."
                            )
                                .replace(
                                    "%s",
                                    notForLoanDescription(msg.payload.from)
                                )
                                .replace(
                                    "%s",
                                    notForLoanDescription(msg.payload.to)
                                )
                        ),
                        alertClass: "alert-warning",
                    });
                }
                if (
                    msg.message === "not_for_loan_status_notice" &&
                    msg.payload
                ) {
                    detailed.push({
                        text: escapeHtml(
                            avDescription("NOT_LOAN", msg.payload.status)
                        ),
                        alertClass: "alert-warning",
                    });
                }
                if (msg.message === "item_location_updated" && msg.payload) {
                    detailed.push({
                        text: escapeHtml(
                            $__(
                                "Item shelving location updated. Old value: %s. New value: %s."
                            )
                                .replace(
                                    "%s",
                                    locationDescription(msg.payload.from)
                                )
                                .replace(
                                    "%s",
                                    locationDescription(msg.payload.to)
                                )
                        ),
                        alertClass: "alert-warning",
                    });
                }
                if (msg.message === "item_type_checkinmsg" && msg.payload) {
                    // Free text from the item type configuration: escape it
                    // and keep its line breaks, like the legacy page did
                    detailed.push({
                        text: escapeHtml(msg.payload.text).replace(
                            /\r?\n/g,
                            "<br>"
                        ),
                        alertClass:
                            msg.type === "alert"
                                ? "alert-warning"
                                : "alert-info",
                    });
                }
                if (msg.message === "patron_has_fines" && msg.payload) {
                    detailed.push({
                        text: $__(
                            'Patron has outstanding fines of %s. <a href="/cgi-bin/koha/members/pay.pl?borrowernumber=%s">Make payment</a>'
                        )
                            .replace("%s", escapeHtml(msg.payload.balance))
                            .replace("%s", escapeHtml(msg.payload.patron_id)),
                        alertClass: "alert-warning",
                    });
                }
                if (msg.message === "patron_has_waiting_holds" && msg.payload) {
                    const p = latest.checkout && latest.checkout.patron;
                    const patronName = p
                        ? $patron_to_html(p, { invert_name: true })
                        : escapeHtml($__("Patron"));
                    detailed.push({
                        text: $__(
                            '%s has %s hold(s) waiting for pickup. <a href="/cgi-bin/koha/circ/circulation.pl?borrowernumber=%s">Check out to this patron</a>'
                        )
                            .replace("%s", patronName)
                            .replace(
                                "%s",
                                escapeHtml(msg.payload.waiting_count)
                            )
                            .replace("%s", escapeHtml(msg.payload.patron_id)),
                        alertClass: "alert-info",
                        priority: 10,
                    });
                }
                // return_claim is handled by the row (yellow + resolve button)
                // No alert needed
                if (msg.message === "claim_auto_resolved") {
                    detailed.push({
                        text: $__(
                            "Previously claimed returned item has been checked in. Claim automatically resolved."
                        ),
                        alertClass: "alert-info",
                    });
                }
            }
            // Show the most important alerts first (e.g. waiting holds), while
            // keeping the original order for boxes of equal priority.
            return detailed
                .map((box, index) => ({ box, index }))
                .sort(
                    (a, b) =>
                        (b.box.priority || 0) - (a.box.priority || 0) ||
                        a.index - b.index
                )
                .map(entry => entry.box);
        });

        function avDescription(category, value) {
            return store.authorisedValues[category]?.[value] || value;
        }

        // Legacy returns.tt treated any false value (undef, '' or 0) as
        // the item being available for loan
        function notForLoanDescription(value) {
            if (value === undefined || value === null || !Number(value)) {
                return $__("Available for loan");
            }
            return avDescription("NOT_LOAN", value);
        }

        function locationDescription(value) {
            if (value === undefined || value === null || value === "") {
                return $__("Blank");
            }
            return avDescription("LOC", value);
        }

        // Refocus barcode input when focus leaves to non-interactive elements
        // (e.g., sidebar toggle button, page chrome clicks)
        function handleDocumentClick(e) {
            // Refocus only when the sidebar collapse toggle is clicked
            if (e.target.closest(".sidebar-toggle")) {
                nextTick(() => refocusInput());
            }
        }

        onMounted(() => {
            document.addEventListener("click", handleDocumentClick);
            handleUrlParams();
        });

        // Handle deep-link query params carried over from the legacy
        // returns.pl page so existing links keep working:
        //   ?barcode=XXXX   -> prefill the barcode input and focus it
        // A GET request must never change state, so the checkin is not
        // submitted: staff need to confirm it explicitly.
        function handleUrlParams() {
            // A check-in requested from another page (header search box,
            // ILL, ...) with a POST request: check the item in
            const requested = (window.__CHECKIN_BARCODE__ || "").trim();
            if (requested) {
                onBarcodeScan(requested);
                return;
            }

            const params = new URLSearchParams(window.location.search);

            const barcode = params.get("barcode");
            if (barcode && barcode.trim() && barcodeInputRef.value) {
                barcodeInputRef.value.setBarcode(barcode.trim());
                refocusInput();
            }
        }

        onBeforeUnmount(() => {
            document.removeEventListener("click", handleDocumentClick);
        });

        // Watch for new pending items - auto-show panel for the first one
        watch(nextModalItem, newItem => {
            if (newItem && !activeModalItem.value && !showClaimModal.value) {
                activeModalItem.value = newItem;
                nextTick(() => refocusInput());
            }
        });

        function onBarcodeScan(barcode) {
            // Moving on from a non-blocking transfer confirms it when
            // AutomaticConfirmTransfer is set (legacy: on closing the modal)
            const active = activeModalItem.value;
            if (
                active &&
                active._action_type === "transfer" &&
                policy.value.auto_confirm_transfer &&
                !policy.value.transfers_block
            ) {
                onResolve(active, "confirm_transfer");
            }

            // Fire and forget - don't block the input
            store.checkin(barcode, { ...checkinOptions }).then(result => {
                if (result?.status === "duplicate") {
                    // The same barcode is still being checked in
                    lastError.value = $__(
                        "Item %s is already being checked in"
                    ).replace("%s", () => barcode);
                } else {
                    nextTick(() => playAudioAlert());
                }
                // HoldsAutoFillPrintSlip: print the slip for an auto-filled hold
                const autoFilled = (result?.data?.messages || []).find(
                    m => m.message === "hold_auto_filled"
                );
                if (
                    autoFilled &&
                    result.status === "success" &&
                    policy.value.holds_auto_fill_print_slip
                ) {
                    printHoldSlip(autoFilled.payload.reserve_id);
                }
            });
            // Clear return date if "remember" is not checked
            if (checkinOptionsRef.value) {
                checkinOptionsRef.value.afterCheckin();
            }
            nextTick(() => refocusInput());
        }

        function showModalFor(item) {
            activeModalItem.value = item;
        }

        function onMessagesClick(e) {
            const slipBtn = e.target.closest(".print-hold-slip");
            if (slipBtn) {
                printHoldSlip(slipBtn.dataset.reserveId);
            }
            const printMissingBtn = e.target.closest(".print-missing-items");
            if (printMissingBtn) {
                printMissingItems(printMissingBtn.dataset.checkinId);
            }
            const bundleBtn = e.target.closest(".remove-from-bundle");
            if (bundleBtn) {
                removeFromBundle(bundleBtn.dataset);
            }
        }

        function printMissingItems(checkinId) {
            const entry = checkins.value.find(
                c => String(c.checkin_id) === String(checkinId)
            );
            const msg = (entry?.messages || []).find(
                m => m.message === "bundle_missing_items"
            );
            if (!entry || !msg) return;
            const barcode = entry._barcode || entry.item?.external_id || "";
            printTable({
                title: $__(
                    "Items missing from bundle at checkin for %s"
                ).replace("%s", () => barcode),
                headers: [$__("Barcode"), $__("Title")],
                rows: (msg.payload?.items || []).map(i => [
                    i.external_id,
                    i.title,
                ]),
            });
        }

        async function removeFromBundle({ checkinId, itemId, hostItemId }) {
            try {
                // Through the API client: it sends the CSRF token
                await APIClient.item.bundled_items.remove(hostItemId, itemId, {
                    config: { suppressDefaultErrorDialog: true },
                });
                removedFromBundle.value = new Set([
                    ...removedFromBundle.value,
                    parseInt(checkinId),
                ]);
            } catch (e) {
                lastError.value = $__(
                    "Could not remove the item from the bundle"
                );
            }
        }

        // From the checkins table or the confirmation modal
        function onResolveClaim(checkin) {
            const claimMsg = (checkin.messages || []).find(
                m => m.message === "return_claim"
            );
            if (claimMsg && claimMsg.payload) {
                openClaimModal(claimMsg.payload.claim_id);
            }
        }

        // Only one modal at a time: the confirmation modal is hidden while
        // the resolve claim modal is open, and comes back when it is closed
        function openClaimModal(claimId) {
            activeModalItem.value = null;
            activeClaimId.value = claimId;
            showClaimModal.value = true;
        }

        function onClaimModalClose() {
            showClaimModal.value = false;
            activeClaimId.value = null;
            _advanceModal();
        }

        function onClaimResolved(claimId) {
            // Mark the row of the resolved claim as resolved
            const idx = checkins.value.findIndex(
                c =>
                    c._action_type === "claim" &&
                    c._status === "needs_action" &&
                    (c.messages || []).some(
                        m =>
                            m.message === "return_claim" &&
                            Number(m.payload?.claim_id) === Number(claimId)
                    )
            );
            if (idx !== -1) {
                checkins.value[idx] = {
                    ...checkins.value[idx],
                    _status: "success",
                    _action_type: null,
                };
            }
            onClaimModalClose();
        }

        async function onConfirm(item) {
            await store.confirmPending(item);
            _advanceModal();
        }

        async function onBundleConfirm(result) {
            const item = bundleModalItem.value;
            if (item) {
                // Pass verified barcodes through options - they will be
                // included in the POST /checkins body alongside the JWT
                if (result.verify) {
                    item._options.verified_bundle_barcodes =
                        result.scanned || [];
                }
                await store.confirmPending(item);
            }
            _advanceModal();
        }

        // Cancelling the bundle confirmation does not check the item in, like
        // "No, don't check in": the confirmation is dismissed and the next
        // pending item is shown
        function onBundleCancel() {
            const item = bundleModalItem.value;
            if (item) {
                store.dismissPending(item);
            }
            _advanceModal();
        }

        function onDismiss(item) {
            store.dismissPending(item);
            _advanceModal();
        }

        function onIgnore(item) {
            store.ignoreAction(item);
            _advanceModal();
        }

        // A non-blocking transfer modal was closed without picking an
        // action. Legacy confirmed an existing transfer on closing when
        // AutomaticConfirmTransfer was set, and left it alone otherwise.
        // Without a transfer (AutomaticItemReturn disabled) none is created,
        // so the row stops showing the suggested one, like "No, don't transfer".
        function onClose(item) {
            // Another modal was opened by the same click
            if (activeModalItem.value !== item) return;
            if (!item.transfer_id) {
                onResolve(item, "cancel_transfer");
            } else if (policy.value.auto_confirm_transfer) {
                onResolve(item, "confirm_transfer");
            } else {
                onIgnore(item);
            }
        }

        async function onResolve(item, action, params = {}) {
            const result = await store.resolveAction(item, action, params);
            const slip = params.slip;
            if (slip?.window) {
                if (result.status === "ok") {
                    slip.window.location.href = slip.url;
                } else {
                    slip.window.close();
                }
            }
            _advanceModal();
        }

        // Open the secondary hold-cancellation pop-up for the active item.
        // With hold_group, all the holds of the hold's group are cancelled.
        function onOpenCancelHold(item, { hold_group = false } = {}) {
            holdCancellationItem.value = item;
            holdCancellationGroup.value = hold_group;
            showHoldCancellationModal.value = true;
        }

        // Confirm from the secondary pop-up: cancel the hold via the API and
        // resolve the main modal
        async function onConfirmHoldCancellation(params = {}) {
            const item = holdCancellationItem.value;
            const holdGroup = holdCancellationGroup.value;
            showHoldCancellationModal.value = false;
            holdCancellationItem.value = null;
            holdCancellationGroup.value = false;
            if (!item) return;
            if (holdGroup) {
                await store.cancelHoldGroup(item, params);
            } else {
                await store.resolveAction(item, "cancel_hold", {
                    ...params,
                    forgive_hold_fees: checkinOptions.forgive_hold_fees,
                });
            }
            _advanceModal();
        }

        function _advanceModal() {
            activeModalItem.value = null;
            setTimeout(() => {
                if (nextModalItem.value) {
                    activeModalItem.value = nextModalItem.value;
                    nextTick(() => playAudioAlert());
                } else {
                    refocusInput();
                }
            }, 100);
        }

        // AudioAlerts: the page is not reloaded after each checkin, so the
        // check js_includes.inc runs on page load needs to be repeated once
        // the result of a checkin (or the next modal) has been rendered.
        // Plays the sound of the first configured selector that matches.
        function playAudioAlert() {
            const alerts = window.AUDIO_ALERTS;
            if (!alerts || typeof window.playSound !== "function") return;
            for (const alert of Object.values(alerts)) {
                let found = false;
                try {
                    found = window.$
                        ? window.$(alert.selector).length > 0
                        : !!document.querySelector(alert.selector);
                } catch (e) {
                    // Invalid selector configured, skip it
                }
                if (found) {
                    window.playSound(alert.sound);
                    break;
                }
            }
        }

        function refocusInput() {
            if (barcodeInputRef.value) {
                barcodeInputRef.value.focus();
            }
        }

        return {
            checkins,
            processing,
            lastError,
            pendingItems,
            activeModalItem,
            isInputBlocked,
            hasActiveSettings,
            dropboxDate,
            formatDate,
            formatDateTime,
            lastCheckinMessages,
            showOptions,
            showClaimModal,
            activeClaimId,
            bundleModalItem,
            confirmationModalItem,
            showHoldCancellationModal,
            holdCancellationGroup,
            onOpenCancelHold,
            onConfirmHoldCancellation,
            barcodeInputRef,
            checkinOptionsRef,
            checkinOptions,
            onOptionsUpdate,
            onBarcodeScan,
            showModalFor,
            onMessagesClick,
            onResolveClaim,
            onClaimModalClose,
            onClaimResolved,
            onBundleConfirm,
            onBundleCancel,
            onConfirm,
            onClose,
            onDismiss,
            onIgnore,
            onResolve,
        };
    },
};
</script>

<style>
/* The form and its settings share one card, as on the legacy page */
#checkin-app .checkin-card {
    padding: 1rem;
}

#checkin-app .checkin-card h1 {
    margin-bottom: 1rem;
}

#checkin-app .checkin-card fieldset {
    background: transparent;
    border: 0;
    box-shadow: none;
    margin: 0;
    padding: 0;
}

#checkin-app .checkin-card .circ-settings {
    margin: 1rem -1rem 0;
    padding: 1rem 1rem 0;
}

#checkin-app #return_date_override_fields input.flatpickr-input {
    max-width: 16em;
    min-width: 0;
}
</style>
