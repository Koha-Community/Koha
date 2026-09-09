// Functional date boundary for booking calendar dates and API instants.

import dayjs from "../../utils/dayjs.js";

/**
 * Parse a date-like value and normalize it to the start of its local day.
 *
 * @param {import("dayjs").ConfigType|null|undefined} input
 * @returns {import("dayjs").Dayjs|null}
 */
export function toDay(input) {
    if (input == null) return null;
    const value = dayjs(input).startOf("day");
    if (!value.isValid()) throw new Error(`Invalid date input: ${input}`);
    return value;
}

/** @returns {import("dayjs").Dayjs} */
export function today() {
    return dayjs().tz(window.$timezone()).startOf("day");
}

/**
 * Convert local calendar-date strings to native dates for Flatpickr.
 *
 * @param {Array<string|null|undefined>} values
 * @returns {Date[]}
 */
export function isoArrayToDates(values) {
    if (!Array.isArray(values)) return [];
    return values.filter(Boolean).map(value => toDay(value).toDate());
}

/**
 * Format a date-like value as a local calendar date.
 *
 * @param {import("dayjs").ConfigType|null|undefined} input
 * @returns {string}
 */
export function formatYMD(input) {
    return toDay(input)?.format("YYYY-MM-DD") ?? "";
}

/**
 * Serialize a local calendar date as an ISO instant at local start of day.
 *
 * @param {import("dayjs").ConfigType|null|undefined} input
 * @returns {string}
 */
export function toISO(input) {
    return toDay(input)?.toISOString() ?? "";
}

/**
 * Add whole calendar days to a date-like value.
 *
 * @param {import("dayjs").ConfigType} input
 * @param {number} days
 * @returns {import("dayjs").Dayjs}
 * @throws {Error} When input is null/undefined - callers that need a
 *   "days from now" result should pass today() explicitly, rather than
 *   relying on a silent fallback here that would mask an upstream bug.
 */
export function addDays(input, days) {
    const day = toDay(input);
    if (!day) throw new Error(`addDays: invalid date input: ${input}`);
    return day.add(days, "day");
}

/**
 * Add whole calendar months to a date-like value.
 *
 * @param {import("dayjs").ConfigType} input
 * @param {number} months
 * @returns {import("dayjs").Dayjs}
 * @throws {Error} When input is null/undefined - see addDays.
 */
export function addMonths(input, months) {
    const day = toDay(input);
    if (!day) throw new Error(`addMonths: invalid date input: ${input}`);
    return day.add(months, "month");
}

/**
 * Serialize a local calendar date as a start-of-day instant anchored to the
 * library's configured timezone for the bookings API.
 *
 * @param {import("dayjs").ConfigType|null|undefined} input
 * @returns {string}
 */
export function toStartOfDayISO(input) {
    const ymd = formatYMD(input);
    return ymd
        ? dayjs.tz(ymd, window.$timezone()).startOf("day").toISOString()
        : "";
}

/**
 * Serialize a local calendar date as an end-of-day instant anchored to the
 * library's configured timezone for the bookings API.
 *
 * @param {import("dayjs").ConfigType|null|undefined} input
 * @returns {string}
 */
export function toEndOfDayISO(input) {
    const ymd = formatYMD(input);
    return ymd
        ? dayjs.tz(ymd, window.$timezone()).endOf("day").toISOString()
        : "";
}

/**
 * Extract the library-local calendar date denoted by an API instant.
 *
 * @param {string} isoInstant
 * @returns {string}
 */
export function datePart(isoInstant) {
    const value = dayjs(isoInstant);
    return value.isValid()
        ? value.tz(window.$timezone()).format("YYYY-MM-DD")
        : "";
}
