import { defineStore } from "pinia";
import { computed, reactive, ref, watch } from "vue";
import { $__ } from "@koha-vue/i18n";
import { idsEqual } from "../../utils/functions.js";
import { itemsAvailableForPeriod } from "../../lib/booking/availability/server-map.js";
import { useBookingCalendarState } from "./calendar.js";
import { useBookingWorkflow } from "./workflow.js";
import { useDataSection } from "./data.js";

/**
 * Status section: async-operation tracking and user-facing error state.
 *
 * Owns the `loading` map keyed by operation name (flipped per action via
 * `withErrorHandling`). Owns `error` for messages surfaced in the form;
 * fetch/mutate failures propagate to callers, which set `error` via
 * `formatApiError`.
 *
 * @typedef {Object} LoadingState In-flight flag per async operation.
 * @property {boolean} bookableItems
 * @property {boolean} patrons
 * @property {boolean} bookingPatron
 * @property {boolean} pickupLocations
 * @property {boolean} circulationRules
 * @property {boolean} holidays
 * @property {boolean} submit
 *
 * @typedef {Object} BookingError User-facing booking error.
 * @property {string} message Human-readable text ("" when cleared).
 * @property {string|null} code Category (e.g. "api", "validation",
 *   "no_items"); null when `message` is empty.
 *
 * @typedef {Object} StatusSection
 * @property {LoadingState} loading
 * @property {BookingError} error
 * @property {(message: string, code?: string) => void} setError
 * @property {() => void} clearError
 *
 * @returns {StatusSection}
 */
function useStatusSection() {
    /** @type {LoadingState} */
    const loading = reactive({
        bookableItems: false,
        patrons: false,
        bookingPatron: false,
        pickupLocations: false,
        circulationRules: false,
        holidays: false,
        submit: false,
    });

    /** @type {BookingError} */
    const error = reactive({ message: "", code: null });

    /**
     * @param {string} message - Error message to display
     * @param {string} code - Categorization code (e.g. "api",
     *   "validation", "no_items"). When `message` is empty the code
     *   is forced to null so consumers can use a single check.
     * @returns {void}
     */
    function setError(message, code = "general") {
        error.message = message || "";
        error.code = message ? code : null;
    }

    /**
     * Clear the current user-facing booking error.
     *
     * @returns {void}
     */
    function clearError() {
        error.message = "";
        error.code = null;
    }

    return {
        loading,
        error,

        setError,
        clearError,
    };
}

/**
 * Draft section: the booking-in-progress.
 *
 * Holds the user-mutable booking fields (patron, item, library,
 * dates) plus thin derived getters that normalize the draft for
 * downstream consumption.
 *
 * Date-type policy: `selectedDateRange` is canonical ISO 8601 strings
 * so the same value can be persisted, sent to the API, and round-
 * tripped through the picker. Widgets (Flatpickr) work with Date
 * objects and convert at the boundary; computation utilities convert
 * ISO → Date close to the boundary; API payloads use ISO as-is.
 *
 * `pickerModelValue` and `rangeAnchor` perform the ISO → Date
 * conversion centrally so the picker, the calendar-maps composable,
 * and any future consumer all see the same shape; previously each
 * call site recomputed it. `setSelectedDates` enforces the inverse
 * (Date → ISO) plus the [a] / [a, b] / [] shape invariant.
 *
 * @typedef {Object} DraftSection
 * @property {import('vue').Ref<import('@koha-vue/lib/booking/types/bookings').Id | null>} bookingId
 * @property {import('vue').Ref<import('@koha-vue/lib/booking/types/bookings').Id | null>} bookingItemId
 * @property {import('vue').Ref<import('@koha-vue/lib/booking/types/bookings').PatronOption | null>} bookingPatron
 * @property {import('vue').Ref<import('@koha-vue/lib/booking/types/bookings').Id | null>} bookingItemtypeId
 * @property {import('vue').Ref<string | null>} pickupLibraryId
 * @property {import('vue').Ref<string[]>} selectedDateRange Canonical ISO 8601 strings.
 * @property {import('vue').ComputedRef<Date[] | null>} pickerModelValue
 * @property {import('vue').ComputedRef<Date | null>} rangeAnchor
 * @property {import('vue').ComputedRef<Date>} minDate
 * @property {(v: Date | Date[] | [Date, Date] | null) => void} setSelectedDates
 *
 * @returns {DraftSection}
 */
function useDraftSection() {
    /** @type {import('vue').Ref<import('@koha-vue/lib/booking/types/bookings').Id | null>} */
    const bookingId = ref(null);
    /** @type {import('vue').Ref<import('@koha-vue/lib/booking/types/bookings').Id | null>} kept for backward compatibility */
    const bookingItemId = ref(null);
    /** @type {import('vue').Ref<import('@koha-vue/lib/booking/types/bookings').PatronOption | null>} */
    const bookingPatron = ref(null);
    /** @type {import('vue').Ref<import('@koha-vue/lib/booking/types/bookings').Id | null>} kept for backward compatibility */
    const bookingItemtypeId = ref(null);
    /** @type {import('vue').Ref<string | null>} */
    const pickupLibraryId = ref(null);
    /** @type {import('vue').Ref<string[]>} ISO 8601 strings; see module docstring */
    const selectedDateRange = ref([]);

    /**
     * ISO[] (store) → Date[] | null at flatpickr's range model:
     *   - empty / null-anchor → null
     *   - length 1 → [anchor]   (picking-end)
     *   - length 2 → [start, end]   (committed)
     *
     * @type {import('vue').ComputedRef<Date[] | null>}
     */
    const pickerModelValue = computed(() => {
        const range = selectedDateRange.value;
        if (!Array.isArray(range) || range.length === 0 || range[0] == null) {
            return null;
        }
        if (range.length === 1) return [new Date(range[0])];
        return [new Date(range[0]), new Date(range[1])];
    });

    /**
     * Anchor (start) of the current draft range, as a Date, or null
     * when no anchor is set. Used by the calendar-maps composable to
     * decide soft-vs-hard severity and constrained-range highlights.
     *
     * @type {import('vue').ComputedRef<Date | null>}
     */
    const rangeAnchor = computed(() => {
        const v = pickerModelValue.value;
        if (Array.isArray(v) && v.length >= 1 && v[0] instanceof Date) {
            return v[0];
        }
        return null;
    });

    /**
     * Earliest selectable date: tomorrow at midnight. Past-date
     * hard-disabling is also enforced inside createDisableFunction;
     * pinning minDate keeps flatpickr from rendering today as a hover
     * target.
     *
     * @type {import('vue').ComputedRef<Date>}
     */
    const minDate = computed(() => {
        const d = new Date();
        d.setHours(0, 0, 0, 0);
        d.setDate(d.getDate() + 1);
        return d;
    });

    /**
     * Write a Date-shaped picker value back into the store as the
     * canonical ISO[] form. Accepts the BookingCalendar range emit shape
     * (Date[] | null) and enforces the
     * [a] / [a, b] / [] invariant on `selectedDateRange`.
     *
     * @param {Date | Date[] | [Date, Date] | null} v
     * @returns {void}
     */
    function setSelectedDates(v) {
        if (!v) {
            selectedDateRange.value = [];
            return;
        }
        if (Array.isArray(v)) {
            selectedDateRange.value = v
                .filter(d => d instanceof Date)
                .map(d => d.toISOString());
            return;
        }
        if (v instanceof Date) {
            selectedDateRange.value = [v.toISOString()];
        }
    }

    /**
     * Reset all state whose lifetime is one booking session.
     *
     * @returns {void}
     */
    function resetDraft() {
        bookingId.value = null;
        bookingItemId.value = null;
        bookingPatron.value = null;
        bookingItemtypeId.value = null;
        pickupLibraryId.value = null;
        selectedDateRange.value = [];
    }

    return {
        bookingId,
        bookingItemId,
        bookingPatron,
        bookingItemtypeId,
        pickupLibraryId,
        selectedDateRange,

        pickerModelValue,
        rangeAnchor,
        minDate,

        setSelectedDates,
        resetDraft,
    };
}

/**
 * Build a localized message explaining why no items match the current draft.
 *
 * @param {Array<{library_id: string, name: string}>} pickupLocations
 * @param {Array<{item_type_id: string, description: string}>} itemTypes
 * @param {string|null} pickupLibraryId
 * @param {string|null} itemtypeId
 * @returns {string}
 */
function buildNoItemsAvailableMessage(
    pickupLocations,
    itemTypes,
    pickupLibraryId,
    itemtypeId
) {
    const selectionParts = [];
    if (pickupLibraryId) {
        const location = (pickupLocations || []).find(location =>
            idsEqual(location.library_id, pickupLibraryId)
        );
        selectionParts.push(
            $__("pickup location: %s").format(location?.name || pickupLibraryId)
        );
    }
    if (itemtypeId) {
        const itemType = (itemTypes || []).find(itemType =>
            idsEqual(itemType.item_type_id, itemtypeId)
        );
        selectionParts.push(
            $__("item type: %s").format(itemType?.description || itemtypeId)
        );
    }
    return $__(
        "No items are available for booking with the selected criteria (%s). Please adjust your selection."
    ).format(selectionParts.join(", "));
}

/**
 * Validation section: submit-readiness predicates, capacity gating,
 * the messages that explain why a draft cannot ship, and the action
 * that assembles the submission payload.
 *
 * Owns the booking form requirements. The workflow configures them for each
 * session; downstream getters read them to build context-aware messages and
 * determine which fields a draft must fill before submission.
 *
 * Owns the layered readiness predicates (dataReady, formPrefilterValid,
 * hasAvailableItems, isCalendarReady, isSubmitReady, readiness) the
 * booking UI previously computed inline. Same for the two top-level
 * watchers — clear-errors-on-input-change and the "no items available"
 * message synthesis — and the resolveItemForPeriod action that
 * encapsulates the 3-way item fallback (specific item / auto-pick /
 * itemtype) the modal previously inlined in handleSubmit.
 *
 * The capacity guard logic — hasPositiveCapacity, zeroCapacityMessage,
 * showCapacityWarning — was previously a standalone composable
 * (useCapacityGuard) called from BookingModal; it lives here now
 * because it is a pure function of store state plus form requirements.
 * Same for canSubmit (formerly useBookingValidation).
 *
 * @typedef {Object} Readiness Layered submit-readiness snapshot.
 * @property {boolean} dataReady Base inventory is loaded and at least one
 *   bookable or edit-assigned item exists.
 * @property {boolean} formPrefilterValid Required pre-calendar fields
 *   (e.g. patron when shown) are filled.
 * @property {boolean} hasAvailableItems The constraint pipeline yields
 *   at least one item.
 * @property {boolean} isCalendarReady Safe to enable the date picker.
 * @property {boolean} availabilityError The most recent availability
 *   fetch for the current context failed; refreshContext() can retry it.
 *
 * @typedef {{ ok: true, item_id: import('@koha-vue/lib/booking/types/bookings').Id|null, itemtype_id: import('@koha-vue/lib/booking/types/bookings').Id|null } | { ok: false }} ResolvedItem
 *
 * @typedef {Object} ValidationSection
 * @property {import('vue').ComputedRef<boolean>} hasPositiveCapacity
 * @property {import('vue').ComputedRef<string>} zeroCapacityMessage
 * @property {import('vue').ComputedRef<boolean>} showCapacityWarning
 * @property {import('vue').ComputedRef<boolean>} dataReady
 * @property {import('vue').ComputedRef<boolean>} formPrefilterValid
 * @property {import('vue').ComputedRef<boolean>} hasAvailableItems
 * @property {import('vue').ComputedRef<boolean>} isCalendarReady
 * @property {import('vue').ComputedRef<boolean>} isSubmitReady
 * @property {import('vue').ComputedRef<Readiness>} readiness
 * @property {(opts?: { patronSelectionRequired?: boolean, itemSelectionEnabled?: boolean, pickupLocationSelectionRequired?: boolean }) => void} configureForm
 * @property {(opts: { start: string, end: string, bookingId?: import('@koha-vue/lib/booking/types/bookings').Id|null }) => ResolvedItem} resolveItemForPeriod
 *
 * @param {{status: StatusSection, data: Object, draft: DraftSection, availability: Object}} sections Store sections used for validation.
 * @returns {ValidationSection}
 */
function useValidationSection({ status, data, draft, availability }) {
    /** @type {import('vue').Ref<boolean>} */
    const patronSelectionRequired = ref(false);
    /** @type {import('vue').Ref<boolean>} */
    const itemSelectionEnabled = ref(false);
    /** @type {import('vue').Ref<boolean>} */
    const pickupLocationSelectionRequired = ref(false);

    /**
     * Register form requirements for the lifetime of the current session.
     * The workflow sets them during initialization and resets them on close.
     *
     * @param {Object} [opts]
     * @param {boolean} [opts.patronSelectionRequired]
     * @param {boolean} [opts.itemSelectionEnabled]
     * @param {boolean} [opts.pickupLocationSelectionRequired]
     * @returns {void}
     */
    function configureForm(opts) {
        const o = opts || {};
        if ("patronSelectionRequired" in o) {
            patronSelectionRequired.value = !!o.patronSelectionRequired;
        }
        if ("itemSelectionEnabled" in o) {
            itemSelectionEnabled.value = !!o.itemSelectionEnabled;
        }
        if ("pickupLocationSelectionRequired" in o) {
            pickupLocationSelectionRequired.value =
                !!o.pickupLocationSelectionRequired;
        }
    }

    const canSubmit = computed(() => {
        if (patronSelectionRequired.value && !draft.bookingPatron.value)
            return false;
        if (
            pickupLocationSelectionRequired.value &&
            !draft.pickupLibraryId.value
        )
            return false;
        if (!data.bookableItems.value?.length) return false;
        return draft.selectedDateRange.value?.length >= 2;
    });

    // Capacity guard. A "positive capacity" means the effective
    // circulation rules yield a non-zero booking period under the
    // current dateRangeConstraint mode. When negative or unknown,
    // showCapacityWarning gates the calendar so the user sees a
    // context-aware reason rather than an unselectable picker.
    const hasPositiveCapacity = computed(() => {
        const rules = data.circulationRules.value?.[0] || {};
        const issuelength = Number(rules.issuelength) || 0;
        const renewalperiod = Number(rules.renewalperiod) || 0;
        const renewalsallowed = Number(rules.renewalsallowed) || 0;
        const withRenewals = issuelength + renewalperiod * renewalsallowed;

        const calculatedDays =
            rules.calculated_period_days != null
                ? Number(rules.calculated_period_days) || 0
                : null;

        const drc = availability.dateRangeConstraint.value;
        if (drc === "issuelength") return issuelength > 0;
        if (drc === "issuelength_with_renewals") return withRenewals > 0;

        if (calculatedDays != null) return calculatedDays > 0;
        return issuelength > 0 || withRenewals > 0;
    });

    const zeroCapacityMessage = computed(() => {
        const rules = data.circulationRules.value?.[0] || {};
        const issuelength = rules.issuelength;
        const hasExplicitZero =
            issuelength != null && Number(issuelength) === 0;
        const hasNull = issuelength === null || issuelength === undefined;

        const patronRequired = patronSelectionRequired.value;
        const itemEnabled = itemSelectionEnabled.value;
        const pickupRequired = pickupLocationSelectionRequired.value;

        if (hasExplicitZero) {
            if (patronRequired && itemEnabled && pickupRequired) {
                return $__(
                    "Bookings are not permitted for this combination of patron category, item type, and pickup location. The circulation rules set the booking period to zero days."
                );
            }
            if (itemEnabled && pickupRequired) {
                return $__(
                    "Bookings are not permitted for this item type at the selected pickup location. The circulation rules set the booking period to zero days."
                );
            }
            if (itemEnabled) {
                return $__(
                    "Bookings are not permitted for this item type. The circulation rules set the booking period to zero days."
                );
            }
            return $__(
                "Bookings are not permitted for this item. The circulation rules set the booking period to zero days."
            );
        }

        if (hasNull) {
            if (patronRequired && itemEnabled && pickupRequired) {
                return $__(
                    "No circulation rule is defined for this combination. Try a different item type, pickup location, or patron."
                );
            }
            if (itemEnabled && pickupRequired) {
                return $__(
                    "No circulation rule is defined for this combination. Try a different item type or pickup location."
                );
            }
            if (itemEnabled) {
                return $__(
                    "No circulation rule is defined for this combination. Try a different item type."
                );
            }
            if (pickupRequired) {
                return $__(
                    "No circulation rule is defined for this combination. Try a different pickup location."
                );
            }
            if (patronRequired) {
                return $__(
                    "No circulation rule is defined for this combination. Try a different patron."
                );
            }
        }

        const both = itemEnabled && pickupRequired;
        if (both) {
            return $__(
                "No valid booking period is available with the current selection. Try a different item type or pickup location."
            );
        }
        if (itemEnabled) {
            return $__(
                "No valid booking period is available with the current selection. Try a different item type."
            );
        }
        if (pickupRequired) {
            return $__(
                "No valid booking period is available with the current selection. Try a different pickup location."
            );
        }
        return $__(
            "No valid booking period is available for this record with your current settings. Please try again later or contact your library."
        );
    });

    const showCapacityWarning = computed(() => {
        // Refetches of the availability window keep serving the previous
        // payload, so only the very first load counts as "not loaded" —
        // gating on the in-flight flag would flap the form on every
        // context change.
        const dataLoaded =
            !status.loading.bookableItems &&
            data.bookingAvailability.value != null;
        const hasItems = (data.bookableItems.value?.length ?? 0) > 0;
        const hasRules = (data.circulationRules.value?.length ?? 0) > 0;

        const ctx = data.circulationRulesContext.value;
        const hasCompleteContext =
            ctx && ctx.patron_category_id != null && ctx.library_id != null;

        const rulesReady = !status.loading.circulationRules;

        return (
            dataLoaded &&
            rulesReady &&
            hasItems &&
            hasRules &&
            hasCompleteContext &&
            !hasPositiveCapacity.value
        );
    });

    // Readiness predicates: a layered description of how close the
    // current draft is to being submittable. The form reads `readiness`
    // to decide which steps to enable; `isSubmitReady` gates the submit
    // button. Layered so consumers can disambiguate "not ready, waiting
    // on data" from "ready, but the user has not filled the form" from
    // "ready, but no items can satisfy the current selection".
    const dataReady = computed(
        () =>
            !status.loading.bookableItems &&
            (data.bookableItems.value?.length ?? 0) > 0
    );
    const contextDataReady = computed(
        () =>
            data.bookingAvailability.value != null &&
            !data.bookingAvailabilityError.value
    );
    const formPrefilterValid = computed(
        () => !patronSelectionRequired.value || !!draft.bookingPatron.value
    );
    const isEditingAssignedItem = computed(
        () => !!draft.bookingId.value && !!draft.bookingItemId.value
    );
    const hasAvailableItems = computed(
        () =>
            availability.constrainedBookableItems.value.length > 0 ||
            isEditingAssignedItem.value
    );
    const isCalendarReady = computed(() => {
        const basicReady =
            dataReady.value &&
            contextDataReady.value &&
            formPrefilterValid.value &&
            hasAvailableItems.value;
        if (!basicReady) return false;
        if (status.loading.circulationRules) return true;
        return hasPositiveCapacity.value;
    });
    const isSubmitReady = computed(
        () => isCalendarReady.value && canSubmit.value
    );
    const readiness = computed(() => ({
        dataReady: dataReady.value,
        formPrefilterValid: formPrefilterValid.value,
        hasAvailableItems: hasAvailableItems.value,
        isCalendarReady: isCalendarReady.value,
        availabilityError: data.bookingAvailabilityError.value,
    }));

    // Clear pending errors as soon as the user changes any
    // submission-affecting input. Prevents stale "no items available"
    // or API failure messages from lingering after the user adjusts
    // the draft.
    watch(
        () => ({
            patron: draft.bookingPatron.value?.patron_id,
            pickup: draft.pickupLibraryId.value,
            itemtype: draft.bookingItemtypeId.value,
            item: draft.bookingItemId.value,
            d0: draft.selectedDateRange.value?.[0],
            d1: draft.selectedDateRange.value?.[1],
        }),
        (curr, prev) => {
            const inputsChanged =
                !prev ||
                curr.patron !== prev.patron ||
                curr.pickup !== prev.pickup ||
                curr.itemtype !== prev.itemtype ||
                curr.item !== prev.item ||
                curr.d0 !== prev.d0 ||
                curr.d1 !== prev.d1;
            if (inputsChanged) status.clearError();
        }
    );

    // Synthesize a "no items available" error when the draft is
    // otherwise complete but the constraint pipeline yields zero
    // bookable items. The watcher also clears its own message once the
    // condition no longer holds, so the flag does not stick.
    watch(
        [
            availability.constrainedBookableItems,
            () => draft.bookingPatron.value,
            () => draft.pickupLibraryId.value,
            () => draft.bookingItemtypeId.value,
            dataReady,
            () => status.loading.circulationRules,
            () => status.loading.pickupLocations,
        ],
        ([availableItems, patron, pickupLibrary, itemtypeId, isDataReady]) => {
            const pickupLocationsReady =
                !pickupLibrary ||
                (!status.loading.pickupLocations &&
                    data.pickupLocations.value.length > 0);
            const circulationRulesReady = !status.loading.circulationRules;

            if (
                isDataReady &&
                pickupLocationsReady &&
                circulationRulesReady &&
                patron &&
                (pickupLibrary || itemtypeId) &&
                availableItems.length === 0 &&
                !isEditingAssignedItem.value
            ) {
                const msg = buildNoItemsAvailableMessage(
                    data.pickupLocations.value,
                    data.itemTypes.value,
                    pickupLibrary,
                    itemtypeId
                );
                status.setError(msg, "no_items");
            } else if (status.error.code === "no_items") {
                status.clearError();
            }
        },
        { immediate: true }
    );

    /**
     * Resolve the item assignment for a draft submission given the
     * already-validated date range. Encapsulates the 3-way fallback
     * that was previously inline in BookingModal.handleSubmit:
     *  - A specific item is selected → returns `{ item_id }`.
     *  - No specific item, exactly one constrained item satisfies the
     *    period → auto-picks it and returns `{ item_id }`.
     *  - No specific item, multiple satisfy → returns `{ itemtype_id }`
     *    so the server picks.
     *  - No specific item, none satisfy → surfaces a "no available
     *    items" error and returns `{ ok: false }`.
     *
     * Exactly one of `item_id` / `itemtype_id` is populated when
     * `ok` is true; consumers can switch on which one is non-null.
     *
     * The availability map already excludes the booking being edited
     * (the fetch passes excluded_booking_id), so edits need no extra
     * exclusion handling here.
     *
     * @param {Object} opts
     * @param {string} opts.start - Start date as ISO string
     * @param {string} opts.end - End date as ISO string
     * @returns {{ ok: true, item_id: string|number|null, itemtype_id: string|number|null } | { ok: false }}
     */
    function resolveItemForPeriod({ start, end }) {
        if (draft.bookingItemId.value) {
            return {
                ok: true,
                item_id: draft.bookingItemId.value,
                itemtype_id: null,
            };
        }
        const available = itemsAvailableForPeriod(
            availability.unavailableByDate.value,
            availability.constrainedBookableItems.value,
            start,
            end
        );
        if (available.length === 0) {
            status.setError(
                $__("No items available for the selected period"),
                "no_available_items"
            );
            return { ok: false };
        }
        if (available.length === 1) {
            return {
                ok: true,
                item_id: available[0].item_id,
                itemtype_id: null,
            };
        }
        if (draft.bookingItemtypeId.value) {
            return {
                ok: true,
                item_id: null,
                itemtype_id: draft.bookingItemtypeId.value,
            };
        }
        // POST /bookings requires exactly one of item_id/itemtype_id, so a
        // multi-item draft with no itemtype selected cannot be submitted
        // as-is. When every available item shares one effective type we can
        // narrow to it; otherwise the staff member has to pick.
        const distinctTypes = [
            ...new Set(
                available
                    .map(i => i.effective_item_type_id || i.item_type_id)
                    .filter(Boolean)
                    .map(String)
            ),
        ];
        if (
            distinctTypes.length === 1 &&
            available.every(i => i.effective_item_type_id || i.item_type_id)
        ) {
            return {
                ok: true,
                item_id: null,
                itemtype_id: distinctTypes[0],
            };
        }
        status.setError(
            $__(
                "Please select an item or item type before placing the booking"
            ),
            "item_type_required"
        );
        return { ok: false };
    }

    return {
        zeroCapacityMessage,
        showCapacityWarning,

        isSubmitReady,
        readiness,

        configureForm,
        resolveItemForPeriod,
    };
}

/**
 * Booking state, synchronous derivation, and deliberately public actions.
 * Asynchronous session/context orchestration remains isolated in workflow.js;
 * booking-calendar derivation remains isolated in calendar.js.
 */
export const useBookingStore = defineStore("bookings", () => {
    const status = useStatusSection();
    const data = useDataSection({ status });
    const draft = useDraftSection({ data });
    const availability = useBookingCalendarState({ data, draft });
    const validation = useValidationSection({
        status,
        data,
        draft,
        availability,
    });
    const workflow = useBookingWorkflow({
        status,
        data,
        draft,
        availability,
        validation,
    });

    return {
        loading: status.loading,
        error: status.error,
        setError: status.setError,
        clearError: status.clearError,

        bookableItems: data.bookableItems,
        pickupLocations: data.pickupLocations,
        itemTypes: data.itemTypes,
        circulationRules: data.circulationRules,
        holidays: data.holidays,
        fetchPatrons: data.fetchPatrons,
        saveOrUpdateBooking: data.saveOrUpdateBooking,

        bookingId: draft.bookingId,
        bookingItemId: draft.bookingItemId,
        bookingPatron: draft.bookingPatron,
        bookingItemtypeId: draft.bookingItemtypeId,
        pickupLibraryId: draft.pickupLibraryId,
        selectedDateRange: draft.selectedDateRange,
        pickerModelValue: draft.pickerModelValue,
        rangeAnchor: draft.rangeAnchor,
        minDate: draft.minDate,
        setSelectedDates: draft.setSelectedDates,

        dateRangeConstraint: availability.dateRangeConstraint,
        maxBookingPeriod: availability.maxBookingPeriod,
        constrainedFlags: availability.constrainedFlags,
        constrainedPickupLocations: availability.constrainedPickupLocations,
        constrainedBookableItems: availability.constrainedBookableItems,
        constrainedItemTypes: availability.constrainedItemTypes,
        pickupLocationsFilteredOut: availability.pickupLocationsFilteredOut,
        pickupLocationsTotal: availability.pickupLocationsTotal,
        bookableItemsFilteredOut: availability.bookableItemsFilteredOut,
        bookableItemsTotal: availability.bookableItemsTotal,
        disabledFn: availability.disabledFn,
        disabledByDate: availability.disabledByDate,
        markersByDate: availability.markersByDate,
        classByDate: availability.classByDate,
        relevantItemIds: availability.relevantItemIds,
        bufferConfig: availability.bufferConfig,
        unavailableByDate: availability.unavailableByDate,

        zeroCapacityMessage: validation.zeroCapacityMessage,
        showCapacityWarning: validation.showCapacityWarning,
        isSubmitReady: validation.isSubmitReady,
        readiness: validation.readiness,
        resolveItemForPeriod: validation.resolveItemForPeriod,

        ...workflow,
    };
});
