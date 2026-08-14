/**
 * @module bookingApi
 * @description Service module for all booking-related API calls.
 * All functions return promises and use async/await.
 */

import { APIClient } from "@koha-vue/fetch/api-client.js";
import { $__ } from "@koha-vue/i18n";

// The adapter's callers present API errors themselves (formatApiError
// -> booking error -> form alert); suppress the HTTP client's page-level
// dialog so failures are not reported twice.
const QUIET = { suppressDefaultErrorDialog: true };

/**
 * Build the shared quiet request configuration with optional cancellation.
 *
 * @param {{signal?: AbortSignal}} [options] Request options.
 * @returns {{suppressDefaultErrorDialog: boolean, signal?: AbortSignal}} HTTP client configuration.
 */
function requestConfig(options = {}) {
    return options.signal ? { ...QUIET, signal: options.signal } : QUIET;
}

/**
 * Fetches bookable items for a given biblionumber
 * @param {import('../../types/bookings').Id} biblionumber Biblio identifier.
 * @param {{signal?: AbortSignal}} [options] Request options.
 * @returns {Promise<import('../../types/bookings').BookableItem[]>} Bookable items.
 * @throws {Error} If the request fails or returns a non-OK status
 */
export function fetchBookableItems(biblionumber, options = {}) {
    return APIClient.biblio.biblios.items(
        encodeURIComponent(biblionumber),
        { bookable: 1 },
        { "x-koha-embed": "+strings,item_type" },
        requestConfig(options)
    );
}

/**
 * Fetch one assigned item so edit workflows can retain it when unbookable.
 *
 * @param {import('../../types/bookings').Id} biblionumber Biblio identifier.
 * @param {import('../../types/bookings').Id} itemId Assigned item identifier.
 * @param {{signal?: AbortSignal}} [options] Request options.
 * @returns {Promise<import('../../types/bookings').BookableItem[]>} Matching assigned items.
 */
export function fetchAssignedItem(biblionumber, itemId, options = {}) {
    return APIClient.biblio.biblios.items(
        encodeURIComponent(biblionumber),
        {},
        { "x-koha-embed": "+strings,item_type" },
        requestConfig(options),
        { item_id: itemId }
    );
}

/**
 * Fetches the booking availability map for a given biblionumber
 * @param {number|string} biblionumber - The biblionumber to fetch availability for
 * @param {Object} params - Query parameters (from, to, pickup_library_id,
 *   item_type_id, patron_id, item_id, excluded_booking_id)
 * @param {{ signal?: AbortSignal }} [options] - Request options
 * @returns {Promise<import('../../types/bookings').BookingAvailabilityResponse>} Availability payload.
 * @throws {Error} If the request fails or returns a non-OK status
 */
export async function fetchBookingAvailability(
    biblionumber,
    params = {},
    options = {}
) {
    return APIClient.biblio.biblios.booking_availability(
        encodeURIComponent(biblionumber),
        params,
        requestConfig(options)
    );
}

/**
 * Fetches a single patron by ID
 * @param {number|string} patronId - The ID of the patron to fetch
 * @param {{ signal?: AbortSignal }} [options] - Request options
 * @returns {Promise<Object>} The patron object
 * @throws {Error} If the request fails or returns a non-OK status
 */
export async function fetchPatron(patronId, options = {}) {
    return APIClient.patron.patrons.get(
        encodeURIComponent(patronId),
        { "x-koha-embed": "library" },
        requestConfig(options)
    );
}

/**
 * Searches for patrons matching a search term
 * @param {string} term - The search term to match against patron names, cardnumbers, etc.
 * @param {number} [page=1] - The page number for pagination
 * @returns {Promise<Object>} Object containing patron search results
 * @throws {Error} If the request fails or returns a non-OK status
 */
export async function fetchPatrons(term, page = 1) {
    if (!term) {
        return { results: [] };
    }

    const globalQueryBuilder = window["buildPatronSearchQuery"];
    if (typeof globalQueryBuilder !== "function") {
        throw new Error(
            $__(
                "Patron search is unavailable. Please refresh the page and try again."
            )
        );
    }
    const query = globalQueryBuilder(term, { search_type: "contains" });

    return APIClient.patron.patrons.search(
        query,
        {
            _page: String(page),
            _per_page: "10",
            _order_by: "surname,firstname",
        },
        {
            "x-koha-embed": "library",
            Accept: "application/json",
        },
        QUIET
    );
}

/**
 * Fetches pickup locations for a biblionumber, optionally filtered by patron
 * @param {number|string} biblionumber - The biblionumber to fetch pickup locations for
 * @param {number|string|null} [patronId] - Optional patron ID to filter pickup locations
 * @param {{ signal?: AbortSignal }} [options] - Request options
 * @returns {Promise<import('../../types/bookings').PickupLocation[]>} Pickup locations.
 * @throws {Error} If the request fails or returns a non-OK status
 */
export async function fetchPickupLocations(
    biblionumber,
    patronId,
    options = {}
) {
    const params = {
        _order_by: "name",
    };

    if (patronId) {
        params.patron_id = String(patronId);
    }

    return APIClient.biblio.biblios.pickup_locations(
        encodeURIComponent(biblionumber),
        params,
        requestConfig(options)
    );
}

/**
 * Fetches circulation rules based on the provided context parameters
 * @param {Object} [params={}] - Context parameters for circulation rules
 * @param {string|number} [params.patron_category_id] - Patron category ID
 * @param {string|number} [params.item_type_id] - Item type ID
 * @param {string|number} [params.library_id] - Library ID
 * @param {string} [params.start_date] - Start date for calculations (ISO format)
 * @param {string} [params.rules] - Comma-separated list of rule kinds
 * @param {boolean} [params.calculate_dates] - Whether to calculate dates
 * @param {{ signal?: AbortSignal }} [options] - Request options
 * @returns {Promise<import('../../types/bookings').CirculationRule[]>} Matching circulation rules.
 * @throws {Error} If the request fails or returns a non-OK status
 */
export async function fetchCirculationRules(params = {}, options = {}) {
    return APIClient.circulation_rules.rules.get(
        params,
        requestConfig(options)
    );
}

/**
 * Fetches holidays (closed days) for a library within a date range
 * @param {string} libraryId - The library ID (branchcode)
 * @param {string} [from] - Start date for the range (ISO format)
 * @param {string} [to] - End date for the range (ISO format)
 * @param {{ signal?: AbortSignal }} [options] - Request options
 * @returns {Promise<string[]>} Array of holiday dates in YYYY-MM-DD format
 * @throws {Error} If the request fails or returns a non-OK status
 */
export async function fetchHolidays(libraryId, from, to, options = {}) {
    if (!libraryId) {
        return [];
    }

    const params = {};
    if (from) params.from = from;
    if (to) params.to = to;

    return APIClient.library.libraries.closed_dates(
        encodeURIComponent(libraryId),
        params,
        requestConfig(options)
    );
}

/**
 * Creates a new booking
 * @param {Object} bookingData - The booking data to create
 * @param {string} bookingData.start_date - Start date of the booking (ISO 8601 format)
 * @param {string} bookingData.end_date - End date of the booking (ISO 8601 format)
 * @param {number|string} bookingData.biblio_id - Biblionumber for the booking
 * @param {number|string} [bookingData.item_id] - Optional item ID for the booking
 * @param {number|string} bookingData.patron_id - Patron ID for the booking
 * @param {number|string} bookingData.pickup_library_id - Pickup library ID
 * @returns {Promise<Object>} The created booking object
 * @throws {Error} If the request fails or returns a non-OK status
 */
export async function createBooking(bookingData) {
    return APIClient.booking.bookings.create(bookingData, QUIET);
}

/**
 * Updates an existing booking
 * @param {number|string} bookingId - The ID of the booking to update
 * @param {Object} bookingData - The updated booking data
 * @param {string} [bookingData.start_date] - New start date (ISO 8601 format)
 * @param {string} [bookingData.end_date] - New end date (ISO 8601 format)
 * @param {number|string} [bookingData.pickup_library_id] - New pickup library ID
 * @param {number|string} [bookingData.item_id] - New item ID
 * @returns {Promise<Object>} The updated booking object
 * @throws {Error} If the request fails or returns a non-OK status
 */
export async function updateBooking(bookingId, bookingData) {
    return APIClient.booking.bookings.update(
        bookingData,
        encodeURIComponent(bookingId),
        QUIET
    );
}
