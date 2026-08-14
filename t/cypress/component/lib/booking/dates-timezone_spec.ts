// Pure-function tests for the library-timezone day-boundary contract helpers.
//
// The bookings API carries the selected calendar DATE as day boundaries
// anchored to the library's configured timezone (window.$timezone()), so the
// DATE survives the server's round-trip back to library time (see Bug 42868).
// handleSubmit serializes with toStartOfDayISO/toEndOfDayISO; edit prefill
// recovers the date with datePart (the server availability map applies the
// same contract backend-side). A regression here shifts bookings by a day
// under timezone skew.

import {
    toStartOfDayISO,
    toEndOfDayISO,
    datePart,
} from "@koha-vue/lib/booking/dates.js";

describe("Library-timezone day-boundary contract helpers", () => {
    // Brisbane is UTC+10 year-round (no DST), so the offset is unambiguous
    // and clearly distinct from UTC.
    const LIBRARY_TZ = "Australia/Brisbane";
    let originalTimezone;

    beforeEach(() => {
        originalTimezone = window["$timezone"];
        window["$timezone"] = () => LIBRARY_TZ;
    });

    afterEach(() => {
        window["$timezone"] = originalTimezone;
    });

    it("serializes a local calendar date as library-timezone day boundaries", () => {
        const localDate = new Date(2026, 7, 10, 14, 30);
        // 2026-08-10 00:00 / 23:59:59.999 in UTC+10, as UTC instants.
        expect(toStartOfDayISO(localDate)).to.eq("2026-08-09T14:00:00.000Z");
        expect(toEndOfDayISO(localDate)).to.eq("2026-08-10T13:59:59.999Z");
    });

    it("extracts the booked date from any offset representation of the instant", () => {
        // All three denote 2026-08-10 in the library timezone (UTC+10).
        expect(datePart("2026-08-09T14:00:00.000Z")).to.eq("2026-08-10");
        expect(datePart("2026-08-10T00:00:00+10:00")).to.eq("2026-08-10");
        expect(datePart("2026-08-09T20:00:00-04:00")).to.eq("2026-08-10");
    });

    it("round-trips a selected local date through the API contract", () => {
        const picked = new Date(2026, 11, 31);
        expect(datePart(toStartOfDayISO(picked))).to.eq("2026-12-31");
        expect(datePart(toEndOfDayISO(picked))).to.eq("2026-12-31");
    });

    it("returns empty strings for invalid input", () => {
        expect(toStartOfDayISO(null)).to.eq("");
        expect(datePart("not-a-date")).to.eq("");
    });
});
