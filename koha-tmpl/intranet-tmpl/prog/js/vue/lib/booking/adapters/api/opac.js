/**
 * Public-API transport adapter for the planned OPAC booking island.
 *
 * The shared exports intentionally mirror staff-interface.js. Patron search,
 * holidays, booking creation, and booking updates remain unsupported until the
 * corresponding OPAC workflow and public endpoints land; their deliberate
 * stubs below make that limitation explicit rather than simulating success.
 *
 * @module opacBookingApi
 */

import HttpClient from "@fetch/http-client";
import { $__ } from "@koha-vue/i18n";

const httpClient = new HttpClient();
const QUIET = { suppressDefaultErrorDialog: true };

/**
 * Request and parse a public API resource through Koha's shared HTTP client.
 *
 * @param {string} url Public API URL.
 * @param {{signal?: AbortSignal, headers?: Record<string, string>} & RequestInit} [options] Request options.
 * @returns {Promise<any>} Parsed response body.
 */
function requestJson(url, { signal, headers, ...options } = {}) {
    return httpClient.get({
        endpoint: url,
        headers: {
            Accept: "application/json",
            ...headers,
        },
        options,
        config: signal ? { ...QUIET, signal } : QUIET,
    });
}

/**
 * Fetch bookable items for a biblio from the public API.
 *
 * @param {import('../../types/bookings').Id} biblionumber Biblio identifier.
 * @param {{signal?: AbortSignal, headers?: Record<string, string>}} [options] Request options.
 * @returns {Promise<import('../../types/bookings').BookableItem[]>} Bookable items.
 */
export function fetchBookableItems(biblionumber, options = {}) {
    const params = new URLSearchParams({ _per_page: "-1", bookable: "1" });
    return requestJson(
        `/api/v1/public/biblios/${encodeURIComponent(
            biblionumber
        )}/items?${params}`,
        {
            ...options,
            headers: { "x-koha-embed": "+strings,item_type" },
        }
    );
}

/**
 * Fetch one assigned item so edit workflows can retain it when unbookable.
 *
 * @param {import('../../types/bookings').Id} biblionumber Biblio identifier.
 * @param {import('../../types/bookings').Id} itemId Assigned item identifier.
 * @param {{signal?: AbortSignal, headers?: Record<string, string>}} [options] Request options.
 * @returns {Promise<import('../../types/bookings').BookableItem[]>} Matching assigned items.
 */
export function fetchAssignedItem(biblionumber, itemId, options = {}) {
    const params = new URLSearchParams({
        _per_page: "-1",
        q: JSON.stringify({ item_id: itemId }),
    });
    return requestJson(
        `/api/v1/public/biblios/${encodeURIComponent(
            biblionumber
        )}/items?${params}`,
        {
            ...options,
            headers: { "x-koha-embed": "+strings,item_type" },
        }
    );
}

/**
 * Fetch the public booking-availability map for a biblio.
 *
 * @param {import('../../types/bookings').Id} biblionumber Biblio identifier.
 * @param {Object} [params] Availability query parameters.
 * @param {{signal?: AbortSignal, headers?: Record<string, string>}} [options] Request options.
 * @returns {Promise<import('../../types/bookings').BookingAvailabilityResponse>} Availability map.
 */
export function fetchBookingAvailability(
    biblionumber,
    params = {},
    options = {}
) {
    return requestJson(
        `/api/v1/public/biblios/${encodeURIComponent(
            biblionumber
        )}/booking_availability?${new URLSearchParams(params)}`,
        options
    );
}

/**
 * Fetch the logged-in patron through the public API.
 *
 * @param {import('../../types/bookings').Id} patronId Patron identifier.
 * @param {{signal?: AbortSignal, headers?: Record<string, string>}} [options] Request options.
 * @returns {Promise<Object>} Patron representation.
 */
export function fetchPatron(patronId, options = {}) {
    return requestJson(
        `/api/v1/public/patrons/${encodeURIComponent(patronId)}`,
        {
            ...options,
            headers: { "x-koha-embed": "library" },
        }
    );
}

/**
 * Return no patron-search results because an OPAC user cannot select another patron.
 *
 * @returns {Promise<[]>} Empty patron list.
 */
export async function fetchPatrons() {
    return [];
}

/**
 * Fetch public pickup locations for a biblio and patron.
 *
 * @param {import('../../types/bookings').Id} biblionumber Biblio identifier.
 * @param {import('../../types/bookings').Id} patronId Patron identifier.
 * @param {{signal?: AbortSignal, headers?: Record<string, string>}} [options] Request options.
 * @returns {Promise<import('../../types/bookings').PickupLocation[]>} Pickup locations.
 */
export function fetchPickupLocations(biblionumber, patronId, options = {}) {
    const params = new URLSearchParams({
        _order_by: "name",
        _per_page: "-1",
    });
    if (patronId) params.set("patron_id", String(patronId));

    return requestJson(
        `/api/v1/public/biblios/${encodeURIComponent(
            biblionumber
        )}/pickup_locations?${params}`,
        options
    );
}

/**
 * Fetch public circulation rules using the shared workflow's parameters.
 *
 * @param {Object} [params] Circulation-rule query parameters.
 * @param {{signal?: AbortSignal, headers?: Record<string, string>}} [options] Request options.
 * @returns {Promise<import('../../types/bookings').CirculationRule[]>} Matching rules.
 */
export function fetchCirculationRules(params = {}, options = {}) {
    return requestJson(
        `/api/v1/public/circulation_rules?${new URLSearchParams(params)}`,
        options
    );
}

/**
 * Deliberate stub: no public closed-dates endpoint exists yet.
 * The OPAC calendar therefore has no holiday highlighting until that API lands.
 *
 * @returns {Promise<string[]>} Empty closed-date list.
 */
export async function fetchHolidays() {
    return [];
}

/**
 * Reject an operation that has no public booking endpoint.
 *
 * @returns {Promise<never>} Rejected unsupported-operation promise.
 */
function unsupportedOperation() {
    const error = new Error(
        $__("This booking action is not available in the OPAC.")
    );
    error.code = "not_implemented";
    return Promise.reject(error);
}

/**
 * Reject booking creation until the public workflow is implemented.
 *
 * @returns {Promise<never>} Rejected unsupported-operation promise.
 */
export function createBooking() {
    return unsupportedOperation();
}

/**
 * Reject booking updates until the public workflow is implemented.
 *
 * @returns {Promise<never>} Rejected unsupported-operation promise.
 */
export function updateBooking() {
    return unsupportedOperation();
}
