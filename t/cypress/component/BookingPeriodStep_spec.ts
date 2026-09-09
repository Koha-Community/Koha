import { provide } from "vue";
import BookingPeriodStep from "@koha-vue/components/Bookings/BookingPeriodStep.vue";
import { useBookingStore } from "@koha-vue/stores/bookings";

const item = id => ({
    item_id: id,
    title: `Item ${id}`,
    barcode: `bar-${id}`,
});

// Pin today to before the March 2026 fixtures so createDisableFunction's
// past-date guard does not poison assertions. Pass an ISO string per
// reference_cypress_clock_cross_realm_dates — a Date instance would
// cross realms once handed to AUT-side libraries.
beforeEach(() => {
    cy.clock(new Date("2026-02-15T12:00:00Z").getTime(), ["Date"]);
});

// Parent wrapper that either seeds simple derived-state fixtures synchronously
// or initializes remote context through the public modal-session workflow.
// Tests that need internal availability use workflowInput rather than creating
// a property that is intentionally absent from the public Pinia surface.
const Host = {
    components: { BookingPeriodStep },
    props: [
        "stepNumber",
        "calendarEnabled",
        "storeSeed",
        "constraints",
        "workflowInput",
    ],
    emits: ["clear-dates"],
    setup(props) {
        const store = useBookingStore();
        provide("bookingStore", store);
        if (props.workflowInput) {
            store.openForCreate(props.workflowInput).catch(() => {});
        } else {
            Object.assign(store, {
                bookableItems: [item("1")],
                holidays: [],
                circulationRules: [],
                selectedDateRange: [],
                ...(props.storeSeed || {}),
            });
            if (props.constraints) {
                store.dateRangeConstraint =
                    props.constraints.dateRangeConstraint ?? null;
            }
        }
        return {};
    },
    template: `
        <BookingPeriodStep
            :step-number="stepNumber"
            :calendar-enabled="calendarEnabled"
            @clear-dates="$emit('clear-dates')"
        />
    `,
};

function mountStep(storeSeed = {}, props = {}) {
    return cy.mount(Host, {
        props: {
            stepNumber: 1,
            calendarEnabled: true,
            storeSeed,
            ...props,
        },
    });
}

// Scope: this spec covers the picker-free wiring around BookingPeriodStep
// — pure DOM/store assertions that don't need the flatpickr calendar to
// be open. Picker interaction (range commit, hover-trail/lead, hover
// feedback, auto-navigate-end) is exercised by the integration specs at
// t/cypress/integration/Circulation/bookingsModal*_spec.ts; the
// underlying primitives (BookingCalendar, useBookingCalendarMaps) have
// dedicated component specs.

describe("BookingPeriodStep — constraint info alert", () => {
    it("renders the alert when a constraint and a positive max period are set", () => {
        // dateRangeConstraint=issuelength + circulationRules.issuelength=7
        // resolves through calculateMaxBookingPeriod to maxBookingPeriod=7.
        mountStep(
            { circulationRules: [{ issuelength: 7 }] },
            { constraints: { dateRangeConstraint: "issuelength" } }
        );
        cy.get(".booking-constraint-info").should("exist");
        cy.get(".booking-constraint-info").should(
            "contain.text",
            "Booking period limited to checkout length (7 days)"
        );
    });

    it("hides the alert when maxBookingPeriod is zero", () => {
        // 0 means "no booking allowed" — surfacing the help text would
        // contradict the disabled state, so the alert short-circuits.
        mountStep(
            { circulationRules: [{ issuelength: 0 }] },
            { constraints: { dateRangeConstraint: "issuelength" } }
        );
        cy.get(".booking-constraint-info").should("not.exist");
    });

    it("hides the alert when no constraint is configured", () => {
        // Without constraint state, dateRangeConstraint stays null
        // and maxBookingPeriod resolves to null — the alert's v-if is
        // gated on dateRangeConstraint, so it's hidden either way.
        mountStep({ circulationRules: [{ issuelength: 7 }] });
        cy.get(".booking-constraint-info").should("not.exist");
    });
});

describe("BookingPeriodStep — constraintHelpText per variant", () => {
    it("renders the issuelength_with_renewals variant with the combined period", () => {
        // issuelength=5, renewalperiod=3, renewalsallowed=2 →
        // calculateMaxBookingPeriod = 5 + 3 * 2 = 11.
        mountStep(
            {
                circulationRules: [
                    {
                        issuelength: 5,
                        renewalperiod: 3,
                        renewalsallowed: 2,
                    },
                ],
            },
            {
                constraints: {
                    dateRangeConstraint: "issuelength_with_renewals",
                },
            }
        );
        cy.get(".booking-constraint-info").should(
            "contain.text",
            "Booking period limited to checkout length with renewals (11 days)"
        );
    });

    it("renders the no-period variant when maxBookingPeriod is null", () => {
        // Empty circulationRules → calculateMaxBookingPeriod returns null
        // (early return at rules?.[0]). The alert still shows because its
        // v-if accepts a null period, and constraintHelpText drops the
        // (X days) suffix.
        mountStep(
            { circulationRules: [] },
            { constraints: { dateRangeConstraint: "issuelength" } }
        );
        cy.get(".booking-constraint-info")
            .should("contain.text", "Booking period limited to checkout length")
            .should("not.contain.text", "(");
    });
});

describe("BookingPeriodStep — accessibility", () => {
    it("marks the booking period as required", () => {
        mountStep();
        cy.get("#booking_period").should("have.attr", "required");
        cy.get("#booking_period").should("have.attr", "aria-required", "true");
        cy.contains("span.required", "Required").should("be.visible");
    });

    it("associates focused conflicts with item labels without exposing internal IDs", () => {
        cy.intercept("GET", "**/api/v1/biblios/1/items*", {
            body: [
                {
                    item_id: 987,
                    item_type_id: "BK",
                    home_library_id: "CPL",
                    external_id: "visible-barcode",
                },
            ],
        });
        cy.intercept("GET", "**/api/v1/biblios/1/pickup_locations*", {
            body: [
                {
                    library_id: "CPL",
                    name: "Centerville",
                    pickup_items: [987],
                },
            ],
        });
        cy.intercept("GET", "**/api/v1/circulation_rules*", {
            body: [{ issuelength: 14 }],
        });
        cy.intercept("GET", "**/api/v1/biblios/1/booking_availability*", {
            body: {
                item_ids: [987, 654],
                availability: {
                    "2026-03-14": {
                        987: {
                            blockers: { booking: 1 },
                            confirms: {},
                            warnings: {},
                        },
                        654: {
                            blockers: { booking: 1 },
                            confirms: {},
                            warnings: {},
                        },
                    },
                },
            },
        }).as("bookingAvailability");
        cy.intercept("GET", "**/api/v1/libraries/CPL/closed_dates*", {
            body: [],
        });

        mountStep(
            {},
            {
                workflowInput: {
                    biblionumber: 1,
                    patron: {
                        patron_id: 42,
                        category_id: "ST",
                        library_id: "CPL",
                    },
                    itemtypeId: "BK",
                    pickupLibraryId: "CPL",
                    selectedDateRange: ["2026-03-10", "2026-03-11"],
                },
            }
        );
        cy.wait("@bookingAvailability");

        cy.get("#booking_period").focus().trigger("keydown", {
            key: "ArrowDown",
            code: "ArrowDown",
            keyCode: 40,
            which: 40,
        });
        for (let i = 0; i < 3; i++) {
            cy.focused().trigger("keydown", {
                key: "ArrowRight",
                code: "ArrowRight",
                keyCode: 39,
                which: 39,
            });
        }
        cy.focused()
            .should("have.attr", "aria-label", "March 14, 2026")
            .and(
                "have.attr",
                "title",
                "Booked (Barcode: N/A)\nBooked (Barcode: visible-barcode)"
            );
        cy.focused()
            .should("have.attr", "aria-describedby")
            .then(describedBy => {
                const ids = String(describedBy).split(/\s+/);
                const details = ids
                    .map(id => document.getElementById(id))
                    .find(element =>
                        element?.classList.contains("booking-day-details")
                    );
                expect(details).not.to.equal(undefined);
                expect(details?.getAttribute("role")).to.equal("status");
                expect(details?.getAttribute("aria-live")).to.equal("polite");
                expect(details?.textContent).to.contain(
                    "Booked (Barcode: visible-barcode)"
                );
                expect(details?.textContent).to.contain(
                    "Booked (Barcode: N/A)"
                );
                expect(details?.textContent).not.to.contain("987");
                expect(details?.textContent).not.to.contain("654");
            });
    });
});

describe("BookingPeriodStep — clear button", () => {
    it("empties selectedDateRange in the store and emits clear-dates", () => {
        const onClear = cy.stub().as("onClear");
        mountStep(
            {
                selectedDateRange: [
                    "2026-03-10T00:00:00.000Z",
                    "2026-03-14T00:00:00.000Z",
                ],
            },
            { "onClear-dates": onClear }
        );
        cy.get(".booking-date-picker-append button").click();
        cy.then(() => {
            const store = useBookingStore();
            expect(store.selectedDateRange).to.deep.equal([]);
        });
        cy.get("@onClear").should("have.been.calledOnce");
    });

    it("disables the clear button when calendarEnabled is false", () => {
        // calendarEnabled false is how the parent step gates input until
        // upstream selections (item type / patron) are made. The clear
        // button mirrors the picker's enabled state so users can't reset
        // a disabled control.
        mountStep({}, { calendarEnabled: false });
        cy.get(".booking-date-picker-append button").should("be.disabled");
    });
});
