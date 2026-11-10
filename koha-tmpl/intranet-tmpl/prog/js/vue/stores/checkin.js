import { defineStore } from "pinia";
import { computed, reactive, ref } from "vue";
import { APIClient } from "../fetch/api-client.js";
import { $__ } from "@koha-vue/i18n";

export const useCheckinStore = defineStore("checkin", () => {
    // Flat view of the module policy: the check-in keys plus `global`
    const policy = reactive({});
    applyPolicy(window.__MODULE_POLICY__);
    const libraryId = window.__LIBRARY_ID__ || null;
    const tableSettings = window.__TABLE_SETTINGS__ || {};
    const libraries = ref({});
    const checkins = ref([]);
    const processing = ref(false);

    // Fetch libraries for name resolution
    APIClient.library.libraries
        .getAll()
        .then(libs => {
            const map = {};
            for (const lib of libs || []) {
                map[lib.library_id] = lib.name;
            }
            libraries.value = map;
        })
        .catch(() => {});

    // Fetch authorised value descriptions used to display item status
    // changes (UpdateNotForLoanStatusOnCheckin, UpdateItemLocationOnCheckin)
    const authorisedValues = ref({ NOT_LOAN: {}, LOC: {} });
    for (const category of Object.keys(authorisedValues.value)) {
        APIClient.authorised_values.values
            .get(category)
            .then(values => {
                const map = {};
                for (const av of values || []) {
                    map[av.value] = av.description;
                }
                authorisedValues.value = {
                    ...authorisedValues.value,
                    [category]: map,
                };
            })
            .catch(() => {});
    }
    const lastError = ref(null);
    const _inflight = new Set();
    // Follow-up actions in progress, by entry key: a double click or a
    // repeated shortcut must not send the same action twice
    const _actionsInflight = new Set();
    // Entries are identified by a key, not by their position: the list
    // changes while requests are in flight (new scans are added on top)
    let _keySeq = 0;

    const maxItems = policy.max_returned_items || 20;

    /**
     * Items in the queue that need staff attention (modal or inline action).
     * Computed from checkins with pending statuses.
     */
    const pendingItems = computed(() =>
        checkins.value.filter(
            c =>
                c._status === "pending_confirmation" ||
                c._status === "needs_action" ||
                c._status === "blocked"
        )
    );

    /**
     * The first pending item that should be shown in a modal.
     * Only one modal at a time - the rest stay as yellow rows.
     */
    const nextModalItem = computed(() => pendingItems.value[0] || null);

    /**
     * Perform a checkin. Adds entry to table regardless of outcome.
     * On 412: stores JWT and confirmation details for later resolution.
     * On 200 with hold/transfer/recall: marks as needs_action.
     */
    async function checkin(barcode, options = {}) {
        // Prevent double-scan: reject if this barcode has a request in-flight
        if (_inflight.has(barcode)) {
            return { status: "duplicate", data: null };
        }
        _inflight.add(barcode);

        processing.value = true;
        lastError.value = null;

        const body = { external_id: barcode };
        if (libraryId) body.library_id = libraryId;
        if (options.exempt_fine) body.exempt_fine = true;
        if (options.dropbox_mode) body.dropbox_mode = true;
        if (options.return_date) body.return_date = options.return_date;

        try {
            const client = APIClient.checkin;
            const data = await client.checkins.create(body, {
                confirmation: options.confirmation || null,
            });

            // Success: determine if post-checkin action needed
            const actionType = _detectActionType(data);
            const status = actionType ? "needs_action" : "success";

            _addEntry({
                ...data,
                _status: status,
                _confirmation_token: null,
                _confirms: {},
                _warnings: {},
                _action_type: actionType,
                _barcode: barcode,
                _options: options,
            });

            return { status, data };
        } catch (error) {
            return _checkinError(error, barcode, options);
        } finally {
            _inflight.delete(barcode);
            processing.value = false;
        }
    }

    /**
     * Handle a check-in refused by the API: confirmations and blockers are
     * added to the table, other errors are reported.
     */
    function _checkinError(error, barcode, options) {
        const data = error?.body || {};

        if (error?.status === 412) {
            // Confirmation required: add to table as pending
            _addEntry({
                checkin_id: null,
                item: data.item || null,
                checkout: data.checkout || null,
                messages: [],
                _status: "pending_confirmation",
                _confirmation_token: data.confirmation_token,
                _confirms: data.confirms || {},
                _warnings: data.warnings || {},
                _action_type: null,
                _barcode: barcode,
                _options: options,
            });
            return { status: "pending_confirmation", data };
        }

        if (error?.status === 403 && data.error_code === "checkin_blocked") {
            // Blocked: add as blocked row
            _addEntry({
                checkin_id: null,
                item: data.item || null,
                checkout: null,
                blockers: data.blockers || {},
                messages: [{ message: "checkin_blocked", type: "error" }],
                _status: "blocked",
                _confirmation_token: null,
                _confirms: {},
                _warnings: {},
                _action_type: null,
                _barcode: barcode,
                _options: options,
            });
            return { status: "blocked", data };
        }

        if (error?.status === 404) {
            lastError.value = $__("No item with barcode: %s").replace(
                "%s",
                barcode
            );
            return { status: "not_found", data };
        }

        lastError.value = _errorMessage(error);
        return { status: "error", data };
    }

    /**
     * Confirm a pre-checkin confirmation (412 flow).
     * Re-issues the checkin request with the stored JWT.
     */
    async function confirmPending(entry) {
        if (_findIndex(entry) === -1)
            return { status: "error", message: $__("Entry not found") };
        if (!_startAction(entry)) return { status: "in_progress" };

        processing.value = true;

        try {
            const client = APIClient.checkin;
            const body = { external_id: entry._barcode };
            if (libraryId) body.library_id = libraryId;
            if (entry._options.exempt_fine) body.exempt_fine = true;
            if (entry._options.dropbox_mode) body.dropbox_mode = true;
            if (entry._options.return_date)
                body.return_date = entry._options.return_date;
            if (entry._options.verified_bundle_barcodes)
                body.verified_bundle_barcodes =
                    entry._options.verified_bundle_barcodes;

            const data = await client.checkins.create(body, {
                confirmation: entry._confirmation_token,
            });

            // Confirmed successfully: update entry in place
            const actionType = _detectActionType(data);
            const status = actionType ? "needs_action" : "success";

            _replaceEntry(entry, {
                ...data,
                _status: status,
                _confirmation_token: null,
                _confirms: {},
                _warnings: {},
                _action_type: actionType,
                _barcode: entry._barcode,
                _options: entry._options,
            });

            return { status, data };
        } catch (error) {
            // Confirmation failed: keep as pending
            lastError.value = _errorMessage(error, $__("Confirmation failed"));
            return { status: "error", data: error?.body || null };
        } finally {
            processing.value = false;
            _endAction(entry);
        }
    }

    /**
     * Dismiss a pending confirmation without confirming (staff said "No").
     * Marks the row as dismissed.
     */
    function dismissPending(entry) {
        _replaceEntry(entry, {
            ...entry,
            _status: "dismissed",
            _confirmation_token: null,
        });
    }

    /**
     * Ignore a post-checkin action (hold, recall, claim). The item was
     * checked in, so the row is marked as a successful checkin.
     */
    function ignoreAction(entry) {
        _replaceEntry(entry, {
            ...entry,
            _status: "success",
            _action_type: null,
        });
    }

    /**
     * Cancel all the holds of the hold group the found hold belongs to
     * (DisplayAddHoldGroups). The checked in item's hold is part of it, so
     * the action is resolved.
     */
    async function cancelHoldGroup(entry, params = {}) {
        const hold = entry.hold;
        if (_findIndex(entry) === -1 || !hold?.hold_group_id) {
            return { status: "error", message: $__("Entry not found") };
        }
        if (!_startAction(entry)) return { status: "in_progress" };

        try {
            await APIClient.patron.hold_groups.cancel(
                hold.patron_id,
                hold.hold_group_id,
                { cancellation_reason: params.reason },
                { suppressDefaultErrorDialog: true }
            );
            const current = checkins.value[_findIndex(entry)];
            if (current) {
                _replaceEntry(entry, {
                    ...current,
                    _status: "success",
                    _action_type: null,
                });
            }
            return { status: "ok" };
        } catch (error) {
            // The action stays pending: tell the user why it did not go through
            lastError.value = _errorMessage(
                error,
                $__("An error occurred while cancelling the hold group.")
            );
            return { status: "error", message: error.message };
        } finally {
            _endAction(entry);
        }
    }

    /**
     * Resolve a post-checkin action (hold, transfer, recall).
     */
    async function resolveAction(entry, action, params = {}) {
        if (_findIndex(entry) === -1)
            return { status: "error", message: $__("Entry not found") };
        if (!_startAction(entry)) return { status: "in_progress" };

        try {
            const client = APIClient.checkin;
            const checkinId = entry.checkin_id;
            // Tokens for the follow-up actions, returned on checkin
            const tokens = entry.action_tokens || {};
            let data;

            switch (action) {
                case "confirm_hold":
                    data = await client.checkins.confirmHold(checkinId, {
                        action_token: tokens.hold_confirmation,
                    });
                    break;
                case "cancel_hold":
                    data = await client.checkins.cancelHold(checkinId, {
                        reason: params.reason,
                        forgive_hold_fees: params.forgive_hold_fees,
                        action_token: tokens.hold_cancellation,
                    });
                    break;
                case "confirm_transfer": {
                    // Without AutomaticItemReturn no transfer was created:
                    // request it to the library the checkin pointed at
                    const needs = _needsTransferMessage(entry);
                    if (entry.transfer_id) {
                        data = await client.checkins.confirmTransfer(
                            checkinId,
                            { action_token: tokens.transfer_confirmation }
                        );
                    } else if (needs) {
                        data = await client.checkins.confirmTransfer(
                            checkinId,
                            {
                                to_library_id: needs.payload?.to_library,
                                reason: needs.payload?.trigger,
                                action_token: tokens.transfer_confirmation,
                            }
                        );
                    }
                    break;
                }
                case "cancel_transfer":
                    if (entry.transfer_id) {
                        data = await client.checkins.cancelTransfer(checkinId, {
                            action_token: tokens.transfer_cancellation,
                        });
                    }
                    break;
                case "confirm_recall":
                    data = await client.checkins.confirmRecall(checkinId, {
                        action_token: tokens.recall_confirmation,
                    });
                    break;
            }

            // Update entry in place: action resolved
            // Preserve item/checkout data from the original response
            // since sub-resource endpoints may not embed them fully.
            // The entry is looked up again: the list may have changed while
            // the request was in flight.
            const existing = checkins.value[_findIndex(entry)];
            if (!existing) return { status: "ok", data };
            const resolved = {
                ...existing,
                _status: "success",
                _action_type: null,
            };
            // Confirming the hold started a transfer to the pickup library:
            // show it on the row
            if (action === "confirm_hold" && data?.transfer) {
                resolved.transfer_id = data.transfer.transfer_id;
                resolved.messages = [
                    ...(existing.messages || []),
                    {
                        message: "transferred",
                        type: "info",
                        payload: {
                            transfer_id: data.transfer.transfer_id,
                            to_library: data.transfer.to_library_id,
                            trigger: data.transfer.reason,
                        },
                    },
                ];
            }
            // The transfer was requested on confirmation: show it as sent
            if (
                action === "confirm_transfer" &&
                !existing.transfer_id &&
                data?.transfer
            ) {
                resolved.transfer_id = data.transfer.transfer_id;
                resolved.messages = (existing.messages || []).map(m =>
                    m.message === "needs_transfer"
                        ? {
                              ...m,
                              message: "transferred",
                              payload: {
                                  ...m.payload,
                                  transfer_id: data.transfer.transfer_id,
                              },
                          }
                        : m
                );
            }
            // The transfer was cancelled: stop showing it on the row
            if (action === "cancel_transfer") {
                resolved.transfer_id = null;
                resolved.messages = (existing.messages || []).filter(
                    m =>
                        ![
                            "needs_transfer",
                            "transferred",
                            "wrong_transfer",
                        ].includes(m.message)
                );
            }
            _replaceEntry(entry, resolved);

            return { status: "ok", data };
        } catch (error) {
            // The action stays pending: tell the user why it did not go through
            lastError.value = _errorMessage(error);
            return { status: "error", message: lastError.value };
        } finally {
            _endAction(entry);
        }
    }

    /**
     * The needs_transfer message of a checkin, if any.
     */
    function _needsTransferMessage(data) {
        return (data.messages || []).find(m => m.message === "needs_transfer");
    }

    /**
     * Detect if a successful checkin requires post-action (hold/transfer/recall).
     */
    function _detectActionType(data) {
        const messages = data.messages || [];
        if (
            data.hold_id &&
            messages.some(m => m.message === "hold_found") &&
            !messages.some(
                m =>
                    m.message === "hold_auto_filled" ||
                    m.message === "hold_auto_fill_failed"
            )
        ) {
            return "hold";
        }
        if (messages.some(m => m.message === "wrong_transfer")) {
            return "transfer";
        }
        if (
            data.transfer_id &&
            messages.some(
                m =>
                    m.message === "needs_transfer" ||
                    m.message === "transferred"
            )
        ) {
            return "transfer";
        }
        // The item needs a transfer that was not created (AutomaticItemReturn
        // disabled): ask whether to transfer it now
        if (_needsTransferMessage(data)) {
            return "transfer";
        }
        if (
            data.recall_id &&
            messages.some(m => m.message === "recall_found")
        ) {
            return "recall";
        }
        if (messages.some(m => m.message === "return_claim")) {
            return "claim";
        }
        return null;
    }

    /**
     * Apply a module policy envelope (as defined by the module_policy API
     * definition) to the reactive policy: the check-in keys are flattened
     * next to the global ones. Used for the policy bootstrapped on page
     * load and the one returned when the API refuses a request because of
     * it.
     */
    function applyPolicy(envelope) {
        if (!envelope || envelope.module !== "checkin") return;
        Object.assign(policy, envelope.checkin || {}, {
            global: envelope.global || {},
        });
    }

    // Messages for the check-in errors not related to the module policy
    const _errorMessages = {
        return_date_in_future: $__(
            "The return date cannot be in the future. The item was not checked in."
        ),
        item_without_barcode: $__(
            "The item has no barcode. It cannot be checked in."
        ),
        library_not_allowed: $__(
            "You are not allowed to check in items at this library."
        ),
        checkin_failed: $__(
            "The item has not been checked in due to an issue in your system. An administrator may find further details in the logs, and in the 'System information' tab of the About page."
        ),
        stale_checkin: $__(
            "The item has been checked in again since. Nothing was done."
        ),
        item_checked_out: $__(
            "The item has been checked out again since. Nothing was done."
        ),
        hold_not_found: $__(
            "The hold no longer exists. It may have been cancelled or filled in the meantime."
        ),
        transfer_limit: $__(
            "The transfer is not allowed by the library transfer limits."
        ),
        transfer_in_queue: $__("The item already has a pending transfer."),
        transfer_finished: $__(
            "The transfer has already arrived or has been cancelled. Nothing was done."
        ),
        transfer_not_started: $__(
            "The transfer to the pickup library could not be started."
        ),
        invalid_action_token: $__(
            "This action has expired. Please check the item in again."
        ),
    };

    /**
     * Message for a failed request: a translated message for the known error
     * codes, the server message otherwise. A refusal because of the module
     * policy also refreshes the policy, so the UI stops offering the option.
     */
    function _errorMessage(error, fallback = $__("An error occurred")) {
        if (!error?.status) {
            return $__("Network error. Please try again.");
        }
        if (error.status === 401) {
            return $__(
                "Your session has expired. Please reload the page and log in again."
            );
        }
        const data = error.body || {};
        if (data.policy) {
            applyPolicy(data.policy);
            return _policyErrorMessage(data);
        }
        return _errorMessages[data.error_code] || data.error || fallback;
    }

    /**
     * Message for a request refused because of the module policy.
     */
    function _policyErrorMessage(data) {
        const messages = {
            no_permission_for_exempt_fine: $__(
                "You are not allowed to forgive overdue charges. The item was not checked in."
            ),
            no_permission_for_forgive_hold_fees: $__(
                "You are not allowed to forgive hold fees. The hold was not cancelled."
            ),
            return_date_not_allowed: $__(
                "Specifying a return date is not allowed. The item was not checked in."
            ),
        };
        return (
            messages[data.error_code] || data.error || $__("An error occurred")
        );
    }

    /**
     * Whether the entry still needs staff attention.
     */
    function _needsAttention(entry) {
        return (
            entry._status === "pending_confirmation" ||
            entry._status === "needs_action" ||
            entry._status === "blocked"
        );
    }

    /**
     * Add entry to the checkins list (most recent first), trim to max.
     * Entries that need attention are never trimmed.
     */
    function _addEntry(entry) {
        entry._key = ++_keySeq;
        checkins.value.unshift(entry);
        if (checkins.value.length > maxItems) {
            let kept = 0;
            checkins.value = checkins.value.filter(
                c => _needsAttention(c) || kept++ < maxItems
            );
        }
    }

    /**
     * Position of the entry in the list, looked up by key.
     */
    function _findIndex(entry) {
        return checkins.value.findIndex(c => c._key === entry?._key);
    }

    /**
     * Replace the entry, wherever it is in the list now. Returns false if
     * the entry is no longer in the list.
     */
    function _replaceEntry(entry, replacement) {
        const idx = _findIndex(entry);
        if (idx === -1) return false;
        checkins.value[idx] = { ...replacement, _key: entry._key };
        return true;
    }

    function _startAction(entry) {
        if (_actionsInflight.has(entry._key)) return false;
        _actionsInflight.add(entry._key);
        return true;
    }

    function _endAction(entry) {
        _actionsInflight.delete(entry._key);
    }

    return {
        policy,
        libraries,
        authorisedValues,
        tableSettings,
        checkins,
        processing,
        lastError,
        pendingItems,
        nextModalItem,
        checkin,
        confirmPending,
        dismissPending,
        ignoreAction,
        resolveAction,
        cancelHoldGroup,
        applyPolicy,
    };
});
