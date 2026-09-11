import { ref } from "vue";
import * as bookingApi from "@bookingApi";
import { $__ } from "@koha-vue/i18n";
import { addDays, addMonths, formatYMD } from "../../lib/booking/dates.js";
import { idsEqual } from "../../utils/functions.js";
import { patronToOption } from "../../utils/patron-options.js";

const PATRON_OPTION_CONFIG = { invertName: true, displayCardnumber: true };

const HOLIDAY_PREFETCH_THRESHOLD_DAYS = 60;
const HOLIDAY_PREFETCH_MONTHS = 6;

/** @typedef {import('@koha-vue/lib/booking/types/bookings').BookableItem} BookableItem */
/** @typedef {import('@koha-vue/lib/booking/types/bookings').BookingAvailabilityResponse} BookingAvailabilityResponse */
/** @typedef {import('@koha-vue/lib/booking/types/bookings').CirculationRule} CirculationRule */
/** @typedef {import('@koha-vue/lib/booking/types/bookings').Id} Id */
/** @typedef {import('@koha-vue/lib/booking/types/bookings').ItemType} ItemType */
/** @typedef {import('@koha-vue/lib/booking/types/bookings').PatronOption} PatronOption */
/** @typedef {import('@koha-vue/lib/booking/types/bookings').PickupLocation} PickupLocation */
/** @typedef {{patron_category_id: Id|null, item_type_id: Id|null, library_id: string|null}} RulesContext */

/**
 * Normalize a patron search response for the booking selector.
 *
 * @param {Array<Object>|{results?: Array<Object>}|null|undefined} data Patron search response.
 * @returns {PatronOption[]} Adapted patron options.
 */
function transformPatronsData(data) {
    const patrons = Array.isArray(data) ? data : data?.results || [];
    return patrons.map(patron => patronToOption(patron, PATRON_OPTION_CONFIG));
}

/**
 * Build a withErrorHandling HOF bound to a section's reactive `loading`
 * map. Wraps an async operation with set-loading / always-clear-loading,
 * eliminating the per-action try/finally boilerplate. Errors propagate to
 * the caller, which surfaces them via `setError`/`formatApiError`.
 *
 * @param {Record<string, boolean>} loading - Reactive loading-flag map
 * @returns {<F extends (...args: any[]) => Promise<any>>(operation: F, loadingKey: string) => F}
 * Operation wrapper bound to the loading map.
 */
function makeWithErrorHandling(loading) {
    /** @type {Record<string, number>} Number of active requests per key. */
    const pendingRequests = Object.create(null);

    /**
     * @template {(...args: any[]) => Promise<any>} F
     * @param {F} operation
     * @param {string} loadingKey
     * @returns {F}
     */
    function withErrorHandling(operation, loadingKey) {
        /**
         * Run an operation while maintaining its shared loading counter.
         *
         * @param {...Parameters<F>} args Operation arguments.
         * @returns {Promise<Awaited<ReturnType<F>>>} Operation result.
         */
        const wrapped = async function (...args) {
            pendingRequests[loadingKey] =
                (pendingRequests[loadingKey] || 0) + 1;
            loading[loadingKey] = true;
            try {
                return await operation(...args);
            } finally {
                pendingRequests[loadingKey]--;
                loading[loadingKey] = pendingRequests[loadingKey] > 0;
            }
        };
        return /** @type {F} */ (wrapped);
    }
    return withErrorHandling;
}

/**
 * Data section: collections fetched from the API and the actions that
 * fetch / mutate them.
 *
 * State:
 *  - bookableItems, bookingAvailability, pickupLocations, itemTypes,
 *    circulationRules, holidays — domain collections.
 *  - circulationRulesContext and the availability/holiday coverage
 *    bookkeeping decide whether a refetch is needed.
 *
 * @typedef {Object} DataSection
 * @property {import('vue').Ref<BookableItem[]>} bookableItems
 * @property {import('vue').Ref<BookingAvailabilityResponse|null>} bookingAvailability
 * @property {import('vue').Ref<boolean>} bookingAvailabilityError Whether the most recent (non-superseded) availability fetch failed, leaving bookingAvailability stale.
 * @property {import('vue').Ref<PickupLocation[]>} pickupLocations
 * @property {import('vue').Ref<ItemType[]>} itemTypes
 * @property {import('vue').Ref<CirculationRule[]>} circulationRules
 * @property {import('vue').Ref<RulesContext|null>} circulationRulesContext
 * @property {import('vue').Ref<string[]>} holidays Closed dates for the pickup library.
 * @property {(...resources: string[]) => void} invalidateRequests
 * @property {() => void} invalidateCalculatedDue
 * @property {() => void} resetContextData
 * @property {() => void} resetSessionData
 * @property {(biblionumber: Id, assignedItemId?: Id|null, options?: Object) => Promise<BookableItem[]>} fetchBookableItems
 * @property {(biblionumber: Id, params: Object, options?: {signal?: AbortSignal}) => Promise<BookingAvailabilityResponse|null>} fetchBookingAvailability
 * @property {(patronId: Id, options?: Object) => Promise<PatronOption|null>} fetchPatron
 * @property {(term: string, page?: number) => Promise<PatronOption[]>} fetchPatrons
 * @property {(biblionumber: Id, patron_id: Id, options?: Object) => Promise<PickupLocation[]>} fetchPickupLocations
 * @property {(params: Object, options?: Object) => Promise<CirculationRule[]>} fetchCirculationRules
 * @property {(libraryId: string|null, from: Date|string, to: Date|string, options?: Object) => Promise<string[]>} ensureHolidays
 * @property {() => void} deriveItemTypesFromBookableItems
 * @property {(bookingData: Object) => Promise<Object>} saveOrUpdateBooking
 *
 * @param {{status: {loading: Record<string, boolean>}}} sections Store sections used by remote data actions.
 * @returns {DataSection}
 */
export function useDataSection({ status }) {
    const withErrorHandling = makeWithErrorHandling(status.loading);
    const requestGenerations = Object.create(null);

    /**
     * Start a new request generation for a remotely populated resource.
     * Responses may be cached, but only the latest generation may publish
     * state for that resource.
     *
     * @param {string} resource
     * @returns {number}
     */
    function beginRequest(resource) {
        requestGenerations[resource] = (requestGenerations[resource] || 0) + 1;
        return requestGenerations[resource];
    }

    /**
     * @param {string} resource
     * @param {number} generation
     * @returns {boolean}
     */
    function isCurrentRequest(resource, generation) {
        return requestGenerations[resource] === generation;
    }

    /**
     * Invalidate in-flight requests when their context disappears without a
     * replacement request (for example, patron clearance or session close).
     *
     * @param {...string} resources
     * @returns {void}
     */
    function invalidateRequests(...resources) {
        resources.forEach(beginRequest);
    }

    /** @type {import('vue').Ref<BookableItem[]>} */
    const bookableItems = ref([]);
    /** @type {import('vue').Ref<BookingAvailabilityResponse|null>} Raw availability payload. */
    const bookingAvailability = ref(null);
    /**
     * True when the most recent (non-superseded) booking-availability fetch
     * failed. bookingAvailability deliberately keeps serving the previous
     * context's payload across refetches (see fetchBookingAvailability), so
     * consumers that gate calendar interactivity on data being present must
     * also check this flag to avoid treating stale, unconfirmed availability
     * as current.
     * @type {import('vue').Ref<boolean>}
     */
    const bookingAvailabilityError = ref(false);
    /** Bumped on writes so pre-write responses and cache entries become stale. */
    let bookingAvailabilityVersion = 0;
    /** @type {Map<string, BookingAvailabilityResponse>} Availability payloads keyed by fetch context. */
    const bookingAvailabilityCache = new Map();
    /** @type {import('vue').Ref<PickupLocation[]>} */
    const pickupLocations = ref([]);
    /** @type {import('vue').Ref<ItemType[]>} */
    const itemTypes = ref([]);
    /** @type {import('vue').Ref<CirculationRule[]>} */
    const circulationRules = ref([]);
    /** @type {import('vue').Ref<RulesContext|null>} Last rules-fetch context. */
    const circulationRulesContext = ref(null);
    /** @type {import('vue').Ref<string[]>} Closed days for the selected pickup library */
    const holidays = ref([]);
    /** Range already fetched per library, so paging only fetches the uncovered remainder */
    const holidaysCovered = { from: null, to: null, libraryId: null };

    /**
     * Invalidate stale backend-calculated due values when
     * inputs change. Keeps the rules object shape but removes
     * calculated fields so consumers fall back to maxPeriod-based logic
     * until fresh rules arrive.
     *
     * @returns {void}
     */
    function invalidateCalculatedDue() {
        if (
            Array.isArray(circulationRules.value) &&
            circulationRules.value.length > 0
        ) {
            const first = { ...circulationRules.value[0] };
            if ("calculated_due_date" in first)
                delete first.calculated_due_date;
            if ("calculated_period_days" in first)
                delete first.calculated_period_days;
            circulationRules.value = [first];
        }
    }

    /**
     * Fetch bookable items and merge the assigned edit item when necessary.
     *
     * @param {Id} biblionumber Biblio identifier.
     * @param {Id|null} [assignedItemId] Assigned item retained during edit.
     * @param {Object} [options] Request options passed to the transport.
     * @returns {Promise<BookableItem[]>} Bookable and retained items.
     */
    const fetchBookableItems = withErrorHandling(async function (
        biblionumber,
        assignedItemId = null,
        options = {}
    ) {
        const generation = beginRequest("bookableItems");
        try {
            const result = await bookingApi.fetchBookableItems(
                biblionumber,
                options
            );
            if (
                assignedItemId != null &&
                assignedItemId !== "" &&
                !result.some(item => idsEqual(item.item_id, assignedItemId))
            ) {
                const assignedItems = await bookingApi.fetchAssignedItem(
                    biblionumber,
                    assignedItemId,
                    options
                );
                const seen = new Set(result.map(item => String(item.item_id)));
                result.push(
                    ...assignedItems.filter(
                        item => !seen.has(String(item.item_id))
                    )
                );
            }
            if (isCurrentRequest("bookableItems", generation)) {
                bookableItems.value = result;
            }
            return result;
        } catch (error) {
            if (!isCurrentRequest("bookableItems", generation)) {
                return bookableItems.value;
            }
            throw error;
        }
    }, "bookableItems");

    const AVAILABILITY_CACHE_MAX = 24;

    /**
     * Fetch and cache the booking-availability window for one context.
     *
     * @param {Id} biblionumber Biblio identifier.
     * @param {Object} params Availability request parameters.
     * @param {{signal?: AbortSignal}} [options] Transport request options.
     * @returns {Promise<BookingAvailabilityResponse|null>} Current availability response.
     */
    const fetchBookingAvailability = withErrorHandling(async function (
        biblionumber,
        params,
        options = {}
    ) {
        const generation = beginRequest("bookingAvailability");
        const cacheVersion = bookingAvailabilityVersion;
        const key =
            cacheVersion + "|" + biblionumber + "|" + JSON.stringify(params);
        if (bookingAvailabilityCache.has(key)) {
            const cached = bookingAvailabilityCache.get(key);
            if (isCurrentRequest("bookingAvailability", generation)) {
                bookingAvailability.value = cached;
                bookingAvailabilityError.value = false;
            }
            return cached;
        }

        try {
            const result = await bookingApi.fetchBookingAvailability(
                biblionumber,
                params,
                options
            );
            if (bookingAvailabilityVersion === cacheVersion) {
                bookingAvailabilityCache.set(key, result);
                if (bookingAvailabilityCache.size > AVAILABILITY_CACHE_MAX) {
                    const oldest = bookingAvailabilityCache.keys().next().value;
                    bookingAvailabilityCache.delete(oldest);
                }
            }
            if (
                bookingAvailabilityVersion === cacheVersion &&
                isCurrentRequest("bookingAvailability", generation)
            ) {
                bookingAvailabilityError.value = false;
                bookingAvailability.value = result;
            }
            return result;
        } catch (error) {
            if (!isCurrentRequest("bookingAvailability", generation)) {
                return bookingAvailability.value;
            }
            bookingAvailabilityError.value = true;
            throw error;
        }
    }, "bookingAvailability");

    /**
     * Drop all cached availability windows after a write. The version keeps
     * an older in-flight response from repopulating or publishing stale data.
     *
     * @returns {void}
     */
    function invalidateBookingAvailability() {
        bookingAvailabilityCache.clear();
        bookingAvailabilityVersion++;
        invalidateRequests("bookingAvailability");
    }

    /**
     * Fetch and adapt the patron selected for the booking.
     *
     * @param {Id} patronId Patron identifier.
     * @param {Object} [options] Request options passed to the transport.
     * @returns {Promise<PatronOption|null>} Adapted patron.
     */
    const fetchPatron = withErrorHandling(async function (
        patronId,
        options = {}
    ) {
        const generation = beginRequest("bookingPatron");
        try {
            const result = await bookingApi.fetchPatron(patronId, options);
            return patronToOption(
                Array.isArray(result) ? result[0] : result,
                PATRON_OPTION_CONFIG
            );
        } catch (error) {
            if (!isCurrentRequest("bookingPatron", generation)) return null;
            throw error;
        }
    }, "bookingPatron");

    /**
     * Search and adapt patrons for the booking selector.
     *
     * @param {string} term Patron search term.
     * @param {number} [page] Result page.
     * @returns {Promise<PatronOption[]>} Adapted patron options.
     */
    const fetchPatrons = withErrorHandling(async function (term, page = 1) {
        const data = await bookingApi.fetchPatrons(term, page);
        return transformPatronsData(data);
    }, "patrons");

    /**
     * Fetch pickup locations for the current biblio and patron.
     *
     * @param {Id} biblionumber Biblio identifier.
     * @param {Id} patron_id Patron identifier.
     * @param {Object} [options] Request options passed to the transport.
     * @returns {Promise<PickupLocation[]>} Pickup locations.
     */
    const fetchPickupLocations = withErrorHandling(async function (
        biblionumber,
        patron_id,
        options = {}
    ) {
        const generation = beginRequest("pickupLocations");
        try {
            const result = await bookingApi.fetchPickupLocations(
                biblionumber,
                patron_id,
                options
            );
            if (isCurrentRequest("pickupLocations", generation)) {
                pickupLocations.value = result;
            }
            return result;
        } catch (error) {
            if (!isCurrentRequest("pickupLocations", generation)) {
                return pickupLocations.value;
            }
            throw error;
        }
    }, "pickupLocations");

    /**
     * Fetch circulation rules for the current booking context.
     *
     * @param {Object} params Circulation-rule query parameters.
     * @param {Object} [options] Request options passed to the transport.
     * @returns {Promise<CirculationRule[]>} Matching rules.
     */
    const fetchCirculationRules = withErrorHandling(async function (
        params,
        options = {}
    ) {
        const generation = beginRequest("circulationRules");
        // Only include defined (non-null, non-undefined, non-empty) params.
        // The rule set is a workflow/domain default rather than a transport
        // concern shared by every interface adapter.
        const filteredParams = {};
        for (const key in params) {
            if (
                params[key] !== null &&
                params[key] !== undefined &&
                params[key] !== ""
            ) {
                filteredParams[key] = params[key];
            }
        }
        if (!filteredParams.rules) {
            filteredParams.rules =
                "bookings_lead_period,bookings_trail_period,issuelength,renewalsallowed,renewalperiod";
        }
        try {
            const result = await bookingApi.fetchCirculationRules(
                filteredParams,
                options
            );
            if (isCurrentRequest("circulationRules", generation)) {
                circulationRules.value = result;
                circulationRulesContext.value = {
                    patron_category_id:
                        filteredParams.patron_category_id ?? null,
                    item_type_id: filteredParams.item_type_id ?? null,
                    library_id: filteredParams.library_id ?? null,
                };
            }
            return result;
        } catch (error) {
            if (!isCurrentRequest("circulationRules", generation)) {
                return circulationRules.value;
            }
            throw error;
        }
    }, "circulationRules");

    /**
     * Make sure closed-day data covers [from, to] for the library. Only
     * the uncovered remainder is fetched, padded forward by the prefetch
     * margin so month-by-month paging stays ahead of the network;
     * results accumulate across calls. A falsy library clears the data.
     *
     * @param {string|null} libraryId Pickup library identifier.
     * @param {Date|string} from First visible date.
     * @param {Date|string} to Last visible date.
     * @param {Object} [options] Request options passed to the transport.
     * @returns {Promise<string[]>} Covered closed dates.
     */
    const ensureHolidays = withErrorHandling(async function (
        libraryId,
        from,
        to,
        options = {}
    ) {
        const generation = beginRequest("holidays");
        if (!libraryId) {
            holidays.value = [];
            Object.assign(holidaysCovered, {
                from: null,
                to: null,
                libraryId: null,
            });
            return [];
        }

        if (holidaysCovered.libraryId !== libraryId) {
            holidays.value = [];
            Object.assign(holidaysCovered, { from: null, to: null, libraryId });
        }

        // YYYY-MM-DD strings compare lexicographically. The want-window
        // extends past `to` by the threshold so coverage is renewed
        // before the visible range reaches the fetched edge.
        const wantFrom = formatYMD(from);
        const wantTo = formatYMD(addDays(to, HOLIDAY_PREFETCH_THRESHOLD_DAYS));
        const { from: haveFrom, to: haveTo } = holidaysCovered;
        if (haveFrom && haveFrom <= wantFrom && haveTo >= wantTo) {
            return holidays.value;
        }

        const fetchFrom = haveFrom && haveFrom < wantFrom ? haveFrom : wantFrom;
        const prefetchTo = formatYMD(addMonths(to, HOLIDAY_PREFETCH_MONTHS));
        const fetchTo = haveTo && haveTo > prefetchTo ? haveTo : prefetchTo;

        const segments = !haveFrom
            ? [[fetchFrom, fetchTo]]
            : [
                  ...(fetchFrom < haveFrom
                      ? [[fetchFrom, formatYMD(addDays(haveFrom, -1))]]
                      : []),
                  ...(fetchTo > haveTo
                      ? [[formatYMD(addDays(haveTo, 1)), fetchTo]]
                      : []),
              ];

        // The closed-dates endpoint caps ranges at 365 days
        const slices = segments.flatMap(([f, t]) => {
            const out = [];
            for (let s = f; s <= t; ) {
                const e = formatYMD(addDays(s, 350));
                out.push([s, e < t ? e : t]);
                s = formatYMD(addDays(e < t ? e : t, 1));
            }
            return out;
        });

        try {
            const results = await Promise.all(
                slices.map(([f, t]) =>
                    bookingApi.fetchHolidays(libraryId, f, t, options)
                )
            );
            if (isCurrentRequest("holidays", generation)) {
                const merged = new Set(holidays.value);
                results.flat().forEach(date => merged.add(date));
                holidays.value = Array.from(merged).sort();
                Object.assign(holidaysCovered, {
                    from: fetchFrom,
                    to: fetchTo,
                });
            }
        } catch (error) {
            if (!isCurrentRequest("holidays", generation)) {
                return holidays.value;
            }
            throw error;
        }

        return holidays.value;
    }, "holidays");

    /**
     * Clear remotely derived state for the current booking context.
     *
     * @returns {void}
     */
    function resetContextData() {
        bookingAvailability.value = null;
        bookingAvailabilityError.value = false;
        circulationRules.value = [];
        circulationRulesContext.value = null;
        holidays.value = [];
        Object.assign(holidaysCovered, {
            from: null,
            to: null,
            libraryId: null,
        });
    }

    /**
     * Clear data whose lifetime is the current booking session. The
     * availability cache is retained because every entry is fully keyed by
     * biblio and request parameters.
     *
     * @returns {void}
     */
    function resetSessionData() {
        bookableItems.value = [];
        pickupLocations.value = [];
        itemTypes.value = [];
        resetContextData();
    }

    /**
     * Derive unique item-type selector options from fetched items.
     *
     * @returns {void}
     */
    function deriveItemTypesFromBookableItems() {
        const typesMap = {};
        bookableItems.value.forEach(item => {
            const typeId = item.effective_item_type_id || item.item_type_id;
            if (typeId) {
                const label = item._strings?.item_type_id?.str ?? typeId;
                typesMap[typeId] = label;
            }
        });
        itemTypes.value = Object.entries(typesMap).map(
            ([item_type_id, description]) => ({ item_type_id, description })
        );
    }

    /**
     * Validate write inputs at the shared workflow boundary.
     *
     * @param {Object} bookingData Booking API payload.
     * @returns {Id|null} Existing booking identifier for updates.
     */
    function validateBookingWrite(bookingData) {
        if (!bookingData || typeof bookingData !== "object") {
            throw new Error($__("Booking data is required"));
        }
        const bookingId = bookingData.bookingId || bookingData.booking_id;
        if (bookingId) return bookingId;

        const requiredFields = [
            "start_date",
            "end_date",
            "biblio_id",
            "patron_id",
            "pickup_library_id",
        ];
        const missing = requiredFields.filter(
            field => bookingData[field] == null || bookingData[field] === ""
        );
        if (missing.length) {
            throw new Error(
                $__("Missing required fields: %s").format(missing.join(", "))
            );
        }
        return null;
    }

    /**
     * Save (POST) or update (PUT) a booking. If the payload carries a
     * booking id we update; otherwise we create.
     *
     * @param {Object} bookingData Validated booking API payload.
     * @returns {Promise<Object>} Saved booking representation.
     */
    const saveOrUpdateBooking = withErrorHandling(async function (bookingData) {
        const bookingId = validateBookingWrite(bookingData);
        let result;
        if (bookingId) {
            result = await bookingApi.updateBooking(bookingId, bookingData);
        } else {
            result = await bookingApi.createBooking(bookingData);
        }
        invalidateBookingAvailability();
        return result;
    }, "submit");

    return {
        bookableItems,
        bookingAvailability,
        bookingAvailabilityError,
        pickupLocations,
        itemTypes,
        circulationRules,
        circulationRulesContext,
        holidays,

        invalidateRequests,
        invalidateCalculatedDue,
        resetContextData,
        resetSessionData,
        fetchBookableItems,
        fetchBookingAvailability,
        fetchPatron,
        fetchPatrons,
        fetchPickupLocations,
        fetchCirculationRules,
        ensureHolidays,
        deriveItemTypesFromBookableItems,
        saveOrUpdateBooking,
    };
}
