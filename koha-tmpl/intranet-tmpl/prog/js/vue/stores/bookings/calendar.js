import { ref, computed } from "vue";
import { useBookingCalendarMaps } from "../../lib/booking/composables/useBookingCalendarMaps.js";
import { calculateMaxBookingPeriod } from "../../lib/booking/availability/predicate.js";
import {
    constrainBookableItems,
    constrainItemTypes,
    constrainPickupLocations,
} from "../../lib/booking/constraints.js";

/**
 * Availability section: derived view of the world based on Data + Draft.
 *
 * Owns the picker viewport, constraint configuration, and the
 * calendar-map outputs (disabledFn / disabledByDate / markersByDate /
 * classByDate / rangePreviewFn / unavailableByDate)
 * produced by useBookingCalendarMaps from the server availability map.
 *
 * Inputs that originate outside the store:
 *  - viewport: the picker's currently-visible month range; the period step
 *    pushes it via setViewport when the user paginates, and the workflow
 *    section refreshes the availability window from it
 *  - dateRangeConstraint, customDateRangeFormula: session configuration
 *    registered and reset by the workflow section
 *
 * @typedef {Object} BookingCalendarState
 * @property {import('vue').Ref<{start: Date, end: Date}|null>} viewport
 * @property {import('vue').Ref<string|null>} dateRangeConstraint
 * @property {import('vue').Ref<((rules: import('@koha-vue/lib/booking/types/bookings').CirculationRule) => number|null)|null>} customDateRangeFormula
 * @property {import('vue').ComputedRef<number|null>} maxBookingPeriod
 * @property {import('vue').ComputedRef<{pickupLocations: boolean, bookableItems: boolean, itemTypes: boolean}>} constrainedFlags
 * @property {import('vue').ComputedRef<import('@koha-vue/lib/booking/types/bookings').PickupLocation[]>} constrainedPickupLocations
 * @property {import('vue').ComputedRef<import('@koha-vue/lib/booking/types/bookings').BookableItem[]>} constrainedBookableItems
 * @property {import('vue').ComputedRef<import('@koha-vue/lib/booking/types/bookings').ItemType[]>} constrainedItemTypes
 * @property {import('vue').ComputedRef<number>} pickupLocationsFilteredOut
 * @property {import('vue').ComputedRef<number>} pickupLocationsTotal
 * @property {import('vue').ComputedRef<number>} bookableItemsFilteredOut
 * @property {import('vue').ComputedRef<number>} bookableItemsTotal
 * @property {import('vue').ComputedRef<(date: Date) => boolean>} disabledFn
 * @property {import('vue').ComputedRef<Map<string, {reason: string, severity: "hard"|"soft"}>>} disabledByDate
 * @property {import('vue').ComputedRef<Map<string, Array<{kind: string, className: string, tooltip?: string}>>>} markersByDate
 * @property {import('vue').ComputedRef<Map<string, string>>} classByDate
 * @property {import('vue').ComputedRef<string[]>} relevantItemIds
 * @property {import('vue').ComputedRef<{leadDays: number, trailDays: number}>} bufferConfig
 * @property {import('vue').ComputedRef<import('@koha-vue/lib/booking/types/bookings').UnavailableByDate>} unavailableByDate
 * @property {(range: {start: Date, end: Date}|null) => void} setViewport
 * @property {(opts?: {dateRangeConstraint?: string|null, customDateRangeFormula?: ((rules: import('@koha-vue/lib/booking/types/bookings').CirculationRule) => number|null)|null}) => void} configureConstraints
 *
 * @param {{data: Object, draft: Object}} sections Data and draft store sections.
 * @returns {BookingCalendarState} Calendar state, constraints, and actions.
 */
export function useBookingCalendarState({ data, draft }) {
    /** @type {import('vue').Ref<{ start: Date, end: Date } | null>} */
    const viewport = ref(null);

    /** @type {import('vue').Ref<string | null>} */
    const dateRangeConstraint = ref(null);

    /** @type {import('vue').Ref<((rules: import('@koha-vue/lib/booking/types/bookings').CirculationRule) => number | null) | null>} */
    const customDateRangeFormula = ref(null);

    /**
     * Push the picker's currently-visible month range. Pass `null` to
     * clear (e.g., when the picker unmounts). The map computations
     * scope themselves to this window for performance.
     *
     * @param {{start: Date, end: Date}|null} range Visible date range.
     * @returns {void}
     */
    function setViewport(range) {
        viewport.value = range && range.start && range.end ? range : null;
    }

    /**
     * Register the constraint configuration for the lifetime of the
     * current booking session. Both fields are stable per-session; the
     * workflow section sets them during initialization and resets them on
     * close.
     *
     * @param {Object} [opts]
     * @param {string | null} [opts.dateRangeConstraint]
     * @param {((rules: import('@koha-vue/lib/booking/types/bookings').CirculationRule) => number | null) | null} [opts.customDateRangeFormula]
     * @returns {void}
     */
    function configureConstraints(opts) {
        const {
            dateRangeConstraint: drc = null,
            customDateRangeFormula: formula = null,
        } = opts || {};
        dateRangeConstraint.value = drc;
        customDateRangeFormula.value = formula;
    }

    /** @type {import('vue').ComputedRef<number|null>} */
    const maxBookingPeriod = computed(() =>
        calculateMaxBookingPeriod(
            data.circulationRules.value,
            dateRangeConstraint.value,
            customDateRangeFormula.value
        )
    );

    /** @type {import('vue').ComputedRef<import('@koha-vue/lib/booking/types/bookings').ConstraintOptions>} */
    const constraintOptions = computed(() => ({
        dateRangeConstraint: dateRangeConstraint.value,
        maxBookingPeriod: maxBookingPeriod.value,
    }));

    // Constraint filtering of pickup locations / bookable items / item
    // types based on the current draft selections. The three constrain*
    // calls are bundled into a single `constraints` computed so all
    // four downstream views (filtered lists, totals, filtered-out
    // counts, applied flags) share one evaluation per input change.
    const constraints = computed(() => {
        const pickup = constrainPickupLocations(
            data.pickupLocations.value,
            data.bookableItems.value,
            draft.bookingItemtypeId.value,
            draft.bookingItemId.value
        );
        const items = constrainBookableItems(
            data.bookableItems.value,
            data.pickupLocations.value,
            draft.pickupLibraryId.value,
            draft.bookingItemtypeId.value
        );
        const types = constrainItemTypes(
            data.itemTypes.value,
            data.bookableItems.value,
            data.pickupLocations.value,
            draft.pickupLibraryId.value,
            draft.bookingItemId.value
        );
        return {
            pickupLocations: pickup,
            bookableItems: items,
            itemTypes: types,
            flags: {
                pickupLocations: pickup.constraintApplied,
                bookableItems: items.constraintApplied,
                itemTypes: types.constraintApplied,
            },
        };
    });

    /** @type {import('vue').ComputedRef<{ pickupLocations: boolean, bookableItems: boolean, itemTypes: boolean }>} */
    const constrainedFlags = computed(() => constraints.value.flags);
    /** @type {import('vue').ComputedRef<Array<import('@koha-vue/lib/booking/types/bookings').PickupLocation>>} */
    const constrainedPickupLocations = computed(
        () => constraints.value.pickupLocations.filtered
    );
    /** @type {import('vue').ComputedRef<Array<import('@koha-vue/lib/booking/types/bookings').BookableItem>>} */
    const constrainedBookableItems = computed(
        () => constraints.value.bookableItems.filtered
    );
    /** @type {import('vue').ComputedRef<Array<import('@koha-vue/lib/booking/types/bookings').ItemType>>} */
    const constrainedItemTypes = computed(
        () => constraints.value.itemTypes.filtered
    );
    /** @type {import('vue').ComputedRef<number>} */
    const pickupLocationsFilteredOut = computed(
        () => constraints.value.pickupLocations.filteredOutCount
    );
    /** @type {import('vue').ComputedRef<number>} */
    const pickupLocationsTotal = computed(
        () => constraints.value.pickupLocations.total
    );
    /** @type {import('vue').ComputedRef<number>} */
    const bookableItemsFilteredOut = computed(
        () => constraints.value.bookableItems.filteredOutCount
    );
    /** @type {import('vue').ComputedRef<number>} */
    const bookableItemsTotal = computed(
        () => constraints.value.bookableItems.total
    );

    // Composables invoked inside the store's setup run in a Vue
    // reactive context the same as if they were called from a
    // component setup. Their outputs are computed refs that update
    // whenever the input refs change, so consumers reading these via
    // storeToRefs get the same reactivity as before the move.
    const maps = useBookingCalendarMaps({
        bookableItems: data.bookableItems,
        availability: data.bookingAvailability,
        holidays: data.holidays,
        selectedDateRange: draft.selectedDateRange,
        constraintOptions,
        rangeAnchor: draft.rangeAnchor,
        maxBookingPeriod,
        bookingItemId: draft.bookingItemId,
        bookingItemtypeId: draft.bookingItemtypeId,
        circulationRules: data.circulationRules,
    });

    return {
        viewport,
        dateRangeConstraint,
        customDateRangeFormula,
        maxBookingPeriod,

        constrainedFlags,
        constrainedPickupLocations,
        constrainedBookableItems,
        constrainedItemTypes,
        pickupLocationsFilteredOut,
        pickupLocationsTotal,
        bookableItemsFilteredOut,
        bookableItemsTotal,

        disabledFn: maps.disabledFn,
        disabledByDate: maps.disabledByDate,
        markersByDate: maps.markersByDate,
        classByDate: maps.classByDate,
        relevantItemIds: maps.relevantItemIds,
        bufferConfig: maps.bufferConfig,

        unavailableByDate: maps.unavailableByDate,

        setViewport,
        configureConstraints,
    };
}
