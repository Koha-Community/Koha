/**
 * OPAC transport adapter placeholder for the booking island.
 *
 * Exposing the booking modal in the OPAC is left to a follow-up bug, which
 * also has to decide the public endpoints it needs. Until then every export
 * mirrors staff-interface.js and rejects as not implemented.
 *
 * @module opacBookingApi
 */

import { $__ } from "@koha-vue/i18n";

/**
 * Reject an operation that has no OPAC implementation.
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

/** @returns {Promise<never>} Rejected unsupported-operation promise. */
export function fetchBookableItems() {
    return unsupportedOperation();
}

/** @returns {Promise<never>} Rejected unsupported-operation promise. */
export function fetchAssignedItem() {
    return unsupportedOperation();
}

/** @returns {Promise<never>} Rejected unsupported-operation promise. */
export function fetchBookingAvailability() {
    return unsupportedOperation();
}

/** @returns {Promise<never>} Rejected unsupported-operation promise. */
export function fetchPatron() {
    return unsupportedOperation();
}

/** @returns {Promise<never>} Rejected unsupported-operation promise. */
export function fetchPatrons() {
    return unsupportedOperation();
}

/** @returns {Promise<never>} Rejected unsupported-operation promise. */
export function fetchPickupLocations() {
    return unsupportedOperation();
}

/** @returns {Promise<never>} Rejected unsupported-operation promise. */
export function fetchCirculationRules() {
    return unsupportedOperation();
}

/** @returns {Promise<never>} Rejected unsupported-operation promise. */
export function fetchHolidays() {
    return unsupportedOperation();
}

/** @returns {Promise<never>} Rejected unsupported-operation promise. */
export function createBooking() {
    return unsupportedOperation();
}

/** @returns {Promise<never>} Rejected unsupported-operation promise. */
export function updateBooking() {
    return unsupportedOperation();
}
