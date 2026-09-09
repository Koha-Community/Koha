// Pure-function tests for the availability predicate - no mount, no DOM.
//
// createDisableFunction is the predicate the composable's disabledFn wraps,
// the same one flatpickr ultimately calls per day; findFirstBlockingDate
// clamps the constrained-range highlight at the last placeable day;
// calculateMaxEndDate is the shared period arithmetic. All evaluate against
// the server availability map (hand-built fixtures here), which arrives
// with existing bookings' lead/trail windows pre-marked and the edited
// booking excluded - both the endpoint's contract, covered by its tests.

import {
    calculateMaxEndDate,
    createDisableFunction,
    findFirstBlockingDate,
} from "@koha-vue/lib/booking/availability/predicate.js";
import { extractBookingConfiguration } from "@koha-vue/lib/booking/availability/predicate.js";

// Deterministic "today" for every test in this file: March 15, 2026.
// All fixtures are relative to this anchor so the past-date guard, lead-
// period math, and isoformat boundaries don't drift across runs.
const TODAY = new Date(2026, 2, 15);

const item = id => ({
    item_id: id,
    title: `Item ${id}`,
    barcode: `bar-${id}`,
});

const mapOf = entries => {
    const map = {};
    for (const [date, byItem] of Object.entries(entries)) {
        map[date] = {};
        for (const [id, reasons] of Object.entries(byItem)) {
            map[date][id] = new Set(reasons);
        }
    }
    return map;
};

// Helper: assert two Date values point at the same YYYY-MM-DD.
// findFirstBlockingDate returns a Date built via dayjs(...).toDate();
// comparing by UTC-ish ts is brittle across runner timezones, so format
// and compare strings.
function expectSameDay(d, expected) {
    const ymd = d => {
        const y = d.getFullYear();
        const m = String(d.getMonth() + 1).padStart(2, "0");
        const dd = String(d.getDate()).padStart(2, "0");
        return `${y}-${m}-${dd}`;
    };
    expect(ymd(d)).to.equal(expected);
}

function makeDisableFn(opts) {
    opts = opts || {};
    const unavailableByDate = mapOf(opts.map || {});
    const bookableItems = opts.bookableItems || [item("1")];
    const rules = opts.rules || {};
    const selectedItem = opts.selectedItem != null ? opts.selectedItem : null;
    const selectedDates = opts.selectedDates || [];
    const holidays = opts.holidays || [];

    const config = extractBookingConfiguration(rules, TODAY);
    return createDisableFunction(
        unavailableByDate,
        config,
        bookableItems,
        selectedItem,
        selectedDates,
        holidays
    );
}

describe("calculateMaxEndDate", () => {
    it("returns start + (maxPeriod - 1) so start counts as day 1", () => {
        // start=Mar 20, maxPeriod=5 → end=Mar 24 (Mar 20, 21, 22, 23, 24)
        const result = calculateMaxEndDate(new Date(2026, 2, 20), 5);
        expect(result.format("YYYY-MM-DD")).to.equal("2026-03-24");
    });

    it("returns the start day itself when maxPeriod is 1", () => {
        const result = calculateMaxEndDate(new Date(2026, 2, 20), 1);
        expect(result.format("YYYY-MM-DD")).to.equal("2026-03-20");
    });

    it("throws when maxPeriod is zero", () => {
        expect(() => calculateMaxEndDate(new Date(2026, 2, 20), 0)).to.throw(
            "maxPeriod must be a positive number"
        );
    });

    it("throws when maxPeriod is negative", () => {
        expect(() => calculateMaxEndDate(new Date(2026, 2, 20), -1)).to.throw(
            "maxPeriod must be a positive number"
        );
    });
});

describe("createDisableFunction (past-date and presence guards)", () => {
    it("disables dates before today", () => {
        const fn = makeDisableFn();
        expect(fn(new Date(2026, 2, 14))).to.be.true; // Mar 14 (yesterday)
        expect(fn(new Date(2026, 1, 28))).to.be.true; // Feb 28
    });

    it("allows today itself", () => {
        const fn = makeDisableFn();
        expect(fn(new Date(2026, 2, 15))).to.be.false;
    });

    it("allows future dates with no constraints", () => {
        const fn = makeDisableFn();
        expect(fn(new Date(2026, 2, 16))).to.be.false;
        expect(fn(new Date(2026, 5, 1))).to.be.false;
    });

    it("disables every date when bookableItems is empty", () => {
        // No items to book against → every probe must be disabled regardless
        // of date. Past-date guard fires first for past dates, so this is
        // really asserting on the future-date branch.
        const fn = makeDisableFn({ bookableItems: [] });
        expect(fn(new Date(2026, 2, 16))).to.be.true;
        expect(fn(new Date(2026, 5, 1))).to.be.true;
    });
});

describe("createDisableFunction (holiday handling)", () => {
    it("disables holidays when no start date is selected", () => {
        // Picking a START date: holidays are hard-disabled. This is the
        // map-side rendering — the composable's disabledByDate surfaces it
        // with severity:'hard'.
        const fn = makeDisableFn({ holidays: ["2026-03-20"] });
        expect(fn(new Date(2026, 2, 20))).to.be.true;
    });

    it("allows holidays once a start date is selected (lets range cross them)", () => {
        // Picking an END date: holidays must NOT be disabled at the
        // flatpickr level, otherwise the range validator rejects spans that
        // cross them. Soft severity is applied separately by disabledByDate.
        const fn = makeDisableFn({
            holidays: ["2026-03-20"],
            selectedDates: [new Date(2026, 2, 18)],
        });
        expect(fn(new Date(2026, 2, 20))).to.be.false;
    });

    it("does not treat the map's holiday reason as an item conflict", () => {
        // The server marks closed days on every item; those marks drive
        // CSS/hover layers, not the per-item conflict logic. With a start
        // selected the date must stay enabled.
        const fn = makeDisableFn({
            map: { "2026-03-20": { "1": ["holiday"] } },
            selectedDates: [new Date(2026, 2, 18)],
        });
        expect(fn(new Date(2026, 2, 20))).to.be.false;
    });

    it("does not affect non-holiday dates", () => {
        const fn = makeDisableFn({ holidays: ["2026-03-20"] });
        expect(fn(new Date(2026, 2, 21))).to.be.false;
    });
});

describe("createDisableFunction (point conflicts with existing bookings)", () => {
    it("disables a date covered by an existing booking when one item exists", () => {
        const fn = makeDisableFn({
            map: {
                "2026-03-20": { "1": ["booking"] },
                "2026-03-21": { "1": ["booking"] },
                "2026-03-22": { "1": ["booking"] },
            },
        });
        expect(fn(new Date(2026, 2, 20))).to.be.true;
        expect(fn(new Date(2026, 2, 21))).to.be.true;
        expect(fn(new Date(2026, 2, 22))).to.be.true;
        expect(fn(new Date(2026, 2, 23))).to.be.false;
    });

    it("allows a date when at least one bookable item is still free", () => {
        // Only item 1 is booked; item 2 is free → not all-items-blocked.
        const fn = makeDisableFn({
            bookableItems: [item("1"), item("2")],
            map: { "2026-03-21": { "1": ["booking"] } },
        });
        expect(fn(new Date(2026, 2, 21))).to.be.false;
    });

    it("disables when the selected item specifically is booked", () => {
        // selectedItem narrows the disable check to that one item.
        const fn = makeDisableFn({
            bookableItems: [item("1"), item("2")],
            map: { "2026-03-21": { "1": ["booking"] } },
            selectedItem: "1",
        });
        expect(fn(new Date(2026, 2, 21))).to.be.true;
    });

    it("treats server-marked lead/trail windows of existing bookings as conflicts", () => {
        const fn = makeDisableFn({
            map: {
                "2026-03-19": { "1": ["lead"] },
                "2026-03-23": { "1": ["trail"] },
            },
        });
        expect(fn(new Date(2026, 2, 19))).to.be.true;
        expect(fn(new Date(2026, 2, 23))).to.be.true;
    });
});

describe("createDisableFunction (lead period from today)", () => {
    it("disables dates inside the lead window when no start is selected", () => {
        // bookings_lead_period=3, today=Mar 15 → minStartDate = Mar 18.
        // Mar 16-17 are inside the lead window and must be disabled.
        const fn = makeDisableFn({
            rules: { bookings_lead_period: 3 },
        });
        expect(fn(new Date(2026, 2, 16))).to.be.true;
        expect(fn(new Date(2026, 2, 17))).to.be.true;
        expect(fn(new Date(2026, 2, 18))).to.be.false;
        expect(fn(new Date(2026, 2, 19))).to.be.false;
    });

    it("ignores lead period when no rule is set", () => {
        const fn = makeDisableFn();
        expect(fn(new Date(2026, 2, 16))).to.be.false;
        expect(fn(new Date(2026, 2, 17))).to.be.false;
    });

    it("blocks a candidate start whose own lead window hits an existing booking's marks", () => {
        // bookings_lead_period=3 with an existing booking starting Mar 25
        // (server marks its lead window Mar 22-24): a new start at Mar 23
        // puts its lead window [Mar 20, Mar 22] onto the Mar 22 mark,
        // which validateLeadPeriod catches (bidirectional semantics).
        const fn = makeDisableFn({
            rules: { bookings_lead_period: 3 },
            map: {
                "2026-03-22": { "1": ["lead"] },
                "2026-03-23": { "1": ["lead"] },
                "2026-03-24": { "1": ["lead"] },
                "2026-03-25": { "1": ["booking"] },
                "2026-03-26": { "1": ["booking"] },
                "2026-03-27": { "1": ["booking"] },
            },
        });
        expect(fn(new Date(2026, 2, 23))).to.be.true;
    });
});

describe("createDisableFunction (end-date selection)", () => {
    it("disables an end date past anchor + maxPeriod - 1", () => {
        // anchor=Mar 20, maxPeriod=5 → calculatedEnd = anchor + 4 = Mar 24
        // (anchor counts as day 1; see calculateMaxEndDate). Mar 25 must
        // be disabled, Mar 24 allowed.
        const fn = makeDisableFn({
            rules: { issuelength: 5 },
            selectedDates: [new Date(2026, 2, 20)],
        });
        expect(fn(new Date(2026, 2, 24))).to.be.false;
        expect(fn(new Date(2026, 2, 25))).to.be.true;
    });

    it("disables an end date whose [start, end] range overlaps a booking", () => {
        // anchor=Mar 20, booking blocks Mar 25 → an end at Mar 26 would span
        // the conflict and must be rejected by the range-overlap check.
        const fn = makeDisableFn({
            map: { "2026-03-25": { "1": ["booking"] } },
            selectedDates: [new Date(2026, 2, 20)],
        });
        expect(fn(new Date(2026, 2, 24))).to.be.false;
        expect(fn(new Date(2026, 2, 26))).to.be.true;
    });

    it("disables an end date whose trail period overlaps the next booking", () => {
        // trail_period=2, anchor=Mar 20, next booking Mar 27-29 → an end at
        // Mar 25 would put [Mar 26, Mar 27] onto the Mar 27 booking mark,
        // caught by validateTrailPeriod.
        const fn = makeDisableFn({
            rules: { bookings_trail_period: 2 },
            map: {
                "2026-03-27": { "1": ["booking"] },
                "2026-03-28": { "1": ["booking"] },
                "2026-03-29": { "1": ["booking"] },
            },
            selectedDates: [new Date(2026, 2, 20)],
        });
        expect(fn(new Date(2026, 2, 25))).to.be.true;
    });
});

describe("createDisableFunction (end-date-only mode)", () => {
    it("blocks a start date when no single item can serve the full fixed period (any item)", () => {
        // end_date_only forces the end to start + maxPeriod - 1, so the
        // whole range must fit on ONE item. Items 1 and 2 each have a
        // disjoint single-day booking inside [Mar 20, Mar 24] — no day
        // has both items blocked, but neither item is free for the full
        // period, so Mar 20 must not be selectable as a start date.
        const fn = makeDisableFn({
            rules: {
                booking_constraint_mode: "end_date_only",
                issuelength: 5,
            },
            bookableItems: [item("1"), item("2")],
            map: {
                "2026-03-21": { "1": ["booking"] },
                "2026-03-23": { "2": ["booking"] },
            },
            selectedDates: [],
        });
        expect(fn(new Date(2026, 2, 20))).to.be.true;
    });

    it("allows a start date when one item remains free for the full fixed period (any item)", () => {
        // Same setup, but item 2 is unencumbered: the range can be
        // served end-to-end by item 2, so Mar 20 stays selectable.
        const fn = makeDisableFn({
            rules: {
                booking_constraint_mode: "end_date_only",
                issuelength: 5,
            },
            bookableItems: [item("1"), item("2")],
            map: { "2026-03-21": { "1": ["booking"] } },
            selectedDates: [],
        });
        expect(fn(new Date(2026, 2, 20))).to.be.false;
    });

    it("allows the calculated end date exactly at anchor + maxPeriod - 1", () => {
        // end_date_only with maxPeriod=5, anchor=Mar 20:
        // calculatedEnd=Mar 24 must be selectable (short-circuit at the
        // isEndDateOnly + isSame(calculatedEnd) check).
        const fn = makeDisableFn({
            rules: {
                booking_constraint_mode: "end_date_only",
                issuelength: 5,
            },
            selectedDates: [new Date(2026, 2, 20)],
        });
        expect(fn(new Date(2026, 2, 24))).to.be.false;
    });

    it("does not disable intermediate dates at the flatpickr level (soft handling owns UX)", () => {
        // end_date_only with maxPeriod=5, anchor=Mar 20:
        // intermediates Mar 21-23 stay enabled here so flatpickr's range
        // validator accepts [Mar 20, Mar 24]. The disabledByDate Map applies
        // soft severity for UI affordance instead.
        const fn = makeDisableFn({
            rules: {
                booking_constraint_mode: "end_date_only",
                issuelength: 5,
            },
            selectedDates: [new Date(2026, 2, 20)],
        });
        expect(fn(new Date(2026, 2, 21))).to.be.false;
        expect(fn(new Date(2026, 2, 23))).to.be.false;
    });

    it("disables dates past the calculated end even in end-date-only mode", () => {
        // anchor + maxPeriod - 1 = Mar 24, so Mar 25 must be disabled.
        const fn = makeDisableFn({
            rules: {
                booking_constraint_mode: "end_date_only",
                issuelength: 5,
            },
            selectedDates: [new Date(2026, 2, 20)],
        });
        expect(fn(new Date(2026, 2, 25))).to.be.true;
    });
});

describe("createDisableFunction (draft-window edge cases)", () => {
    it("does not check the lead window when no lead rule is set", () => {
        // A mark right before the candidate start must not block it when
        // leadDays is zero - the window simply does not exist.
        const fn = makeDisableFn({
            map: { "2026-03-19": { "1": ["booking"] } },
        });
        expect(fn(new Date(2026, 2, 20))).to.be.false;
    });

    it("does not check the trail window when no trail rule is set", () => {
        const fn = makeDisableFn({
            map: { "2026-03-25": { "1": ["booking"] } },
            selectedDates: [new Date(2026, 2, 20)],
        });
        expect(fn(new Date(2026, 2, 24))).to.be.false;
    });

    it("blocks a start whose lead window hits an existing trail mark (bidirectional)", () => {
        // The required gap between consecutive bookings is the earlier
        // booking's trail plus the later booking's lead.
        const fn = makeDisableFn({
            rules: { bookings_lead_period: 2 },
            map: { "2026-03-19": { "1": ["trail"] } },
        });
        expect(fn(new Date(2026, 2, 20))).to.be.true;
    });

    it("blocks a start whose one-day trail window hits the next booking's lead", () => {
        const fn = makeDisableFn({
            rules: { bookings_trail_period: 1 },
            map: { "2026-03-17": { "1": ["lead"] } },
        });
        expect(fn(new Date(2026, 2, 16))).to.be.true;
        expect(fn(new Date(2026, 2, 15))).to.be.false;
    });
});

describe("findFirstBlockingDate (empty cases)", () => {
    it("returns the start date with reason 'no_items' when bookableItems is empty", () => {
        const result = findFirstBlockingDate(
            new Date(2026, 2, 10),
            new Date(2026, 2, 24),
            mapOf({}),
            [],
            null
        );
        expect(result.reason).to.equal("no_items");
        expectSameDay(result.firstBlockingDate, "2026-03-10");
    });

    it("returns null when the map holds no conflicts in the window", () => {
        const result = findFirstBlockingDate(
            new Date(2026, 2, 10),
            new Date(2026, 2, 24),
            mapOf({}),
            [item("1")],
            null
        );
        expect(result.firstBlockingDate).to.be.null;
        expect(result.reason).to.be.null;
    });

    it("returns null when conflicts exist past the search window", () => {
        const result = findFirstBlockingDate(
            new Date(2026, 2, 10),
            new Date(2026, 2, 24),
            mapOf({ "2026-04-01": { "1": ["booking"] } }),
            [item("1")],
            null
        );
        expect(result.firstBlockingDate).to.be.null;
    });
});

describe("findFirstBlockingDate (single item)", () => {
    it("returns the first day that crosses a booking", () => {
        // Single item, booking on Mar 20. The first [Mar 10, X] range that
        // overlaps Mar 20 is X = Mar 20. So firstBlockingDate = Mar 20.
        const result = findFirstBlockingDate(
            new Date(2026, 2, 10),
            new Date(2026, 2, 24),
            mapOf({ "2026-03-20": { "1": ["booking"] } }),
            [item("1")],
            null
        );
        expectSameDay(result.firstBlockingDate, "2026-03-20");
        expect(result.reason).to.equal("all_items_have_conflicts");
    });

    it("returns null when the conflict is before start", () => {
        const result = findFirstBlockingDate(
            new Date(2026, 2, 10),
            new Date(2026, 2, 24),
            mapOf({ "2026-03-05": { "1": ["booking"] } }),
            [item("1")],
            null
        );
        expect(result.firstBlockingDate).to.be.null;
    });

    it("treats checkouts as blockers", () => {
        const result = findFirstBlockingDate(
            new Date(2026, 2, 10),
            new Date(2026, 2, 24),
            mapOf({ "2026-03-19": { "1": ["checkout"] } }),
            [item("1")],
            null
        );
        expectSameDay(result.firstBlockingDate, "2026-03-19");
        expect(result.reason).to.equal("all_items_have_conflicts");
    });

    it("blocks the earliest possible end when the start day itself conflicts", () => {
        const result = findFirstBlockingDate(
            new Date(2026, 2, 10),
            new Date(2026, 2, 24),
            mapOf({ "2026-03-10": { "1": ["booking"] } }),
            [item("1")],
            null
        );
        expectSameDay(result.firstBlockingDate, "2026-03-11");
    });

    it("ignores display-only reasons (holiday, lead-floor)", () => {
        const result = findFirstBlockingDate(
            new Date(2026, 2, 10),
            new Date(2026, 2, 24),
            mapOf({
                "2026-03-15": { "1": ["holiday", "lead-floor"] },
            }),
            [item("1")],
            null
        );
        expect(result.firstBlockingDate).to.be.null;
    });
});

describe("findFirstBlockingDate (multiple items)", () => {
    it("returns null when at least one item is free across the window", () => {
        // Item 1 booked Mar 20, item 2 free. A range using item 2 is fine,
        // so no candidate end date all-items-blocks.
        const result = findFirstBlockingDate(
            new Date(2026, 2, 10),
            new Date(2026, 2, 24),
            mapOf({ "2026-03-20": { "1": ["booking"] } }),
            [item("1"), item("2")],
            null
        );
        expect(result.firstBlockingDate).to.be.null;
    });

    it("returns the candidate end date when every item is blocked at some point in the range", () => {
        // Both items blocked on Mar 20 (different bookings) — any range
        // covering Mar 20 has no free item. firstBlockingDate = Mar 20.
        const result = findFirstBlockingDate(
            new Date(2026, 2, 10),
            new Date(2026, 2, 24),
            mapOf({
                "2026-03-20": { "1": ["booking"], "2": ["booking"] },
            }),
            [item("1"), item("2")],
            null
        );
        expectSameDay(result.firstBlockingDate, "2026-03-20");
        expect(result.reason).to.equal("all_items_have_conflicts");
    });

    it("accumulates disjoint per-item conflicts across the range", () => {
        // Item 1 blocked Mar 18, item 2 blocked Mar 21: from Mar 21 on,
        // no single item can serve [Mar 10, X].
        const result = findFirstBlockingDate(
            new Date(2026, 2, 10),
            new Date(2026, 2, 24),
            mapOf({
                "2026-03-18": { "1": ["booking"] },
                "2026-03-21": { "2": ["checkout"] },
            }),
            [item("1"), item("2")],
            null
        );
        expectSameDay(result.firstBlockingDate, "2026-03-21");
    });

    it("narrows to a specific item when selectedItem is set", () => {
        // Same as the "at least one item free" case BUT we've selected
        // item 1, so item 2's freedom doesn't help. firstBlockingDate = Mar 20.
        const result = findFirstBlockingDate(
            new Date(2026, 2, 10),
            new Date(2026, 2, 24),
            mapOf({ "2026-03-20": { "1": ["booking"] } }),
            [item("1"), item("2")],
            "1"
        );
        expectSameDay(result.firstBlockingDate, "2026-03-20");
        expect(result.reason).to.equal("booking");
    });
});

describe("findFirstBlockingDate (lead/trail period influence)", () => {
    it("treats server-marked trail windows as blockers", () => {
        // The server pads existing bookings with their trail window, so a
        // range reaching into it has no free item.
        const result = findFirstBlockingDate(
            new Date(2026, 2, 10),
            new Date(2026, 2, 26),
            mapOf({
                "2026-03-23": { "1": ["trail"] },
                "2026-03-25": { "1": ["booking"] },
            }),
            [item("1")],
            null
        );
        expectSameDay(result.firstBlockingDate, "2026-03-23");
        expect(result.reason).to.equal("all_items_have_conflicts");
    });
});
