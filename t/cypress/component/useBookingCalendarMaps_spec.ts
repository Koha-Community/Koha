import BookingCalendar from "@koha-vue/components/Bookings/BookingCalendar.vue";
import { useBookingCalendarMaps } from "@koha-vue/lib/booking/composables/useBookingCalendarMaps.js";
import { computed, toRefs } from "vue";

// This spec tests the composable's contract directly: given input refs,
// it returns Maps + computeds + a function. Most tests inspect those
// outputs via wrapper.vm without mounting BookingCalendar or flatpickr.
// Cross-checks against BookingCalendar's DOM behavior live in
// BookingCalendar_spec; algorithmic correctness of the underlying
// availability/* helpers lives in t/cypress/component/lib/booking/*.
// The remaining DOM smoke tests at the bottom of this file verify that
// the composable's outputs still slot into BookingCalendar cleanly.
//
// The `availability` input is the raw booking_availability endpoint
// payload; fixtures hand-build it per case. The endpoint pre-marks
// existing bookings' lead/trail windows and excludes the booking being
// edited — both are its contract, covered by the backend tests.

const MARCH_2026 = { year: 2026, month: 2 };

const MARCH_RANGE = {
    start: new Date(2026, 2, 1),
    end: new Date(2026, 2, 31),
};

const item = id => ({
    item_id: id,
    title: `Item ${id}`,
    barcode: `bar-${id}`,
});

// A marker's className may itself be space-separated (a run-start/
// run-end modifier alongside the base class, applied when the day
// bridges into or stands as a contiguous Unavailable run) - mirrors how
// onDayCreate in BookingCalendar.vue actually consumes it.
const markerHasClass = (marker, className) =>
    (marker.className || "").split(/\s+/).includes(className);

// Raw endpoint payload from per-date reason arrays:
// availabilityOf({ "2026-03-15": { "1": ["booking"] } })
const BLOCKER_REASONS = new Set(["booking", "checkout", "lead", "trail"]);
const availabilityOf = byDate => {
    const availability = {};
    for (const [date, byItem] of Object.entries(byDate || {})) {
        availability[date] = {};
        for (const [id, reasons] of Object.entries(byItem)) {
            const cell = { blockers: {}, confirms: {}, warnings: {} };
            for (const reason of reasons) {
                cell[BLOCKER_REASONS.has(reason) ? "blockers" : "warnings"][
                    reason
                ] = 1;
            }
            availability[date][id] = cell;
        }
    }
    return { item_ids: [], availability };
};

// Renderless host that wires the composable the same way production does
// (rangeAnchor + selectedDateRange derived from modelValue) and exposes
// every output for direct inspection. No BookingCalendar, no flatpickr.
const ComposableHost = {
    props: [
        "bookableItems",
        "availability",
        "holidays",
        "bookingItemId",
        "bookingItemtypeId",
        "circulationRules",
        "modelValue",
        "maxBookingPeriod",
    ],
    setup(props) {
        const rangeAnchor = computed(() => {
            const v = props.modelValue;
            if (Array.isArray(v) && v.length >= 1 && v[0] instanceof Date)
                return v[0];
            return null;
        });
        const selectedDateRange = computed(() => {
            const v = props.modelValue;
            if (!Array.isArray(v)) return [];
            return v.filter(d => d instanceof Date).map(d => d.toISOString());
        });
        const refs = toRefs(props);
        return useBookingCalendarMaps({
            ...refs,
            rangeAnchor,
            selectedDateRange,
        });
    },
    template: `<div data-cy="composable-host" />`,
};

// DOM smoke harness: mounts BookingCalendar with the composable's outputs
// wired in. Used only by the bottom-of-file smoke describe to confirm the
// composable's Maps still slot into the calendar's prop contract.
const RangeHostWithPicker = {
    components: { BookingCalendar },
    props: [
        "bookableItems",
        "availability",
        "holidays",
        "modelValue",
        "maxBookingPeriod",
        "circulationRules",
    ],
    setup(props) {
        const rangeAnchor = computed(() => {
            const v = props.modelValue;
            if (Array.isArray(v) && v.length >= 1 && v[0] instanceof Date)
                return v[0];
            return null;
        });
        const selectedDateRange = computed(() => {
            const v = props.modelValue;
            if (!Array.isArray(v)) return [];
            return v.filter(d => d instanceof Date).map(d => d.toISOString());
        });
        const refs = toRefs(props);
        const { disabledByDate, markersByDate, classByDate } =
            useBookingCalendarMaps({
                ...refs,
                rangeAnchor,
                selectedDateRange,
            });
        return {
            disabledByDate,
            markersByDate,
            classByDate,
            viewport: MARCH_2026,
        };
    },
    template: `
        <BookingCalendar
            :viewport="viewport"
            min-date="2026-03-01"
            :model-value="modelValue"
            :disabled="disabledByDate"
            :markers-by-date="markersByDate"
            :class-by-date="classByDate"
        />
    `,
};

const day = label => cy.get(`.flatpickr-day[aria-label="${label}"]`);

// Pin today to before the March 2026 fixtures so the past-date guard
// inside createDisableFunction does not poison assertions. Pass an ISO
// string per reference_cypress_clock_cross_realm_dates: a Date instance
// would cross realms when handed to AUT-side libraries.
beforeEach(() => {
    cy.clock(new Date("2026-02-15T12:00:00Z").getTime(), ["Date"]);
});

function defaultProps(overrides) {
    return Object.assign(
        {
            bookableItems: [item("1")],
            availability: availabilityOf({}),
            holidays: [],
            circulationRules: [],
        },
        overrides || {}
    );
}

describe("useBookingCalendarMaps (disabledByDate by item availability)", () => {
    it("hard-disables a day when every item has a booking on it", () => {
        cy.mount(ComposableHost, {
            props: defaultProps({
                bookableItems: [item("1"), item("2")],
                availability: availabilityOf({
                    "2026-03-15": { "1": ["booking"], "2": ["booking"] },
                }),
            }),
        }).then(({ wrapper }) => {
            const entry = wrapper.vm.disabledByDate.get("2026-03-15");
            expect(entry?.severity).to.equal("hard");
            expect(wrapper.vm.disabledByDate.has("2026-03-16")).to.be.false;
        });
    });

    it("does not hard-disable a day when one item is still free", () => {
        cy.mount(ComposableHost, {
            props: defaultProps({
                bookableItems: [item("1"), item("2")],
                availability: availabilityOf({
                    "2026-03-15": { "1": ["booking"] },
                }),
            }),
        }).then(({ wrapper }) => {
            expect(wrapper.vm.disabledByDate.has("2026-03-15")).to.be.false;
        });
    });

    it("hard-disables when one item has a booking and the other is checked out", () => {
        cy.mount(ComposableHost, {
            props: defaultProps({
                bookableItems: [item("1"), item("2")],
                availability: availabilityOf({
                    "2026-03-15": { "1": ["booking"], "2": ["checkout"] },
                }),
            }),
        }).then(({ wrapper }) => {
            expect(
                wrapper.vm.disabledByDate.get("2026-03-15")?.severity
            ).to.equal("hard");
        });
    });

    it("emits a booked marker entry on a day with a booking", () => {
        cy.mount(ComposableHost, {
            props: defaultProps({
                availability: availabilityOf({
                    "2026-03-15": { "1": ["booking"] },
                }),
            }),
        }).then(({ wrapper }) => {
            const markers = wrapper.vm.markersByDate.get("2026-03-15");
            expect(markers, "markers for Mar 15").to.exist;
            expect(markers.some(m => markerHasClass(m, "booking-day--booked")))
                .to.be.true;
        });
    });

    it("never tags an isolated Unavailable day with run-start or run-end", () => {
        // Unlike the hover-preview lead/trail bands, Unavailable never
        // rounds - it's the always-on, most emphatic state on the grid,
        // and a flat-edged block reads as a stronger "this is occupied"
        // signal than a softened pill shape (see the UX spec §2).
        cy.mount(ComposableHost, {
            props: defaultProps({
                availability: availabilityOf({
                    "2026-03-15": { "1": ["booking"] },
                }),
            }),
        }).then(({ wrapper }) => {
            const marker = wrapper.vm.markersByDate
                .get("2026-03-15")
                .find(m => m.kind === "booked");
            expect(markerHasClass(marker, "booking-day--run-start")).to.not.be
                .true;
            expect(markerHasClass(marker, "booking-day--run-end")).to.not.be
                .true;
        });
    });

    it("never tags any day of a multi-day Unavailable run with run-start or run-end", () => {
        cy.mount(ComposableHost, {
            props: defaultProps({
                availability: availabilityOf({
                    "2026-03-15": { "1": ["booking"] },
                    "2026-03-16": { "1": ["booking"] },
                    "2026-03-17": { "1": ["booking"] },
                }),
            }),
        }).then(({ wrapper }) => {
            const markerFor = date =>
                wrapper.vm.markersByDate
                    .get(date)
                    .find(m => m.kind === "booked");

            for (const date of ["2026-03-15", "2026-03-16", "2026-03-17"]) {
                const marker = markerFor(date);
                expect(markerHasClass(marker, "booking-day--run-start")).to.not
                    .be.true;
                expect(markerHasClass(marker, "booking-day--run-end")).to.not.be
                    .true;
            }
        });
    });

    it("emits a checked-out marker entry on a day with a checkout", () => {
        cy.mount(ComposableHost, {
            props: defaultProps({
                availability: availabilityOf({
                    "2026-03-15": { "1": ["checkout"] },
                }),
            }),
        }).then(({ wrapper }) => {
            const markers = wrapper.vm.markersByDate.get("2026-03-15");
            expect(markers).to.exist;
            expect(
                markers.some(m => markerHasClass(m, "booking-day--checked-out"))
            ).to.be.true;
        });
    });

    it("does not mark a day Unavailable when only one of several relevant items is booked", () => {
        cy.mount(ComposableHost, {
            props: defaultProps({
                bookableItems: [item("1"), item("2")],
                availability: availabilityOf({
                    "2026-03-15": { "1": ["booking"] },
                }),
            }),
        }).then(({ wrapper }) => {
            // Item 2 is still free, so the day is still fully bookable -
            // colouring it Unavailable would contradict disabledByDate,
            // which agrees the day isn't disabled (see the "does not
            // hard-disable" test above for the same fixture).
            const markers = wrapper.vm.markersByDate.get("2026-03-15");
            expect(markers?.some(m => m.className === "booking-day--booked")).to
                .not.be.true;
        });
    });

    it("marks a day partial when only one of several relevant items is booked", () => {
        cy.mount(ComposableHost, {
            props: defaultProps({
                bookableItems: [item("1"), item("2")],
                availability: availabilityOf({
                    "2026-03-15": { "1": ["booking"] },
                }),
            }),
        }).then(({ wrapper }) => {
            const markers = wrapper.vm.markersByDate.get("2026-03-15");
            expect(markers.some(m => m.className === "booking-day--partial")).to
                .be.true;
        });
    });

    it("does not mark a day partial once every relevant item is booked", () => {
        cy.mount(ComposableHost, {
            props: defaultProps({
                bookableItems: [item("1"), item("2")],
                availability: availabilityOf({
                    "2026-03-15": { "1": ["booking"], "2": ["booking"] },
                }),
            }),
        }).then(({ wrapper }) => {
            const markers = wrapper.vm.markersByDate.get("2026-03-15");
            expect(markers.some(m => m.className === "booking-day--partial")).to
                .not.be.true;
        });
    });

    it("marks a day Unavailable when a specific item selection narrows to just the booked item", () => {
        cy.mount(ComposableHost, {
            props: defaultProps({
                bookableItems: [item("1"), item("2")],
                bookingItemId: "1",
                availability: availabilityOf({
                    "2026-03-15": { "1": ["booking"] },
                }),
            }),
        }).then(({ wrapper }) => {
            // Item 2's availability is irrelevant once item 1 is the only
            // one the patron can actually get.
            const markers = wrapper.vm.markersByDate.get("2026-03-15");
            expect(markers.some(m => markerHasClass(m, "booking-day--booked")))
                .to.be.true;
            expect(markers.some(m => m.className === "booking-day--partial")).to
                .not.be.true;
        });
    });

    it("marks a day Unavailable when every relevant item is blocked by a mix of booking and checkout", () => {
        cy.mount(ComposableHost, {
            props: defaultProps({
                bookableItems: [item("1"), item("2")],
                availability: availabilityOf({
                    "2026-03-15": { "1": ["booking"], "2": ["checkout"] },
                }),
            }),
        }).then(({ wrapper }) => {
            const markers = wrapper.vm.markersByDate.get("2026-03-15");
            expect(
                markers.some(
                    m =>
                        markerHasClass(m, "booking-day--booked") ||
                        markerHasClass(m, "booking-day--checked-out")
                )
            ).to.be.true;
        });
    });

    it("emits lead-floor / lead-theoretical marker entries as day classes", () => {
        cy.mount(ComposableHost, {
            props: defaultProps({
                availability: availabilityOf({
                    "2026-03-15": {
                        "1": ["lead_floor", "lead_theoretical"],
                    },
                }),
            }),
        }).then(({ wrapper }) => {
            const classes = wrapper.vm.markersByDate
                .get("2026-03-15")
                .map(m => m.className);
            expect(classes).to.include("booking-day--lead-floor");
            expect(classes).to.include("booking-day--lead-theoretical");
        });
    });

    it("tags days whose trail window would hit an existing conflict", () => {
        // Anchor Mar 10, trail 2 days, booking on Mar 15: an end on Mar 13
        // or Mar 14 would push the trail into the booking.
        cy.mount(ComposableHost, {
            props: defaultProps({
                availability: availabilityOf({
                    "2026-03-15": { "1": ["booking"] },
                }),
                modelValue: [new Date("2026-03-10")],
                circulationRules: [{ bookings_trail_period: 2 }],
            }),
        }).then(({ wrapper }) => {
            const classByDate = wrapper.vm.classByDate;
            expect(classByDate.get("2026-03-13")).to.include(
                "booking-day--trail-theoretical"
            );
            expect(classByDate.get("2026-03-14")).to.include(
                "booking-day--trail-theoretical"
            );
            expect(classByDate.get("2026-03-12") || "").to.not.include(
                "booking-day--trail-theoretical"
            );
        });
    });

    it("exposes translated reasons through unavailableByDate", () => {
        cy.mount(ComposableHost, {
            props: defaultProps({
                availability: availabilityOf({
                    "2026-03-15": { "1": ["lead_floor", "booking"] },
                }),
            }),
        }).then(({ wrapper }) => {
            const reasons = wrapper.vm.unavailableByDate["2026-03-15"]["1"];
            expect(reasons.has("lead-floor")).to.be.true;
            expect(reasons.has("booking")).to.be.true;
        });
    });
});

describe("useBookingCalendarMaps (availability loading state)", () => {
    it("disables every date until the availability payload arrives", () => {
        cy.mount(ComposableHost, {
            props: defaultProps({ availability: null }),
        }).then(({ wrapper }) => {
            expect(wrapper.vm.availabilityReady).to.be.false;
            expect(wrapper.vm.disabledFn(new Date(2026, 2, 20))).to.be.true;
            expect(wrapper.vm.disabledFn(new Date(2026, 5, 1))).to.be.true;
        });
    });

    it("enables clear dates once the payload arrives", () => {
        let host;
        cy.mount(ComposableHost, {
            props: defaultProps({ availability: null }),
        }).then(({ wrapper }) => {
            host = wrapper;
            expect(wrapper.vm.disabledFn(new Date(2026, 2, 20))).to.be.true;
        });
        cy.then(() => host.setProps({ availability: availabilityOf({}) }));
        cy.then(() => {
            expect(host.vm.availabilityReady).to.be.true;
            expect(host.vm.disabledFn(new Date(2026, 2, 20))).to.be.false;
        });
    });
});

describe("useBookingCalendarMaps (anchor-aware soft severity)", () => {
    it("hard-disables a holiday when no anchor is set", () => {
        cy.mount(ComposableHost, {
            props: defaultProps({ holidays: ["2026-03-15"] }),
        }).then(({ wrapper }) => {
            expect(
                wrapper.vm.disabledByDate.get("2026-03-15")?.severity
            ).to.equal("hard");
        });
    });

    it("soft-disables a holiday when an anchor is set", () => {
        cy.mount(ComposableHost, {
            props: defaultProps({
                holidays: ["2026-03-12"],
                modelValue: [new Date(2026, 2, 10), null],
            }),
        }).then(({ wrapper }) => {
            expect(
                wrapper.vm.disabledByDate.get("2026-03-12")?.severity
            ).to.equal("soft");
        });
    });

    it("flips severity when modelValue changes from null to anchor", () => {
        let host;
        cy.mount(ComposableHost, {
            props: defaultProps({
                holidays: ["2026-03-12"],
                modelValue: null,
            }),
        }).then(({ wrapper }) => {
            host = wrapper;
            expect(
                wrapper.vm.disabledByDate.get("2026-03-12")?.severity
            ).to.equal("hard");
        });
        cy.then(() =>
            host.setProps({ modelValue: [new Date(2026, 2, 10), null] })
        );
        cy.then(() => {
            expect(host.vm.disabledByDate.get("2026-03-12")?.severity).to.equal(
                "soft"
            );
        });
    });

    it("keeps a holiday hard-disabled when bookings also block all items that day", () => {
        cy.mount(ComposableHost, {
            props: defaultProps({
                availability: availabilityOf({
                    "2026-03-12": { "1": ["booking"] },
                }),
                holidays: ["2026-03-12"],
                modelValue: [new Date(2026, 2, 10), null],
            }),
        }).then(({ wrapper }) => {
            expect(
                wrapper.vm.disabledByDate.get("2026-03-12")?.severity
            ).to.equal("hard");
        });
    });
});

describe("useBookingCalendarMaps (classByDate constrained-range)", () => {
    // The constrained-range pre-paint only applies in end_date_only mode
    // (see the "end-date-only mode" describe block below), where the end
    // date is forced rather than chosen. In the normal mode - where the
    // user picks their own end date - the range is revealed progressively
    // through hover (disabledFn / rangePreviewFn) instead of being painted
    // the instant the anchor is clicked, so it doesn't read as though the
    // choice has already been made for them.
    it("returns no constrained-range entries when there is no anchor", () => {
        cy.mount(ComposableHost, {
            props: defaultProps({
                modelValue: null,
                maxBookingPeriod: 5,
            }),
        }).then(({ wrapper }) => {
            const has = key =>
                (wrapper.vm.classByDate.get(key) || "").includes(
                    "booking-constrained-range-marker"
                );
            expect(has("2026-03-10")).to.be.false;
            expect(has("2026-03-14")).to.be.false;
        });
    });

    it("does not pre-paint the constrained range once an anchor is picked", () => {
        cy.mount(ComposableHost, {
            props: defaultProps({
                modelValue: [new Date(2026, 2, 10), null],
                maxBookingPeriod: 5,
            }),
        }).then(({ wrapper }) => {
            const has = key =>
                (wrapper.vm.classByDate.get(key) || "").includes(
                    "booking-constrained-range-marker"
                );
            // Would have been anchor..anchor+maxPeriod-1 under the old
            // eager-highlight behaviour; none of it is pre-painted now.
            expect(has("2026-03-10")).to.be.false;
            expect(has("2026-03-12")).to.be.false;
            expect(has("2026-03-14")).to.be.false;
        });
    });

    it("emits no constrained-range entries when maxBookingPeriod is missing or zero", () => {
        cy.mount(ComposableHost, {
            props: defaultProps({
                modelValue: [new Date(2026, 2, 10), null],
                maxBookingPeriod: 0,
            }),
        }).then(({ wrapper }) => {
            const has = key =>
                (wrapper.vm.classByDate.get(key) || "").includes(
                    "booking-constrained-range-marker"
                );
            expect(has("2026-03-10")).to.be.false;
            expect(has("2026-03-14")).to.be.false;
        });
    });
});

describe("useBookingCalendarMaps (rangePreviewFn)", () => {
    it("returns valid for a clear range within maxBookingPeriod", () => {
        cy.mount(ComposableHost, {
            props: defaultProps({
                modelValue: [new Date(2026, 2, 10), null],
                maxBookingPeriod: 10,
            }),
        }).then(({ wrapper }) => {
            const status = wrapper.vm.rangePreviewFn(
                new Date(2026, 2, 10),
                new Date(2026, 2, 14)
            );
            expect(status.status).to.equal("valid");
        });
    });

    it("returns invalid when range exceeds maxBookingPeriod", () => {
        cy.mount(ComposableHost, {
            props: defaultProps({
                modelValue: [new Date(2026, 2, 10), null],
                maxBookingPeriod: 3,
            }),
        }).then(({ wrapper }) => {
            const status = wrapper.vm.rangePreviewFn(
                new Date(2026, 2, 10),
                new Date(2026, 2, 15)
            );
            expect(status.status).to.equal("invalid");
            expect(status.message).to.contain("max booking period");
        });
    });

    it("returns invalid when range crosses a hard-disabled booking day", () => {
        cy.mount(ComposableHost, {
            props: defaultProps({
                availability: availabilityOf({
                    "2026-03-12": { "1": ["booking"] },
                }),
                modelValue: [new Date(2026, 2, 10), null],
                maxBookingPeriod: 30,
            }),
        }).then(({ wrapper }) => {
            const status = wrapper.vm.rangePreviewFn(
                new Date(2026, 2, 10),
                new Date(2026, 2, 14)
            );
            expect(status.status).to.equal("invalid");
        });
    });

    it("returns valid when range crosses only a soft-disabled holiday", () => {
        cy.mount(ComposableHost, {
            props: defaultProps({
                holidays: ["2026-03-12"],
                modelValue: [new Date(2026, 2, 10), null],
                maxBookingPeriod: 30,
            }),
        }).then(({ wrapper }) => {
            const status = wrapper.vm.rangePreviewFn(
                new Date(2026, 2, 10),
                new Date(2026, 2, 14)
            );
            expect(status.status).to.equal("valid");
        });
    });

    it("returns invalid when end is before anchor", () => {
        cy.mount(ComposableHost, {
            props: defaultProps({
                modelValue: [new Date(2026, 2, 10), null],
                maxBookingPeriod: 30,
            }),
        }).then(({ wrapper }) => {
            const status = wrapper.vm.rangePreviewFn(
                new Date(2026, 2, 10),
                new Date(2026, 2, 5)
            );
            expect(status.status).to.equal("invalid");
            expect(status.message).to.contain("on or after");
        });
    });
});

describe("useBookingCalendarMaps (selected-item awareness)", () => {
    it("hard-disables a day when the selected bookingItemId has a booking", () => {
        cy.mount(ComposableHost, {
            props: defaultProps({
                bookableItems: [item("1"), item("2")],
                availability: availabilityOf({
                    "2026-03-15": { "1": ["booking"] },
                }),
                bookingItemId: "1",
            }),
        }).then(({ wrapper }) => {
            expect(
                wrapper.vm.disabledByDate.get("2026-03-15")?.severity
            ).to.equal("hard");
        });
    });

    it("does not hard-disable when bookingItemId points to a free item", () => {
        cy.mount(ComposableHost, {
            props: defaultProps({
                bookableItems: [item("1"), item("2")],
                availability: availabilityOf({
                    "2026-03-15": { "1": ["booking"] },
                }),
                bookingItemId: "2",
            }),
        }).then(({ wrapper }) => {
            expect(wrapper.vm.disabledByDate.has("2026-03-15")).to.be.false;
        });
    });

    it("narrows the disable check to bookingItemtypeId when no specific item is selected", () => {
        const itemWithType = (id, typeId) => ({
            item_id: id,
            title: `Item ${id}`,
            item_type_id: typeId,
            effective_item_type_id: typeId,
        });
        cy.mount(ComposableHost, {
            props: defaultProps({
                bookableItems: [
                    itemWithType("1", "BK"),
                    itemWithType("2", "DVD"),
                ],
                availability: availabilityOf({
                    "2026-03-15": { "1": ["booking"] },
                }),
                bookingItemtypeId: "BK",
            }),
        }).then(({ wrapper }) => {
            expect(
                wrapper.vm.disabledByDate.get("2026-03-15")?.severity
            ).to.equal("hard");
        });
    });

    it("emits lead and trail marker entries from the server map", () => {
        cy.mount(ComposableHost, {
            props: defaultProps({
                availability: availabilityOf({
                    "2026-03-13": { "1": ["lead"] },
                    "2026-03-15": { "1": ["booking"] },
                    "2026-03-17": { "1": ["trail"] },
                }),
            }),
        }).then(({ wrapper }) => {
            const lead = wrapper.vm.markersByDate.get("2026-03-13");
            const trail = wrapper.vm.markersByDate.get("2026-03-17");
            expect(lead).to.exist;
            expect(lead.some(m => m.className === "booking-day--lead")).to.be
                .true;
            expect(trail).to.exist;
            expect(trail.some(m => m.className === "booking-day--trail")).to.be
                .true;
        });
    });
});

// Renderless harness that exposes loanBoundaryTimes directly so the Set
// contents can be asserted without going through the picker. classByDate
// derives the .booking-loan-boundary day class from this Set, so this
// output is a real contract; pin the math.
const LoanBoundaryHost = {
    props: [
        "bookableItems",
        "availability",
        "holidays",
        "modelValue",
        "circulationRules",
    ],
    setup(props) {
        const rangeAnchor = computed(() => {
            const v = props.modelValue;
            if (Array.isArray(v) && v.length >= 1 && v[0] instanceof Date)
                return v[0];
            return null;
        });
        const refs = toRefs(props);
        const { loanBoundaryTimes } = useBookingCalendarMaps({
            ...refs,
            rangeAnchor,
        });
        return { loanBoundaryTimes };
    },
    template: `<div data-cy="loan-boundary-host" />`,
};

describe("useBookingCalendarMaps (loanBoundaryTimes)", () => {
    const startOfDay = (year, month0, day) =>
        new Date(year, month0, day, 0, 0, 0, 0).getTime();

    const loanBoundaryProps = overrides =>
        Object.assign(
            {
                bookableItems: [item("1")],
                availability: availabilityOf({}),
                holidays: [],
                modelValue: null,
                circulationRules: [],
            },
            overrides || {}
        );

    it("returns an empty Set when no anchor is set", () => {
        cy.mount(LoanBoundaryHost, {
            props: loanBoundaryProps({
                circulationRules: [{ issuelength: 7 }],
            }),
        }).then(({ wrapper }) => {
            expect([...wrapper.vm.loanBoundaryTimes]).to.deep.equal([]);
        });
    });

    it("returns just the anchor timestamp when issuelength is missing", () => {
        cy.mount(LoanBoundaryHost, {
            props: loanBoundaryProps({
                modelValue: [new Date(2026, 2, 10), null],
                circulationRules: [{}],
            }),
        }).then(({ wrapper }) => {
            expect([...wrapper.vm.loanBoundaryTimes]).to.deep.equal([
                startOfDay(2026, 2, 10),
            ]);
        });
    });

    it("includes anchor + anchor+issuelength when only issuelength is set", () => {
        cy.mount(LoanBoundaryHost, {
            props: loanBoundaryProps({
                modelValue: [new Date(2026, 2, 10), null],
                circulationRules: [{ issuelength: 7 }],
            }),
        }).then(({ wrapper }) => {
            expect([...wrapper.vm.loanBoundaryTimes].sort()).to.deep.equal(
                [startOfDay(2026, 2, 10), startOfDay(2026, 2, 17)].sort()
            );
        });
    });

    it("adds one boundary per renewal when renewalperiod and renewalsallowed are set", () => {
        // anchor=Mar 10, issuelength=5, renewalperiod=3, renewalsallowed=2:
        // expect {Mar 10, Mar 15 (issuelength), Mar 18 (k=1), Mar 21 (k=2)}.
        cy.mount(LoanBoundaryHost, {
            props: loanBoundaryProps({
                modelValue: [new Date(2026, 2, 10), null],
                circulationRules: [
                    {
                        issuelength: 5,
                        renewalperiod: 3,
                        renewalsallowed: 2,
                    },
                ],
            }),
        }).then(({ wrapper }) => {
            expect([...wrapper.vm.loanBoundaryTimes].sort()).to.deep.equal(
                [
                    startOfDay(2026, 2, 10),
                    startOfDay(2026, 2, 15),
                    startOfDay(2026, 2, 18),
                    startOfDay(2026, 2, 21),
                ].sort()
            );
        });
    });

    it("ignores renewals when renewalperiod is zero", () => {
        cy.mount(LoanBoundaryHost, {
            props: loanBoundaryProps({
                modelValue: [new Date(2026, 2, 10), null],
                circulationRules: [
                    {
                        issuelength: 5,
                        renewalperiod: 0,
                        renewalsallowed: 3,
                    },
                ],
            }),
        }).then(({ wrapper }) => {
            expect([...wrapper.vm.loanBoundaryTimes].sort()).to.deep.equal(
                [startOfDay(2026, 2, 10), startOfDay(2026, 2, 15)].sort()
            );
        });
    });

    it("recomputes when the anchor changes", () => {
        let host;
        cy.mount(LoanBoundaryHost, {
            props: loanBoundaryProps({
                modelValue: [new Date(2026, 2, 10), null],
                circulationRules: [{ issuelength: 5 }],
            }),
        }).then(({ wrapper }) => {
            host = wrapper;
            expect([...wrapper.vm.loanBoundaryTimes].sort()).to.deep.equal(
                [startOfDay(2026, 2, 10), startOfDay(2026, 2, 15)].sort()
            );
        });
        // setProps returns a Promise that resolves after Vue's nextTick;
        // cy.then awaits it so the assertion reads the post-flush value.
        cy.then(() =>
            host.setProps({
                modelValue: [new Date(2026, 2, 20), null],
            })
        );
        cy.then(() => {
            expect([...host.vm.loanBoundaryTimes].sort()).to.deep.equal(
                [startOfDay(2026, 2, 20), startOfDay(2026, 2, 25)].sort()
            );
        });
    });
});

describe("useBookingCalendarMaps (end-date-only mode)", () => {
    // booking_constraint_mode: "end_date_only" means the user picks the
    // anchor and the picker enforces a fixed range from the anchor to the
    // forced end anchor+maxPeriod-1 (the start counts as day 1, mirroring
    // calculateMaxEndDate). Intermediate days inside that span are soft-
    // disabled so they can't be clicked (which would otherwise restart
    // the range); the forced end itself MUST stay clickable — it is the
    // only valid commit target.
    it("soft-disables intermediate dates but keeps the forced end clickable", () => {
        cy.mount(ComposableHost, {
            props: defaultProps({
                modelValue: [new Date(2026, 2, 10), null],
                maxBookingPeriod: 5,
                circulationRules: [
                    { booking_constraint_mode: "end_date_only" },
                ],
            }),
        }).then(({ wrapper }) => {
            // Mar 10 is anchor (day 1); Mar 11..13 are intermediate;
            // Mar 14 = anchor+maxPeriod-1 is the forced end.
            expect(
                wrapper.vm.disabledByDate.get("2026-03-11")?.severity
            ).to.equal("soft");
            expect(
                wrapper.vm.disabledByDate.get("2026-03-13")?.severity
            ).to.equal("soft");
            expect(wrapper.vm.disabledByDate.has("2026-03-14")).to.be.false;
            expect(wrapper.vm.disabledByDate.has("2026-03-15")).to.be.false;
        });
    });

    it("tags intermediates with booking-intermediate-blocked in classByDate", () => {
        cy.mount(ComposableHost, {
            props: defaultProps({
                modelValue: [new Date(2026, 2, 10), null],
                maxBookingPeriod: 5,
                circulationRules: [
                    { booking_constraint_mode: "end_date_only" },
                ],
            }),
        }).then(({ wrapper }) => {
            const has = key =>
                (wrapper.vm.classByDate.get(key) || "").includes(
                    "booking-intermediate-blocked"
                );
            expect(has("2026-03-11")).to.be.true;
            expect(has("2026-03-13")).to.be.true;
            // Anchor and the forced end (anchor+maxPeriod-1) are not
            // intermediates.
            expect(has("2026-03-10")).to.be.false;
            expect(has("2026-03-14")).to.be.false;
        });
    });

    it("space-merges intermediate-blocked with constrained-range-marker", () => {
        // Intermediate days are also inside the constrained range, so the
        // classByDate output joins both classes with a space. A regression
        // that overwrote one with the other would surface here.
        cy.mount(ComposableHost, {
            props: defaultProps({
                modelValue: [new Date(2026, 2, 10), null],
                maxBookingPeriod: 5,
                circulationRules: [
                    { booking_constraint_mode: "end_date_only" },
                ],
            }),
        }).then(({ wrapper }) => {
            const cls = wrapper.vm.classByDate.get("2026-03-12") || "";
            expect(cls).to.contain("booking-intermediate-blocked");
            expect(cls).to.contain("booking-constrained-range-marker");
        });
    });

    it("keeps an intermediate hard-disabled when a booking blocks all items", () => {
        // A hard block (booking covers every relevant item) wins over the
        // intermediate-soft tag — composable's disabledByDate short-circuits
        // when the existing severity is 'hard'.
        cy.mount(ComposableHost, {
            props: defaultProps({
                availability: availabilityOf({
                    "2026-03-12": { "1": ["booking"] },
                }),
                modelValue: [new Date(2026, 2, 10), null],
                maxBookingPeriod: 5,
                circulationRules: [
                    { booking_constraint_mode: "end_date_only" },
                ],
            }),
        }).then(({ wrapper }) => {
            expect(
                wrapper.vm.disabledByDate.get("2026-03-12")?.severity
            ).to.equal("hard");
        });
    });
});

// Smoke tests: the composable's outputs should still slot into BookingCalendar
// cleanly. These mount the calendar and assert on rendered classes — one per
// output type — to catch contract drift between the composable and the
// wrapper without re-testing the per-case logic above.
describe("useBookingCalendarMaps (DOM smoke tests)", () => {
    it("disabledByDate severity 'hard' renders flatpickr-disabled", () => {
        cy.mount(RangeHostWithPicker, {
            props: {
                bookableItems: [item("1"), item("2")],
                availability: availabilityOf({
                    "2026-03-15": { "1": ["booking"], "2": ["booking"] },
                }),
                holidays: [],
                modelValue: null,
                maxBookingPeriod: 0,
                circulationRules: [],
            },
        });
        cy.get("#booking_period").click();
        day("March 15, 2026").should("have.class", "flatpickr-disabled");
    });

    it("markersByDate kind 'booked' renders booking-day--booked", () => {
        cy.mount(RangeHostWithPicker, {
            props: {
                bookableItems: [item("1")],
                availability: availabilityOf({
                    "2026-03-15": { "1": ["booking"] },
                }),
                holidays: [],
                modelValue: null,
                maxBookingPeriod: 0,
                circulationRules: [],
            },
        });
        cy.get("#booking_period").click();
        day("March 15, 2026").should("have.class", "booking-day--booked");
    });

    it("classByDate merges booking-loan-boundary and constrained-range-marker on the right days", () => {
        // Anchor=Mar 10, issuelength=5 → boundaries at Mar 10 and Mar 15.
        // The class must land on the day cell via the classByDate output;
        // this validates the merge with the constrained-range class. The
        // constrained-range marker only pre-paints in end_date_only mode
        // (see the "end-date-only mode" describe block) - that's the only
        // mode this merge can occur in now.
        cy.mount(RangeHostWithPicker, {
            props: {
                bookableItems: [item("1")],
                availability: availabilityOf({}),
                holidays: [],
                modelValue: [new Date("2026-03-10"), null],
                maxBookingPeriod: 10,
                circulationRules: [
                    {
                        issuelength: 5,
                        booking_constraint_mode: "end_date_only",
                    },
                ],
            },
        });
        cy.get("#booking_period").click();
        day("March 10, 2026").should("have.class", "booking-loan-boundary");
        day("March 15, 2026").should("have.class", "booking-loan-boundary");
        // Sanity: a non-boundary day inside the constrained range gets the
        // range marker but not the boundary class.
        day("March 12, 2026")
            .should("have.class", "booking-constrained-range-marker")
            .should("not.have.class", "booking-loan-boundary");
    });
});
