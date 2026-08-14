import { ref } from "vue";
import { formatYMD, addDays } from "../../lib/booking/dates.js";
import { idsEqual } from "../../utils/functions.js";
import { calculateMaxBookingPeriod } from "../../lib/booking/availability/predicate.js";

const CALENDAR_BUFFER_DAYS = 7;
const DEFAULT_LOOKAHEAD_DAYS = 90;

/** @typedef {import('@koha-vue/lib/booking/types/bookings').Id} Id */
/** @typedef {import('@koha-vue/lib/booking/types/bookings').PatronOption} PatronOption */
/** @typedef {{generation: number, signal: AbortSignal}} Transition */
/** @typedef {{start: Date, end: Date}} Viewport */
/** @typedef {{status: Object, data: Object, draft: Object, availability: Object, validation: Object}} WorkflowSections */
/** @typedef {{biblionumber?: Id, biblio_id?: Id, bookingId?: Id|null, booking_id?: Id|null, itemId?: Id|null, item_id?: Id|null, patronId?: Id|null, patron_id?: Id|null, patron?: PatronOption|null, pickupLibraryId?: string|null, pickup_library_id?: string|null, itemtypeId?: Id|null, item_type_id?: Id|null, itemtype_id?: Id|null, selectedDateRange?: string[]}} BookingRecord */
/** @typedef {{booking?: BookingRecord, biblionumber?: Id, bookingId?: Id|null, itemId?: Id|null, patronId?: Id|null, patron?: PatronOption|null, pickupLibraryId?: string|null, itemtypeId?: Id|null, selectedDateRange?: string[], dateRangeConstraint?: string|null, customDateRangeFormula?: ((rules: import('@koha-vue/lib/booking/types/bookings').CirculationRule) => number|null)|null, showPatronSelect?: boolean, showItemDetailsSelects?: boolean, showPickupLocationSelect?: boolean}} BookingSessionInput */
/**
 * @typedef {Object} BookingWorkflow
 * @property {(input: BookingSessionInput) => Promise<boolean>} openForCreate
 * @property {(input?: BookingSessionInput) => Promise<boolean>} openForEdit
 * @property {(patron: PatronOption|null) => Promise<boolean>} changePatron
 * @property {(changes?: {itemtypeId?: Id|null, itemId?: Id|null, pickupLibraryId?: string|null}) => Promise<boolean>} changeBookingContext
 * @property {(range: Viewport|null) => Promise<boolean>} changeViewport
 * @property {() => Promise<boolean>} refreshContext
 * @property {() => void} closeSession
 */

/**
 * Explicit booking workflow orchestration.
 *
 * Reactivity in the other store sections derives synchronous form state. This
 * section owns booking-session lifetime and every asynchronous transition that
 * changes the booking context. Each transition is awaitable, aborts the prior
 * transition where possible, and uses a generation guard before publishing
 * defaults or starting dependent requests.
 *
 * @param {WorkflowSections} sections Store sections coordinated by the workflow.
 * @returns {BookingWorkflow} Public asynchronous booking workflow actions.
 */
export function useBookingWorkflow({
    status,
    data,
    draft,
    availability,
    validation,
}) {
    const sessionActive = ref(false);
    const sessionBiblionumber = ref(null);

    let transitionGeneration = 0;
    /** @type {AbortController|null} */
    let transitionController = null;

    /**
     * Start a transition and cancel the previously active transition.
     *
     * @returns {Transition} New transition token.
     */
    function beginTransition() {
        transitionGeneration++;
        transitionController?.abort();
        transitionController = new AbortController();
        return {
            generation: transitionGeneration,
            signal: transitionController.signal,
        };
    }

    /**
     * Return whether a transition may still publish session state.
     *
     * @param {Transition} transition Transition token.
     * @returns {boolean} Whether the transition still owns publication.
     */
    function isCurrentTransition(transition) {
        return (
            sessionActive.value &&
            transition.generation === transitionGeneration &&
            !transition.signal.aborted
        );
    }

    /**
     * Run work owned by one transition.
     *
     * A superseded transport may reject even after its AbortSignal fires.
     * Such failures belong to the old context and must not reach the form's
     * error handler. Current failures still propagate to the caller.
     *
     * @param {Transition} transition Transition token.
     * @param {() => Promise<any>} operation Transition-owned operation.
     * @returns {Promise<any|false>} Operation result, or false when superseded.
     */
    async function runTransition(transition, operation) {
        try {
            return await operation();
        } catch (error) {
            if (!isCurrentTransition(transition)) return false;
            throw error;
        }
    }

    /**
     * Invalidate and clear data derived from a complete booking context.
     *
     * @returns {void}
     */
    function invalidateContextData() {
        data.invalidateRequests(
            "circulationRules",
            "bookingAvailability",
            "holidays"
        );
        data.resetContextData();
    }

    /**
     * Match an externally supplied item ID to the fetched option's type.
     *
     * @returns {void}
     */
    function normalizeSelectedItemId() {
        if (!draft.bookingItemId.value) return;
        const selectedItem = data.bookableItems.value.find(item =>
            idsEqual(item.item_id, draft.bookingItemId.value)
        );
        if (selectedItem) draft.bookingItemId.value = selectedItem.item_id;
    }

    /**
     * Apply the item-derived or sole constrained item-type default once.
     *
     * @returns {void}
     */
    function applyItemTypeDefault() {
        if (draft.bookingItemtypeId.value) return;

        if (draft.bookingItemId.value) {
            const item = data.bookableItems.value.find(candidate =>
                idsEqual(candidate.item_id, draft.bookingItemId.value)
            );
            if (item) {
                draft.bookingItemtypeId.value =
                    item.effective_item_type_id || item.item_type_id || null;
                return;
            }
        }

        const constrainedTypes = availability.constrainedItemTypes.value;
        if (constrainedTypes.length === 1) {
            draft.bookingItemtypeId.value = constrainedTypes[0].item_type_id;
        }
    }

    /**
     * Apply the patron or item pickup-library default once.
     *
     * @returns {void}
     */
    function applyPickupLibraryDefault() {
        const locations = data.pickupLocations.value;
        if (
            draft.pickupLibraryId.value &&
            locations.some(location =>
                idsEqual(location.library_id, draft.pickupLibraryId.value)
            )
        ) {
            return;
        }

        draft.pickupLibraryId.value = null;
        const patronLibrary = draft.bookingPatron.value?.library_id;
        if (
            patronLibrary &&
            locations.some(location =>
                idsEqual(location.library_id, patronLibrary)
            )
        ) {
            draft.pickupLibraryId.value = patronLibrary;
            return;
        }

        const selectedItem = draft.bookingItemId.value
            ? data.bookableItems.value.find(item =>
                  idsEqual(item.item_id, draft.bookingItemId.value)
              )
            : null;
        const itemLibrary =
            selectedItem?.home_library_id ??
            data.bookableItems.value[0]?.home_library_id;
        if (
            itemLibrary &&
            locations.some(location =>
                idsEqual(location.library_id, itemLibrary)
            )
        ) {
            draft.pickupLibraryId.value = itemLibrary;
        }
    }

    /**
     * Capture the complete set of values that keys contextual requests.
     *
     * @returns {Object} Stable booking-context snapshot.
     */
    function snapshotCurrentContext() {
        const itemTypeId = draft.bookingItemtypeId.value;
        const patron = draft.bookingPatron.value;
        const viewport = availability.viewport.value;
        return {
            biblionumber: sessionBiblionumber.value,
            patronId: patron?.patron_id ?? null,
            patronCategoryId: patron?.category_id ?? null,
            itemTypeId,
            itemId: draft.bookingItemId.value,
            pickupLibraryId: draft.pickupLibraryId.value,
            bookingId: draft.bookingId.value,
            viewport: viewport
                ? {
                      start: new Date(viewport.start),
                      end: new Date(viewport.end),
                  }
                : null,
            dateRangeConstraint: availability.dateRangeConstraint.value,
            customDateRangeFormula: availability.customDateRangeFormula.value,
        };
    }

    /**
     * Return whether contextual rules and availability can be requested.
     *
     * @param {Object} context Booking-context snapshot.
     * @returns {boolean} Whether all required context fields are present.
     */
    function hasCompleteContext(context) {
        return !!(
            context.biblionumber &&
            context.patronId &&
            context.patronCategoryId &&
            context.pickupLibraryId
        );
    }

    /**
     * Build the buffered availability range for a stable context snapshot.
     *
     * @param {Viewport|null} viewport Visible calendar range.
     * @param {number|null} maxPeriod Maximum booking length.
     * @returns {{from: string, to: string}} Buffered API date window.
     */
    function computeAvailabilityWindow(viewport, maxPeriod) {
        const today = new Date();
        const start = viewport?.start ?? today;
        const end = viewport?.end ?? addDays(today, DEFAULT_LOOKAHEAD_DAYS);
        let from = addDays(start, -CALENDAR_BUFFER_DAYS);
        let to = addDays(
            end,
            CALENDAR_BUFFER_DAYS + (maxPeriod && maxPeriod > 0 ? maxPeriod : 0)
        );
        if (to.diff(from, "day") > 366) {
            to = addDays(from, 366);
        }
        return { from: formatYMD(from), to: formatYMD(to) };
    }

    /**
     * Refresh rules, availability, and holidays for one stable snapshot.
     *
     * @param {Transition} transition Transition token.
     * @param {{includeRules?: boolean}} [options] Refresh options.
     * @returns {Promise<boolean>} Whether the refreshed snapshot is current.
     */
    async function runContextRefresh(transition, { includeRules = true } = {}) {
        const context = snapshotCurrentContext();
        if (!hasCompleteContext(context)) {
            invalidateContextData();
            return false;
        }

        let rules = data.circulationRules.value;
        if (includeRules) {
            data.invalidateCalculatedDue();
            rules = await data.fetchCirculationRules(
                {
                    patron_category_id: context.patronCategoryId,
                    item_type_id: context.itemTypeId,
                    library_id: context.pickupLibraryId,
                },
                { signal: transition.signal }
            );
            if (!isCurrentTransition(transition)) return false;
        }

        const maxPeriod = calculateMaxBookingPeriod(
            rules,
            context.dateRangeConstraint,
            context.customDateRangeFormula
        );
        const range = computeAvailabilityWindow(context.viewport, maxPeriod);
        const params = {
            from_date: range.from,
            to_date: range.to,
            pickup_library_id: context.pickupLibraryId,
            ...(context.itemTypeId ? { item_type_id: context.itemTypeId } : {}),
            ...(context.itemId ? { item_id: context.itemId } : {}),
            ...(context.patronId ? { patron_id: context.patronId } : {}),
            ...(context.bookingId
                ? { excluded_booking_id: context.bookingId }
                : {}),
        };

        await Promise.all([
            data.fetchBookingAvailability(context.biblionumber, params, {
                signal: transition.signal,
            }),
            data.ensureHolidays(context.pickupLibraryId, range.from, range.to, {
                signal: transition.signal,
            }),
        ]);
        return isCurrentTransition(transition);
    }

    /**
     * Retry all contextual resources for the current draft.
     *
     * @returns {Promise<boolean>} Whether the refreshed snapshot is current.
     */
    function refreshContext() {
        const transition = beginTransition();
        return runTransition(transition, () => runContextRefresh(transition));
    }

    /**
     * Initialize a complete create or edit booking session.
     *
     * @param {BookingSessionInput} input Initial booking configuration.
     * @returns {Promise<boolean>} Whether initialization completed while current.
     */
    async function initializeSession(input) {
        closeSession();
        sessionActive.value = true;
        sessionBiblionumber.value = input.biblionumber
            ? String(input.biblionumber)
            : null;
        availability.configureConstraints({
            dateRangeConstraint: input.dateRangeConstraint ?? null,
            customDateRangeFormula: input.customDateRangeFormula ?? null,
        });
        validation.configureForm({
            patronSelectionRequired: input.showPatronSelect ?? false,
            itemSelectionEnabled: input.showItemDetailsSelects ?? false,
            pickupLocationSelectionRequired:
                input.showPickupLocationSelect ?? false,
        });

        draft.bookingId.value = input.bookingId ?? null;
        draft.bookingItemId.value = input.itemId ?? null;
        draft.bookingPatron.value = input.patron ?? null;
        draft.bookingItemtypeId.value = input.itemtypeId ?? null;
        draft.pickupLibraryId.value = input.pickupLibraryId ?? null;
        draft.selectedDateRange.value = input.selectedDateRange || [];

        const transition = beginTransition();
        const biblionumber = sessionBiblionumber.value;
        if (!biblionumber) return false;

        return runTransition(transition, async () => {
            const patronId = input.patronId ?? input.patron?.patron_id ?? null;
            const requests = [
                data.fetchBookableItems(biblionumber, input.itemId, {
                    signal: transition.signal,
                }),
            ];
            if (patronId) {
                if (!input.patron) {
                    requests.push(
                        data.fetchPatron(patronId, {
                            signal: transition.signal,
                        })
                    );
                }
                requests.push(
                    data.fetchPickupLocations(biblionumber, patronId, {
                        signal: transition.signal,
                    })
                );
            }

            const results = await Promise.all(requests);
            if (!isCurrentTransition(transition)) return false;

            normalizeSelectedItemId();
            data.deriveItemTypesFromBookableItems();
            if (patronId && !input.patron) {
                draft.bookingPatron.value = results[1];
            }
            applyPickupLibraryDefault();
            applyItemTypeDefault();
            return runContextRefresh(transition);
        });
    }

    /**
     * Open and fully initialize a create-booking session.
     *
     * @param {BookingSessionInput} input Initial booking configuration.
     * @returns {Promise<boolean>} Whether initialization completed while current.
     */
    function openForCreate(input) {
        return initializeSession(input || {});
    }

    /**
     * Open and fully initialize an edit-booking session.
     *
     * @param {BookingSessionInput} [input] Existing booking configuration.
     * @returns {Promise<boolean>} Whether initialization completed while current.
     */
    function openForEdit({ booking, ...options } = {}) {
        const record = booking || {};
        return initializeSession({
            ...options,
            biblionumber:
                record.biblionumber ?? record.biblio_id ?? options.biblionumber,
            bookingId: record.bookingId ?? record.booking_id,
            itemId: record.itemId ?? record.item_id,
            patronId: record.patronId ?? record.patron_id,
            patron: record.patron ?? options.patron,
            pickupLibraryId: record.pickupLibraryId ?? record.pickup_library_id,
            itemtypeId:
                record.itemtypeId ?? record.item_type_id ?? record.itemtype_id,
            selectedDateRange:
                record.selectedDateRange ?? options.selectedDateRange,
        });
    }

    /**
     * Change patron, reload pickup locations, apply defaults, and refresh.
     *
     * @param {PatronOption|null} patron Selected patron.
     * @returns {Promise<boolean>} Whether the refreshed transition is current.
     */
    function changePatron(patron) {
        const transition = beginTransition();
        data.invalidateRequests("pickupLocations");
        data.pickupLocations.value = [];
        invalidateContextData();
        draft.bookingPatron.value = patron || null;
        draft.pickupLibraryId.value = null;
        status.clearError();

        if (!patron?.patron_id || !sessionBiblionumber.value) {
            data.pickupLocations.value = [];
            invalidateContextData();
            return Promise.resolve(false);
        }

        return runTransition(transition, async () => {
            await data.fetchPickupLocations(
                sessionBiblionumber.value,
                patron.patron_id,
                { signal: transition.signal }
            );
            if (!isCurrentTransition(transition)) return false;
            applyPickupLibraryDefault();
            applyItemTypeDefault();
            return runContextRefresh(transition);
        });
    }

    /**
     * Apply item and library changes as one transaction and refresh context.
     *
     * @param {{itemtypeId?: Id|null, itemId?: Id|null, pickupLibraryId?: string|null}} [changes]
     * Changed context fields.
     * @returns {Promise<boolean>} Whether the refreshed transition is current.
     */
    function changeBookingContext(changes = {}) {
        const transition = beginTransition();
        invalidateContextData();
        if (Object.prototype.hasOwnProperty.call(changes, "itemtypeId")) {
            draft.bookingItemtypeId.value = changes.itemtypeId;
        }
        if (Object.prototype.hasOwnProperty.call(changes, "itemId")) {
            draft.bookingItemId.value = changes.itemId;
        }
        if (Object.prototype.hasOwnProperty.call(changes, "pickupLibraryId")) {
            draft.pickupLibraryId.value = changes.pickupLibraryId;
        }
        status.clearError();
        applyItemTypeDefault();
        return runTransition(transition, () => runContextRefresh(transition));
    }

    /**
     * Change the calendar viewport and refresh its remote date coverage.
     *
     * @param {Viewport|null} range Visible calendar range.
     * @returns {Promise<boolean>} Whether the refreshed transition is current.
     */
    async function changeViewport(range) {
        availability.setViewport(range);
        if (!sessionActive.value) return false;

        const context = snapshotCurrentContext();
        if (!hasCompleteContext(context)) return false;
        const rulesContext = data.circulationRulesContext.value;
        const rulesAreCurrent = !!(
            rulesContext &&
            idsEqual(
                rulesContext.patron_category_id,
                context.patronCategoryId
            ) &&
            idsEqual(rulesContext.item_type_id, context.itemTypeId) &&
            idsEqual(rulesContext.library_id, context.pickupLibraryId)
        );
        const transition = beginTransition();
        return runTransition(transition, () =>
            runContextRefresh(transition, {
                includeRules: !rulesAreCurrent,
            })
        );
    }

    /**
     * Abort work and clear all state whose lifetime is the booking session.
     *
     * @returns {void}
     */
    function closeSession() {
        transitionGeneration++;
        transitionController?.abort();
        transitionController = null;
        sessionActive.value = false;
        sessionBiblionumber.value = null;
        data.invalidateRequests(
            "bookableItems",
            "bookingPatron",
            "pickupLocations",
            "circulationRules",
            "bookingAvailability",
            "holidays"
        );
        data.resetSessionData();
        draft.resetDraft();
        availability.setViewport(null);
        availability.configureConstraints();
        validation.configureForm({
            patronSelectionRequired: false,
            itemSelectionEnabled: false,
            pickupLocationSelectionRequired: false,
        });
        status.clearError();
    }

    return {
        openForCreate,
        openForEdit,
        changePatron,
        changeBookingContext,
        changeViewport,
        refreshContext,
        closeSession,
    };
}
