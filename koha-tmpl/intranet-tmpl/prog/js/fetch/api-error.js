/* global __ */

/**
 * Extract a message from an API error.
 *
 * @param {unknown} error API error
 * @returns {string} Raw error message
 */
function extractErrorMessage(error) {
    if (typeof error === "string" && error) return error;
    if (
        typeof error === "object" &&
        error !== null &&
        "message" in error &&
        typeof error.message === "string"
    ) {
        return error.message;
    }
    return "";
}

/**
 * Detect a failure raised by fetch itself rather than by the server.
 *
 * @param {unknown} error API error
 * @returns {boolean} Whether the request never reached the server
 */
function isNetworkError(error) {
    return error instanceof TypeError && !("status" in error);
}

/**
 * Turn an API error into a user-facing, translated message.
 *
 * The HTTP client attaches the HTTP status and Koha error code to thrown
 * errors. Callers remain responsible for filtering expected AbortErrors.
 *
 * @param {unknown} error API error
 * @returns {string} Translated error message
 */
export function formatApiError(error) {
    const status =
        typeof error === "object" &&
        error !== null &&
        "status" in error &&
        typeof error.status === "number"
            ? error.status
            : undefined;

    if (status === 401) {
        return __("Your session has expired. Please log in again.");
    }
    if (status === 403) {
        return __("You are not authorized to perform this action.");
    }
    if (isNetworkError(error)) {
        return __(
            "Could not reach the server. Check your connection and try again."
        );
    }

    const message = extractErrorMessage(error);
    return message
        ? __("An error occurred: %s").format(message)
        : __("An unexpected error occurred.");
}
