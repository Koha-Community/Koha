<template>
    <div
        v-if="item"
        class="modal modal-lg show d-block audio-alert-action non-blocking"
        tabindex="-1"
        role="dialog"
        aria-modal="false"
        aria-labelledby="checkin-confirmation-title"
    >
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h1 id="checkin-confirmation-title" class="modal-title">
                        {{ modalTitle }}
                    </h1>
                </div>

                <div class="modal-body">
                    <!-- Item info (not shown for transfers - they render their own) -->
                    <h3 v-if="itemTitle && item._action_type !== 'transfer'">
                        <a
                            v-if="biblioId"
                            :href="`/cgi-bin/koha/catalogue/detail.pl?biblionumber=${biblioId}`"
                        >
                            {{ itemTitle }}
                        </a>
                        <span v-else>{{ itemTitle }}</span>
                        <div v-if="itemBarcode" class="hold-found-barcode">
                            (<a
                                v-if="biblioId"
                                :href="`/cgi-bin/koha/catalogue/moredetail.pl?biblionumber=${biblioId}${itemId ? `&itemnumber=${itemId}` : ''}`"
                                >{{ itemBarcode }}</a
                            ><span v-else>{{ itemBarcode }}</span
                            >)
                        </div>
                    </h3>

                    <!-- Patron note recorded on the checkout (issue.note) -->
                    <div v-if="patronNote" class="alert alert-info patron-note">
                        <h4>{{ $__("Patron note") }}</h4>
                        <p v-if="patronNoteDate">{{ patronNoteDate }}</p>
                        <p>{{ patronNote }}</p>
                    </div>

                    <!-- Blocked: item cannot be checked in (e.g. wrong branch) -->
                    <template v-if="isBlocked">
                        <p>
                            <strong>{{ $__("NOT CHECKED IN") }}</strong>
                        </p>
                        <p v-if="blockedReason">{{ blockedReason }}</p>

                        <!-- Note about accompanying materials -->
                        <div
                            v-if="item.item && item.item.materials_notes"
                            id="materials"
                            class="alert alert-info"
                        >
                            <span class="mats_spec_label">{{
                                $__("Note about the accompanying materials:")
                            }}</span>
                            <span class="mats_spec_message">{{
                                item.item.materials_notes
                            }}</span>
                        </div>
                    </template>

                    <!-- Pre-checkin confirmation: CircConfirmItemParts -->
                    <template v-if="isPreCheckin">
                        <div
                            v-if="item._confirms.item_parts"
                            class="alert alert-info"
                        >
                            <strong>{{
                                $__(
                                    "Please confirm that the accompanying materials are present:"
                                )
                            }}</strong>
                            {{ item._confirms.item_parts }}
                        </div>
                        <div
                            v-if="item._confirms.items_bundle"
                            class="alert alert-info"
                        >
                            <strong>{{
                                $__(
                                    "This item is a bundle. Please verify bundle contents before confirming check in."
                                )
                            }}</strong>
                        </div>
                    </template>

                    <!-- Post-checkin: Hold found -->
                    <template v-if="item._action_type === 'hold'">
                        <h4>{{ $__("Hold for:") }}</h4>
                        <ul v-if="item.hold && item.hold.patron">
                            <li>
                                <strong>
                                    <a
                                        :href="`/cgi-bin/koha/circ/circulation.pl?borrowernumber=${item.hold.patron.patron_id}`"
                                        v-html="
                                            patronName(item.hold.patron, {
                                                cardnumber: true,
                                            })
                                        "
                                    ></a>
                                </strong>
                                <span
                                    v-if="item.hold.patron.category_id"
                                    class="patron-category"
                                >
                                    &mdash;
                                    {{
                                        item.hold.patron._strings?.category_id
                                            ?.str ||
                                        item.hold.patron.category_id
                                    }}
                                </span>
                            </li>
                            <li
                                v-if="
                                    item.hold.patron.address ||
                                    item.hold.patron.city
                                "
                            >
                                {{
                                    [
                                        item.hold.patron.address,
                                        item.hold.patron.city,
                                        item.hold.patron.state,
                                        item.hold.patron.postal_code,
                                    ]
                                        .filter(Boolean)
                                        .join(", ")
                                }}
                            </li>
                            <li v-if="item.hold.patron.phone">
                                {{ item.hold.patron.phone }}
                            </li>
                            <li v-if="item.hold.patron.email">
                                <a :href="`mailto:${item.hold.patron.email}`">{{
                                    item.hold.patron.email
                                }}</a>
                            </li>
                            <li v-if="item.hold.patron.sms_number">
                                <a
                                    :href="`tel:${item.hold.patron.sms_number}`"
                                    >{{ item.hold.patron.sms_number }}</a
                                >
                            </li>
                            <li
                                v-if="item.hold.patron.restricted"
                                class="text-danger"
                            >
                                <strong>{{
                                    $__("Patron is RESTRICTED")
                                }}</strong>
                            </li>
                            <li
                                v-if="item.hold.patron.incorrect_address"
                                class="text-danger"
                            >
                                {{ $__("Patron's address is in doubt") }}
                            </li>
                            <li
                                v-if="
                                    patronNotified(
                                        item.hold.patron,
                                        'hold_fill_transports'
                                    )
                                "
                                class="notification_method"
                            >
                                <span>{{ $__("Patron notification:") }}</span>
                                {{
                                    notificationTransports(
                                        item.hold.patron,
                                        "hold_fill_transports"
                                    )
                                }}
                            </li>
                            <li v-else class="notification_method none">
                                {{ $__("Patron is not notified.") }}
                            </li>
                            <li
                                v-if="mainContactMethod(item.hold.patron)"
                                id="main_contact_method"
                            >
                                {{ $__("Main contact method:") }}
                                {{ mainContactMethod(item.hold.patron) }}
                            </li>
                        </ul>
                        <p v-else-if="holdInfo">
                            <strong>{{ $__("Hold for:") }}</strong>
                            <span v-html="holdPatronDescription"></span>
                        </p>

                        <template v-if="holdGroupId">
                            <h4>
                                <strong
                                    >{{ $__("Part of a hold group") }}:</strong
                                >
                            </h4>
                            <a
                                target="_blank"
                                :href="`/cgi-bin/koha/circ/circulation.pl?borrowernumber=${item.hold.patron_id}#holds_panel`"
                            >
                                <i class="fa fa-fw fa-external-link-alt"></i>
                                {{ $__("View patron's holds") }}
                            </a>
                        </template>

                        <h4 v-if="holdLibrary">
                            <strong>{{
                                needsTransfer
                                    ? $__("Transfer to:")
                                    : $__("Hold at")
                            }}</strong>
                            {{ holdLibrary }}
                        </h4>

                        <p v-if="checkinLibrary">
                            <strong>{{ $__("Checked in at:") }}</strong>
                            {{ checkinLibrary }}
                        </p>
                    </template>

                    <!-- Post-checkin: Transfer needed -->
                    <template v-if="item._action_type === 'transfer'">
                        <!-- Item info -->
                        <p>
                            <a
                                v-if="item.item && item.item.biblio"
                                :href="`/cgi-bin/koha/catalogue/detail.pl?biblionumber=${item.item.biblio.biblio_id}`"
                                >{{ itemBarcode }}: {{ itemTitle }}</a
                            >
                            <span v-else>{{ itemBarcode }}</span>
                        </p>

                        <h4 v-if="isTransferQuestion">
                            {{ $__("Transfer now?") }}
                        </h4>
                        <p v-if="hasExistingTransfer" class="text-muted">
                            {{
                                $__(
                                    'The transfer has already been created. "Cancel transfer" cancels it and records the cancellation in the item\'s transfer history.'
                                )
                            }}
                        </p>

                        <!-- Reason for transfer -->
                        <div
                            v-if="transferInfo && transferInfo.trigger"
                            class="alert alert-info"
                        >
                            <h5>{{ $__("Reason for transfer") }}</h5>
                            <p>
                                {{
                                    formatTransferTrigger(transferInfo.trigger)
                                }}
                            </p>
                        </div>

                        <!-- Check in messages -->
                        <div
                            v-if="transferCheckinMessages.length"
                            class="alert alert-warning"
                        >
                            <h5>{{ $__("Check in message") }}</h5>
                            <p
                                v-for="msg in transferCheckinMessages"
                                :key="msg.message"
                                class="text-danger"
                            >
                                {{ formatMessage(msg) }}
                            </p>
                        </div>
                    </template>

                    <!-- Post-checkin: Recall found -->
                    <template v-if="item._action_type === 'recall'">
                        <h4>{{ $__("Recall placed by:") }}</h4>
                        <ul v-if="item.recall && item.recall.patron">
                            <li>
                                <strong>
                                    <a
                                        :href="`/cgi-bin/koha/circ/circulation.pl?borrowernumber=${item.recall.patron.patron_id}`"
                                        v-html="
                                            patronName(item.recall.patron, {
                                                cardnumber: true,
                                            })
                                        "
                                    ></a>
                                </strong>
                                <span
                                    v-if="item.recall.patron.category_id"
                                    class="patron-category"
                                >
                                    &mdash;
                                    {{
                                        item.recall.patron._strings?.category_id
                                            ?.str ||
                                        item.recall.patron.category_id
                                    }}
                                </span>
                            </li>
                            <li
                                v-if="
                                    item.recall.patron.address ||
                                    item.recall.patron.city
                                "
                            >
                                {{
                                    [
                                        item.recall.patron.address,
                                        item.recall.patron.city,
                                        item.recall.patron.state,
                                        item.recall.patron.postal_code,
                                    ]
                                        .filter(Boolean)
                                        .join(", ")
                                }}
                            </li>
                            <li v-if="item.recall.patron.phone">
                                {{ item.recall.patron.phone }}
                            </li>
                            <li v-if="item.recall.patron.email">
                                <a
                                    :href="`mailto:${item.recall.patron.email}`"
                                    >{{ item.recall.patron.email }}</a
                                >
                            </li>
                            <li
                                v-if="
                                    patronNotified(
                                        item.recall.patron,
                                        'recall_waiting_transports'
                                    )
                                "
                                class="notification_method"
                            >
                                <span>{{ $__("Patron notification:") }}</span>
                                {{
                                    notificationTransports(
                                        item.recall.patron,
                                        "recall_waiting_transports"
                                    )
                                }}
                            </li>
                            <li v-else class="notification_method none">
                                {{ $__("Patron is not notified.") }}
                            </li>
                            <li
                                v-if="mainContactMethod(item.recall.patron)"
                                id="main_contact_method"
                            >
                                {{ $__("Main contact method:") }}
                                {{ mainContactMethod(item.recall.patron) }}
                            </li>
                        </ul>

                        <p
                            v-if="item.recall && item.recall.notes"
                            class="recall-notes"
                        >
                            <strong>{{ $__("Notes:") }}</strong>
                            {{ item.recall.notes }}
                        </p>

                        <p v-if="recallInfo && recallInfo.needs_transfer">
                            <strong>{{
                                $__("Transfer required for recall")
                            }}</strong>
                        </p>

                        <h4 v-if="recallLibrary">
                            <strong>{{ $__("Recall at") }}</strong>
                            {{ recallLibrary }}
                        </h4>
                    </template>

                    <!-- Post-checkin: Return claim -->
                    <template v-if="item._action_type === 'claim'">
                        <h4>{{ $__("Item was claimed returned") }}</h4>
                        <p>
                            {{
                                $__(
                                    "This item has an active return claim. Please resolve it."
                                )
                            }}
                        </p>
                        <div
                            v-for="(box, idx) in claimCheckinMessages"
                            :key="idx"
                            class="alert"
                            :class="box.alertClass"
                        >
                            {{ box.text }}
                        </div>
                    </template>

                    <!-- Warnings -->
                    <div
                        v-for="(value, key) in item._warnings"
                        :key="key"
                        class="alert alert-warning"
                    >
                        {{ formatWarning(key, value) }}
                    </div>
                </div>

                <div class="modal-footer">
                    <!-- Blocked: only an acknowledge button -->
                    <template v-if="isBlocked">
                        <button
                            type="button"
                            class="btn btn-primary approve"
                            accesskey="o"
                            @click="$emit('dismiss', item)"
                        >
                            <i class="fa fa-check"></i>
                            {{ $__("OK") }}
                        </button>
                    </template>

                    <!-- Pre-checkin confirmation buttons -->
                    <template v-if="isPreCheckin">
                        <button
                            type="button"
                            class="btn btn-primary approve"
                            :disabled="confirming"
                            accesskey="y"
                            @click="$emit('confirm', item)"
                        >
                            <i class="fa fa-check"></i>
                            {{ $__("Yes, check in (Y)") }}
                        </button>
                        <button
                            type="button"
                            class="btn btn-default deny"
                            :disabled="confirming"
                            accesskey="n"
                            @click="$emit('dismiss', item)"
                        >
                            <i class="fa fa-times"></i>
                            {{ $__("No, don't check in (N)") }}
                        </button>
                    </template>

                    <!-- Hold action buttons -->
                    <template v-if="item._action_type === 'hold'">
                        <button
                            type="button"
                            class="btn btn-primary approve"
                            :disabled="confirming"
                            accesskey="y"
                            @click="$emit('resolve', item, 'confirm_hold')"
                        >
                            <i class="fa fa-check"></i>
                            {{
                                needsTransfer
                                    ? $__("Confirm hold and transfer (Y)")
                                    : $__("Confirm hold (Y)")
                            }}
                        </button>
                        <button
                            type="button"
                            class="btn btn-default"
                            :disabled="confirming"
                            accesskey="p"
                            @click="printAndResolveHold"
                        >
                            <i class="fa fa-print"></i>
                            {{
                                needsTransfer
                                    ? $__(
                                          "Print slip, transfer, and confirm (P)"
                                      )
                                    : $__("Print slip and confirm (P)")
                            }}
                        </button>
                        <button
                            type="button"
                            class="btn btn-default deny"
                            :disabled="confirming"
                            accesskey="i"
                            @click="$emit('ignore', item)"
                        >
                            <i class="fa fa-times"></i>
                            {{ $__("Ignore (I)") }}
                        </button>
                        <!-- Only a waiting hold can be cancelled from here, as on the legacy page -->
                        <template v-if="holdInfo?.status === 'waiting'">
                            <button
                                v-if="holdGroupId"
                                type="button"
                                class="btn btn-danger"
                                :disabled="confirming"
                                accesskey="g"
                                @click="
                                    $emit('open-cancel-hold', item, {
                                        hold_group: true,
                                    })
                                "
                            >
                                <i class="fa fa-trash-can"></i>
                                {{ $__("Cancel all holds in hold group (G)") }}
                            </button>
                            <button
                                type="button"
                                class="btn btn-danger"
                                :disabled="confirming"
                                accesskey="x"
                                @click="$emit('open-cancel-hold', item)"
                            >
                                <i class="fa fa-trash-can"></i>
                                {{
                                    holdGroupId
                                        ? $__("Cancel this hold (X)")
                                        : $__("Cancel hold (X)")
                                }}
                            </button>
                        </template>
                    </template>

                    <!-- Transfer action buttons -->
                    <template v-if="item._action_type === 'transfer'">
                        <button
                            type="button"
                            class="btn btn-primary approve"
                            :disabled="confirming"
                            accesskey="y"
                            @click="$emit('resolve', item, 'confirm_transfer')"
                        >
                            <i class="fa fa-check"></i>
                            {{
                                hasExistingTransfer
                                    ? $__("OK (Y)")
                                    : $__("Yes, transfer (Y)")
                            }}
                        </button>
                        <button
                            type="button"
                            class="btn btn-default"
                            :disabled="confirming"
                            accesskey="p"
                            @click="printAndResolveTransfer"
                        >
                            <i class="fa fa-print"></i>
                            {{
                                hasExistingTransfer
                                    ? $__("Print slip (P)")
                                    : $__("Yes, print slip and transfer (P)")
                            }}
                        </button>
                        <button
                            v-if="isNonBlockingTransfer || isTransferQuestion"
                            type="button"
                            class="btn btn-default deny"
                            :disabled="confirming"
                            :accesskey="hasExistingTransfer ? 'x' : 'n'"
                            @click="$emit('resolve', item, 'cancel_transfer')"
                        >
                            <i class="fa fa-times"></i>
                            {{
                                hasExistingTransfer
                                    ? $__("Cancel transfer (X)")
                                    : $__("No, don't transfer (N)")
                            }}
                        </button>
                    </template>

                    <!-- Recall action buttons -->
                    <template v-if="item._action_type === 'recall'">
                        <button
                            type="button"
                            class="btn btn-primary approve"
                            :disabled="confirming"
                            accesskey="y"
                            @click="$emit('resolve', item, 'confirm_recall')"
                        >
                            <i class="fa fa-check"></i>
                            {{ $__("Confirm recall (Y)") }}
                        </button>
                        <button
                            type="button"
                            class="btn btn-default"
                            :disabled="confirming"
                            accesskey="p"
                            @click="printAndResolveRecall"
                        >
                            <i class="fa fa-print"></i>
                            {{ $__("Print slip and confirm (P)") }}
                        </button>
                        <button
                            type="button"
                            class="btn btn-default deny"
                            :disabled="confirming"
                            accesskey="i"
                            @click="$emit('ignore', item)"
                        >
                            <i class="fa fa-times"></i>
                            {{ $__("Ignore (I)") }}
                        </button>
                    </template>

                    <!-- Claim action buttons -->
                    <template v-if="item._action_type === 'claim'">
                        <button
                            type="button"
                            class="btn btn-primary approve"
                            accesskey="y"
                            @click="$emit('resolve-claim', item)"
                        >
                            <i class="fa fa-gavel"></i>
                            {{ $__("Resolve claim (Y)") }}
                        </button>
                        <button
                            type="button"
                            class="btn btn-default deny"
                            accesskey="i"
                            @click="$emit('ignore', item)"
                        >
                            <i class="fa fa-times"></i>
                            {{ $__("Ignore (I)") }}
                        </button>
                    </template>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
import { computed, onBeforeUnmount, onMounted } from "vue";
import { storeToRefs } from "pinia";
import { useCheckinStore } from "../../../stores/checkin.js";
import { $__ } from "@koha-vue/i18n";
import {
    holdSlipUrl,
    openSlipWindow,
    printTransferSlip,
    recallSlipUrl,
} from "./slip-printer.js";

export default {
    props: {
        item: {
            type: Object,
            default: null,
        },
        confirming: {
            type: Boolean,
            default: false,
        },
    },
    emits: [
        "close",
        "confirm",
        "dismiss",
        "ignore",
        "resolve",
        "resolve-claim",
        "open-cancel-hold",
    ],
    setup(props, { emit }) {
        const store = useCheckinStore();
        const { policy } = storeToRefs(store);

        // Resolve a library code to its name (falls back to the code)
        function libraryName(branchcode) {
            if (!branchcode) return "";
            return store.libraries[branchcode] || branchcode;
        }

        // Notification helpers, driven by the patron's notification_summary
        // embed (Bug 43486). Mirrors the legacy returns.pl display. The hold
        // modal uses the Hold_Filled transports; the recall modal uses the
        // Recall_Waiting transports (the notice that fires when a recall is
        // set waiting on checkin).
        const _transportLabels = {
            email: $__("Email"),
            phone: $__("Phone"),
            sms: $__("SMS"),
        };
        const _contactMethodLabels = {
            phone: $__("Primary phone"),
            phonepro: $__("Secondary phone"),
            mobile: $__("Other phone"),
            email: $__("Primary email"),
            emailpro: $__("Secondary email"),
            fax: $__("Fax"),
        };

        function patronNotified(patron, key = "hold_fill_transports") {
            const ns = patron && patron.notification_summary;
            return !!(ns && Array.isArray(ns[key]) && ns[key].length);
        }

        function notificationTransports(patron, key = "hold_fill_transports") {
            const ns = patron && patron.notification_summary;
            if (!ns || !Array.isArray(ns[key]) || !ns[key].length) return "";
            return ns[key].map(t => _transportLabels[t] || t).join(", ") + ".";
        }

        function mainContactMethod(patron) {
            const ns = patron && patron.notification_summary;
            const method = ns && ns.primary_contact_method;
            if (!method) return "";
            return _contactMethodLabels[method] || method;
        }

        // Non-blocking transfer: muted style when transfers_block is false
        const isNonBlockingTransfer = computed(
            () =>
                props.item &&
                props.item._action_type === "transfer" &&
                !policy.value.transfers_block
        );

        // The transfer already exists (created by AutomaticItemReturn, or
        // replacing a wrong one): the dialog only asks to acknowledge it and
        // the last button cancels it after the fact, which is recorded in the
        // transfer history. Without one, "No" simply does not create it.
        const hasExistingTransfer = computed(
            () =>
                !!props.item &&
                props.item._action_type === "transfer" &&
                !!props.item.transfer_id
        );

        // A non-blocking transfer modal can be closed by pressing Escape. It
        // does not block the page (staff keep scanning items), so clicks on
        // the page do not close it: a stray click must not cancel or confirm
        // the transfer. The parent decides what closing means.

        function onDocumentKeydown(e) {
            if (e.key !== "Escape" || !isNonBlockingTransfer.value) return;
            emit("close", props.item);
        }

        onMounted(() => {
            document.addEventListener("keydown", onDocumentKeydown);
        });

        onBeforeUnmount(() => {
            document.removeEventListener("keydown", onDocumentKeydown);
        });

        // The item needs a transfer that was not created (AutomaticItemReturn
        // disabled): staff decide whether to transfer it now
        const isTransferQuestion = computed(
            () =>
                props.item &&
                props.item._action_type === "transfer" &&
                !props.item.transfer_id &&
                (props.item.messages || []).some(
                    m => m.message === "needs_transfer"
                )
        );

        const isPreCheckin = computed(
            () => props.item && props.item._status === "pending_confirmation"
        );

        const isBlocked = computed(
            () => props.item && props.item._status === "blocked"
        );

        // Human-readable explanation for a blocked check-in, mirroring the
        // legacy returns.pl wrong-branch / blocked-item modal body.
        const blockedReason = computed(() => {
            const blockers = (props.item && props.item.blockers) || {};
            if (blockers.wrong_branch) {
                return $__(
                    "This item must be checked in at following library: %s"
                ).replace(
                    "%s",
                    libraryName(blockers.wrong_branch.right_branch)
                );
            }
            if (blockers.blocked_withdrawn) {
                return $__("This item is withdrawn and cannot be checked in.");
            }
            if (blockers.blocked_lost) {
                return $__("This item is lost and cannot be checked in.");
            }
            return "";
        });

        const itemBarcode = computed(
            () => props.item?.item?.external_id || props.item?._barcode || ""
        );

        const itemTitle = computed(() => props.item?.item?.biblio?.title || "");

        const biblioId = computed(
            () => props.item?.item?.biblio?.biblio_id || null
        );

        const itemId = computed(() => props.item?.item?.item_id || null);

        const modalTitle = computed(() => {
            if (!props.item) return "";
            if (isBlocked.value) return $__("Cannot check in");
            if (isPreCheckin.value) return $__("Please confirm check in");
            if (props.item._action_type === "hold") {
                return holdInfo.value?.status === "waiting"
                    ? $__("Hold found (item is already waiting)")
                    : $__("Hold found");
            }
            if (props.item._action_type === "transfer") {
                const msgs = props.item.messages || [];
                const wrongTransfer = msgs.find(
                    m => m.message === "wrong_transfer"
                );
                if (wrongTransfer) {
                    const dest = libraryName(wrongTransfer.payload?.to_library);
                    return $__(
                        "Wrong transfer detected, please return item to: %s"
                    ).replace("%s", dest);
                }
                return $__("Please return this item to: %s").replace(
                    "%s",
                    libraryName(transferInfo.value?.to_library)
                );
            }
            if (props.item._action_type === "recall")
                return $__("Recall found");
            if (props.item._action_type === "claim") return $__("Return claim");
            return $__("Action required");
        });

        const holdInfo = computed(() => {
            if (!props.item || props.item._action_type !== "hold") return null;
            const msg = (props.item.messages || []).find(
                m => m.message === "hold_found"
            );
            return msg?.payload || null;
        });

        // Hold group the found hold belongs to (DisplayAddHoldGroups)
        const holdGroupId = computed(() => {
            if (!holdInfo.value || !policy.value.display_hold_groups) {
                return null;
            }
            return props.item?.hold?.hold_group_id || null;
        });

        // Patron name as HTML (escaped), formatted like everywhere else
        function patronName(patron, { cardnumber = false } = {}) {
            return $patron_to_html(patron, {
                invert_name: true,
                display_cardnumber: cardnumber,
            });
        }

        // HTML: rendered with v-html
        const holdPatronDescription = computed(() => {
            if (!holdInfo.value) return "";
            // If hold is embedded with patron info
            if (props.item.hold?.patron) {
                return patronName(props.item.hold.patron);
            }
            return holdInfo.value.patron_id
                ? $__("Patron #%s").replace(
                      "%s",
                      parseInt(holdInfo.value.patron_id, 10)
                  )
                : "";
        });

        const holdLibrary = computed(() => {
            return libraryName(holdInfo.value?.library_id);
        });

        // The library the item was checked in at (for the "Checked in at" line)
        const checkinLibrary = computed(() => {
            return libraryName(props.item?.library_id);
        });

        // The recall's pickup library (for the "Recall at" line)
        const recallLibrary = computed(() => {
            return libraryName(props.item?.recall?.pickup_library_id);
        });

        // Patron note recorded on the checkout (issues.note), surfaced via the
        // embedded `checkout` object on the checkin response.
        const patronNote = computed(() => props.item?.checkout?.note || "");
        const patronNoteDate = computed(() => {
            const date = props.item?.checkout?.note_date;
            if (!date) return "";
            return typeof $date === "function" ? $date(date) : date;
        });

        // The hold is for another library: confirming it starts a transfer
        const needsTransfer = computed(() => {
            if (!props.item || props.item._action_type !== "hold") return false;
            return (
                !!holdInfo.value?.library_id &&
                holdInfo.value.library_id !== props.item.library_id
            );
        });

        // Check-in messages shown in the transfer modal: the transfer ones
        // have their own section, and was_returned is set on every return
        const transferCheckinMessages = computed(() =>
            (props.item?.messages || []).filter(
                m =>
                    ![
                        "wrong_transfer",
                        "needs_transfer",
                        "transferred",
                        "was_returned",
                    ].includes(m.message)
            )
        );

        const transferInfo = computed(() => {
            if (!props.item) return null;
            const msg = (props.item.messages || []).find(
                m =>
                    m.message === "needs_transfer" ||
                    m.message === "wrong_transfer" ||
                    m.message === "transferred"
            );
            return msg?.payload || null;
        });

        const recallInfo = computed(() => {
            if (!props.item) return null;
            const msg = (props.item.messages || []).find(
                m => m.message === "recall_found"
            );
            return msg?.payload || null;
        });

        function formatWarning(key, value) {
            const labels = {
                not_issued: $__("Item was not checked out"),
                withdrawn: $__("Item is withdrawn"),
            };
            return labels[key] || key.replace(/_/g, " ");
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

        function formatMessage(msg) {
            // The item type checkin message carries its text in the payload
            if (msg.message === "item_type_checkinmsg") {
                return msg.payload?.text || "";
            }
            const labels = {
                not_issued: $__("Not checked out."),
                local_use: $__("Local use recorded"),
                was_lost: $__("Was lost, now found"),
                withdrawn: $__("Item is withdrawn"),
            };
            return labels[msg.message] || msg.message.replace(/_/g, " ");
        }

        // Check-in messages shown inside the return-claim modal (a claim
        // checkin actually returns the item, so lost/fee messages apply).
        const claimCheckinMessages = computed(() => {
            const labels = {
                was_lost: {
                    text: $__("Item was lost, now found."),
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
                lost_item_fee_refunded: {
                    text: $__(
                        "A refund for the lost item charge has been applied to the borrowing patron's account."
                    ),
                    alertClass: "alert-info",
                },
                processing_fee_refunded: {
                    text: $__(
                        "A refund for the lost item processing charge has been applied to the borrowing patron's account."
                    ),
                    alertClass: "alert-info",
                },
            };
            const messages = (props.item && props.item.messages) || [];
            return messages
                .filter(m => labels[m.message])
                .map(m => labels[m.message]);
        });

        function printAndResolveHold() {
            const reserveId = holdInfo.value?.reserve_id || props.item?.hold_id;
            emit("resolve", props.item, "confirm_hold", {
                print: true,
                slip: _pendingHoldSlip(reserveId),
            });
        }

        function printAndResolveTransfer() {
            const itemId = props.item?.item?.item_id;
            const destination = transferInfo.value?.to_library || "";
            if (itemId && destination) {
                printTransferSlip(itemId, destination);
            }
            emit("resolve", props.item, "confirm_transfer", { print: true });
        }

        function printAndResolveRecall() {
            const recallId = recallInfo.value?.recall_id;
            emit("resolve", props.item, "confirm_recall", {
                print: true,
                slip: recallId
                    ? { window: openSlipWindow(), url: recallSlipUrl(recallId) }
                    : null,
            });
        }

        // Bug 42505: open the popup now, while the click gesture is active, so
        // it is not blocked. The slip is only loaded into it once the hold has
        // been confirmed, so waitingdate/expirationdate are up to date.
        function _pendingHoldSlip(reserveId) {
            if (!reserveId) return null;
            return { window: openSlipWindow(), url: holdSlipUrl(reserveId) };
        }

        return {
            hasExistingTransfer,
            isNonBlockingTransfer,
            isTransferQuestion,
            isPreCheckin,
            isBlocked,
            blockedReason,
            itemBarcode,
            itemTitle,
            biblioId,
            itemId,
            modalTitle,
            holdInfo,
            transferCheckinMessages,
            holdPatronDescription,
            holdGroupId,
            patronName,
            holdLibrary,
            checkinLibrary,
            recallLibrary,
            patronNote,
            patronNoteDate,
            needsTransfer,
            transferInfo,
            recallInfo,
            formatWarning,
            formatTransferTrigger,
            formatMessage,
            claimCheckinMessages,
            printAndResolveHold,
            printAndResolveTransfer,
            printAndResolveRecall,
            patronNotified,
            notificationTransports,
            mainContactMethod,
        };
    },
};
</script>

<style scoped>
/* Non-blocking transfers: no backdrop, pointer-events pass through */
.non-blocking {
    pointer-events: none;
}

.non-blocking .modal-dialog {
    pointer-events: auto;
}

/* Match the legacy returns.pl notification boxes */
.notification_method,
#main_contact_method {
    background-color: #ffe;
    border: 1px solid #ccc;
    border-radius: 5px;
    display: inline-block;
    list-style-type: none;
    margin: 0.5em 0;
    padding: 0.1em 0.3em;
}

.notification_method.none {
    background-color: #eee;
}
</style>
