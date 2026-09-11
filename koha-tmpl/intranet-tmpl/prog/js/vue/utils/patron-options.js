/**
 * Pure helpers for turning raw patron API records into PatronSelect options.
 *
 * Mirrors the field-by-field rules of the legacy $patron_to_html() /
 * patron_autocomplete() (staff-global.js, patron-format.js), but returns
 * plain data for native Vue rendering instead of pre-built HTML strings.
 */
import { $__ } from "../i18n/index.js";
import { idsEqual } from "./functions.js";
import { APIClient } from "../fetch/api-client.js";

/**
 * Compute a patron's age in whole years from their date of birth.
 *
 * @param {string|null|undefined} dateOfBirth
 * @returns {number|null}
 */
function calculateAge(dateOfBirth) {
    if (!dateOfBirth) return null;
    const dob = new Date(dateOfBirth);
    if (isNaN(dob.getTime())) return null;

    const today = new Date();
    let age = today.getFullYear() - dob.getFullYear();
    const monthDifference = today.getMonth() - dob.getMonth();
    if (
        monthDifference < 0 ||
        (monthDifference === 0 && today.getDate() < dob.getDate())
    ) {
        age--;
    }
    return age;
}

/**
 * Format a patron's display name, following the same rules as the legacy
 * $patron_to_html() helper (patron-format.js), minus HTML markup.
 *
 * @param {Object} patron Raw patron API record.
 * @param {Object} [config]
 * @param {boolean} [config.invertName] Render as "Surname, Preferred".
 * @param {boolean} [config.hidePatronName] Blank the name (e.g. cardnumber-only display).
 * @param {boolean} [config.displayCardnumber] Append the cardnumber.
 * @param {boolean} [config.showDiffFirstname] Show the legal firstname in brackets when it differs from the preferred name.
 * @returns {string}
 */
export function formatPatronName(patron, config = {}) {
    if (!patron) return "";

    let firstname = patron.firstname || "";
    let preferredName = patron.preferred_name || "";
    const surname = patron.surname || "";

    if (patron.middle_name) {
        firstname = firstname
            ? `${firstname} ${patron.middle_name}`
            : patron.middle_name;
        preferredName = preferredName
            ? `${preferredName} ${patron.middle_name}`
            : patron.middle_name;
    }

    if (patron.other_name) {
        firstname += ` (${patron.other_name})`;
        preferredName += ` (${patron.other_name})`;
    }

    if (
        config.showDiffFirstname &&
        patron.firstname &&
        patron.preferred_name !== patron.firstname
    ) {
        preferredName += ` [${patron.firstname}]`;
    }

    const nameParts = [];
    let name;
    if (config.invertName) {
        if (surname) nameParts.push(surname);
        if (preferredName) {
            nameParts.push(surname ? `, ${preferredName}` : preferredName);
        }
        name = nameParts.join("");
    } else {
        if (preferredName) nameParts.push(preferredName);
        if (surname) nameParts.push(surname);
        name = nameParts.join(" ");
    }

    if (name.trim().length === 0) {
        return patron.library?.name
            ? `${$__("A patron from")} ${patron.library.name}`
            : $__("A patron from another library");
    }

    if (config.hidePatronName) {
        name = "";
    }

    if (config.displayCardnumber) {
        name = name
            ? `${name} (${patron.cardnumber || ""})`
            : patron.cardnumber || "";
    }

    return name;
}

/**
 * Build a PatronSelect option from a raw patron API record.
 *
 * @param {Object|null} patron Raw patron API record.
 * @param {Object} [config] See formatPatronName(), plus:
 * @param {string|number} [config.loggedInLibraryId] Current user's library, to flag matching patrons.
 * @returns {Object|null}
 */
export function patronToOption(patron, config = {}) {
    if (!patron) return null;

    return {
        ...patron,
        label: formatPatronName(patron, config),
        _age: calculateAge(patron.date_of_birth),
        _libraryName: patron.library?.name ?? null,
        _expired: !!patron.expired,
        _restricted: !!patron.restricted,
        _isCurrentLibrary: idsEqual(
            patron.library_id,
            config.loggedInLibraryId
        ),
        _city: patron.city ?? null,
        _country: patron.country ?? null,
    };
}

/**
 * Resolve a PatronSelect option from either a bare patron id or an
 * already-fetched patron record, fetching only when necessary.
 *
 * @param {string|number|Object|null} idOrPatron
 * @param {Object} [config] See patronToOption().
 * @returns {Promise<Object|null>}
 */
export async function resolvePatronOption(idOrPatron, config = {}) {
    if (idOrPatron == null) return null;

    if (typeof idOrPatron === "object") {
        return patronToOption(idOrPatron, config);
    }

    const patron = await APIClient.patron.patrons.get(idOrPatron);
    return patronToOption(patron, config);
}
