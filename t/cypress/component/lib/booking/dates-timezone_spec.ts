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
    addDays,
    formatYMD,
    today,
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

    // today() feeds the past-date disable and lead-time floor, so it must
    // follow the same library-timezone contract as every other boundary
    // here, not the browser/test-runner's own local timezone.
    it("anchors today() to the library timezone, not the browser's local time", () => {
        // 2026-08-09T20:00:00Z is already 2026-08-10 06:00 in UTC+10.
        cy.clock(new Date("2026-08-09T20:00:00Z").getTime(), ["Date"]);
        cy.then(() => {
            expect(formatYMD(today())).to.eq("2026-08-10");
        });
    });
});

describe("Library-timezone day-boundary contract helpers across a DST transition", () => {
    // Europe/London observes DST (GMT/BST), unlike the fixed-offset zone
    // above. The lead/trail-period window math (addDays) and the API
    // day-boundary serialization both need to keep landing on the same
    // calendar date across a boundary where the UTC offset itself changes
    // mid-range, or a booking window silently drifts by an hour into the
    // wrong day.
    const LIBRARY_TZ = "Europe/London";
    let originalTimezone;

    beforeEach(() => {
        originalTimezone = window["$timezone"];
        window["$timezone"] = () => LIBRARY_TZ;
    });

    afterEach(() => {
        window["$timezone"] = originalTimezone;
    });

    // 2026-03-29: clocks spring forward 01:00 GMT -> 02:00 BST. Start of day
    // is still GMT (UTC+0); end of day is already BST (UTC+1).
    it("keeps the same calendar date across the spring-forward transition", () => {
        const localDate = new Date(2026, 2, 29);
        expect(toStartOfDayISO(localDate)).to.eq("2026-03-29T00:00:00.000Z");
        expect(toEndOfDayISO(localDate)).to.eq("2026-03-29T22:59:59.999Z");
        expect(datePart(toStartOfDayISO(localDate))).to.eq("2026-03-29");
        expect(datePart(toEndOfDayISO(localDate))).to.eq("2026-03-29");
    });

    // 2026-10-25: clocks fall back 02:00 BST -> 01:00 GMT. Start of day is
    // still BST (UTC+1); end of day is already GMT (UTC+0).
    it("keeps the same calendar date across the fall-back transition", () => {
        const localDate = new Date(2026, 9, 25);
        expect(toStartOfDayISO(localDate)).to.eq("2026-10-24T23:00:00.000Z");
        expect(toEndOfDayISO(localDate)).to.eq("2026-10-25T23:59:59.999Z");
        expect(datePart(toStartOfDayISO(localDate))).to.eq("2026-10-25");
        expect(datePart(toEndOfDayISO(localDate))).to.eq("2026-10-25");
    });

    // A lead/trail-period window is built by adding whole days to a booking
    // boundary (see predicate.js's leadWindowConflicts/trailWindowConflicts).
    // That arithmetic must stay in whole calendar days across a DST switch,
    // not drift by the transition's missing/repeated hour.
    it("adds whole calendar days across a spring-forward boundary", () => {
        expect(formatYMD(addDays("2026-03-27", 3))).to.eq("2026-03-30");
    });

    it("adds whole calendar days across a fall-back boundary", () => {
        expect(formatYMD(addDays("2026-10-23", 3))).to.eq("2026-10-26");
    });
});
