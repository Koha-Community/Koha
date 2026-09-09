import BookingCalendar from "@koha-vue/components/Bookings/BookingCalendar.vue";
import { ref } from "vue";

const MARCH_2026 = { year: 2026, month: 2 };

const day = label => cy.get(`.flatpickr-day[aria-label="${label}"]`);

const pressKey = (key, keyCode, options = {}) =>
    cy.focused().trigger("keydown", {
        key,
        code: key === " " ? "Space" : key,
        keyCode,
        which: keyCode,
        ...options,
    });

const mountCalendar = (props = {}) =>
    cy.mount(BookingCalendar, {
        props: {
            viewport: MARCH_2026,
            minDate: "2026-03-01",
            ...props,
        },
    });

const openCalendar = () => cy.get("#booking_period").click();

describe("BookingCalendar", () => {
    describe("booking range state", () => {
        it("omits Koha's ambient date shortcut plugins", () => {
            mountCalendar();

            cy.get("#booking_period").then($input => {
                expect($input[0]._flatpickr.config.plugins).to.deep.equal([]);
            });
            cy.get(".shortcut-buttons-flatpickr-buttons").should("not.exist");
        });

        it("emits anchor and committed range values across two clicks", () => {
            const onUpdate = cy.stub().as("onUpdate");
            mountCalendar({ "onUpdate:modelValue": onUpdate });
            openCalendar();

            day("March 10, 2026").click();
            cy.get("@onUpdate").its("lastCall.args.0").should("have.length", 1);
            day("March 14, 2026").click();
            cy.get("@onUpdate").its("lastCall.args.0").should("have.length", 2);
        });

        it("applies an external committed range without re-emitting it", () => {
            const onUpdate = cy.stub().as("onUpdate");
            mountCalendar({
                modelValue: [new Date("2026-03-10"), new Date("2026-03-14")],
                "onUpdate:modelValue": onUpdate,
            });
            openCalendar();

            day("March 10, 2026").should("have.class", "startRange");
            day("March 14, 2026").should("have.class", "endRange");
            cy.get("@onUpdate").should("not.have.been.called");
        });

        it("starts fixed-anchor selection from an external one-day range", () => {
            mountCalendar({ modelValue: [new Date("2026-03-10")] });
            openCalendar();

            day("March 10, 2026").should("have.class", "selected");
            day("March 14, 2026").click();
            day("March 10, 2026").should("have.class", "startRange");
        });

        it("preserves an edit range when disable rules refresh", () => {
            mountCalendar({
                modelValue: [new Date("2026-03-10"), new Date("2026-03-14")],
            }).then(({ wrapper }) => {
                openCalendar();
                day("March 10, 2026").should("have.class", "startRange");
                wrapper.setProps({
                    disabled: new Map([
                        [
                            "2026-03-10",
                            {
                                reason: "Existing conflict",
                                severity: "hard",
                            },
                        ],
                    ]),
                });
            });

            cy.window().then(
                win =>
                    new Cypress.Promise(resolve =>
                        win.requestAnimationFrame(resolve)
                    )
            );
            day("March 10, 2026").should("have.class", "startRange");
            day("March 14, 2026").should("have.class", "endRange");
        });
    });

    describe("keyboard interaction", () => {
        it("keeps the popup inside its modal focus boundary", () => {
            cy.mount({
                components: { BookingCalendar },
                data: () => ({ viewport: MARCH_2026 }),
                template: `
                    <div class="modal" data-cy="modal">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <BookingCalendar
                                    :viewport="viewport"
                                    min-date="2026-03-01"
                                />
                            </div>
                        </div>
                    </div>
                `,
            });

            cy.get("#booking_period").focus();
            cy.get("[data-cy='modal'] > .flatpickr-calendar")
                .should("exist")
                .and("have.css", "position", "fixed");
        });

        it("opens, moves by day and month, and restores focus on Escape", () => {
            mountCalendar();
            cy.get("#booking_period").focus();
            pressKey("Enter", 13);

            cy.get("#booking_period")
                .should("have.attr", "aria-haspopup", "dialog")
                .and("have.attr", "aria-controls", "booking_period_calendar")
                .and("have.attr", "aria-expanded", "true");
            cy.get(".flatpickr-calendar.open")
                .should("have.attr", "role", "dialog")
                .and("have.attr", "aria-label", "Choose date");
            cy.focused()
                .should("have.class", "flatpickr-day")
                .and("have.attr", "aria-label", "March 1, 2026")
                .and("have.attr", "role", "button")
                .and("have.attr", "tabindex", "0");

            pressKey("ArrowRight", 39);
            cy.focused().should("have.attr", "aria-label", "March 2, 2026");
            pressKey("ArrowDown", 40);
            cy.focused().should("have.attr", "aria-label", "March 9, 2026");
            pressKey("PageDown", 34);
            cy.focused().should("have.attr", "aria-label", "April 9, 2026");
            pressKey("PageUp", 33);
            cy.focused().should("have.attr", "aria-label", "March 9, 2026");

            pressKey("Escape", 27);
            cy.get(".flatpickr-calendar.open").should("not.exist");
            cy.focused()
                .should("have.attr", "id", "booking_period")
                .and("have.attr", "aria-expanded", "false");
        });

        it("selects a range with Enter and Space", () => {
            const onUpdate = cy.stub().as("onUpdate");
            mountCalendar({ "onUpdate:modelValue": onUpdate });

            cy.get("#booking_period").focus();
            pressKey("ArrowDown", 40);
            cy.focused().should("have.attr", "aria-label", "March 1, 2026");
            pressKey("Enter", 13);
            cy.get("@onUpdate").its("lastCall.args.0").should("have.length", 1);
            pressKey("ArrowRight", 39);
            pressKey("ArrowRight", 39);
            pressKey(" ", 32);

            cy.get("@onUpdate").its("lastCall.args.0").should("have.length", 2);
            cy.get(".flatpickr-calendar.open").should("not.exist");
            cy.focused().should("have.attr", "id", "booking_period");
        });

        it("focuses disabled conflict days and reports blocked selection", () => {
            const onHover = cy.stub().as("onHover");
            const onBlocked = cy.stub().as("onBlocked");
            mountCalendar({
                disabled: new Map([
                    [
                        "2026-03-02",
                        { reason: "Existing booking", severity: "hard" },
                    ],
                ]),
                markersByDate: new Map([
                    [
                        "2026-03-02",
                        [{ kind: "booked", tooltip: "item-barcode" }],
                    ],
                ]),
                "onDay-hover": onHover,
                "onSelect-attempt-blocked": onBlocked,
            });

            cy.get("#booking_period").focus();
            pressKey("ArrowDown", 40);
            cy.focused().should("have.attr", "aria-label", "March 1, 2026");
            pressKey("ArrowRight", 39);
            cy.focused()
                .should("have.attr", "aria-label", "March 2, 2026")
                .and("have.attr", "aria-disabled", "true");
            cy.get("@onHover")
                .its("lastCall.args.0.trigger")
                .should("equal", "focus");
            pressKey("Enter", 13);
            cy.get("@onBlocked")
                .should("have.been.calledOnce")
                .its("lastCall.args.0.reason")
                .should("equal", "Existing booking");
        });

        it("preserves focused day when availability redraws", () => {
            mountCalendar().then(({ wrapper }) => {
                openCalendar();
                day("March 14, 2026").focus();
                wrapper.setProps({
                    disabled: new Map([
                        [
                            "2026-03-20",
                            { reason: "Conflict", severity: "hard" },
                        ],
                    ]),
                });
            });

            cy.window().then(
                win =>
                    new Cypress.Promise(resolve =>
                        win.requestAnimationFrame(resolve)
                    )
            );
            cy.focused().should("have.attr", "aria-label", "March 14, 2026");
        });
    });

    describe("availability presentation", () => {
        it("hard-disables a mapped date", () => {
            const onUpdate = cy.stub().as("onUpdate");
            mountCalendar({
                disabled: new Map([
                    ["2026-03-15", { reason: "Closed", severity: "hard" }],
                ]),
                "onUpdate:modelValue": onUpdate,
            });
            openCalendar();

            day("March 15, 2026").should("have.class", "flatpickr-disabled");
            day("March 15, 2026").click({ force: true });
            cy.get("@onUpdate").should("not.have.been.called");
        });

        it("accepts a function-form hard-disabled predicate", () => {
            mountCalendar({
                disabled: date =>
                    date.getDate() === 15
                        ? {
                              reason: "Mid-month closed",
                              severity: "hard",
                          }
                        : null,
            });
            openCalendar();

            day("March 15, 2026").should("have.class", "flatpickr-disabled");
            day("March 14, 2026").should(
                "not.have.class",
                "flatpickr-disabled"
            );
        });

        it("styles soft-disabled dates and reports blocked endpoint clicks", () => {
            const onBlocked = cy.stub().as("onBlocked");
            mountCalendar({
                disabled: new Map([
                    ["2026-03-15", { reason: "Holiday", severity: "soft" }],
                ]),
                "onSelect-attempt-blocked": onBlocked,
            });
            openCalendar();

            day("March 15, 2026")
                .should("have.class", "booking-fp-soft-disabled")
                .and("not.have.class", "flatpickr-disabled")
                .click();
            cy.get("@onBlocked").should("have.been.calledOnce");
        });

        it("allows a range to cross a soft-disabled date", () => {
            const onUpdate = cy.stub().as("onUpdate");
            mountCalendar({
                disabled: new Map([
                    ["2026-03-12", { reason: "Holiday", severity: "soft" }],
                ]),
                "onUpdate:modelValue": onUpdate,
            });
            openCalendar();

            day("March 10, 2026").click();
            day("March 14, 2026").click();
            cy.get("@onUpdate").its("lastCall.args.0").should("have.length", 2);
        });

        it("applies marker classes and combines their tooltips", () => {
            mountCalendar({
                markersByDate: new Map([
                    [
                        "2026-03-15",
                        [
                            {
                                kind: "booked",
                                className: "booking-day--booked",
                                tooltip: "Booked (Barcode: 1)",
                            },
                            {
                                kind: "booked",
                                className: "booking-day--booked",
                                tooltip: "Booked (Barcode: 2)",
                            },
                            {
                                kind: "checked-out",
                                className: "booking-day--checked-out",
                            },
                        ],
                    ],
                ]),
            });
            openCalendar();

            day("March 15, 2026")
                .should("have.class", "booking-day--booked")
                .and("have.class", "booking-day--checked-out")
                .and(
                    "have.attr",
                    "title",
                    "Booked (Barcode: 1)\nBooked (Barcode: 2)"
                );
        });

        it("applies updated calendar classes without losing the anchor", () => {
            mountCalendar({
                modelValue: [new Date("2026-03-10")],
                classByDate: new Map([["2026-03-15", "preview-initial"]]),
            }).then(({ wrapper }) => {
                openCalendar();
                day("March 15, 2026")
                    .should("have.class", "preview-initial")
                    .then(() =>
                        wrapper.setProps({
                            classByDate: new Map([
                                ["2026-03-15", "preview-updated"],
                            ]),
                        })
                    );
            });

            day("March 15, 2026")
                .should("have.class", "preview-updated")
                .and("not.have.class", "preview-initial");
            day("March 10, 2026").should("have.class", "selected");
        });
    });

    describe("calendar integration", () => {
        it("emits day details for pointer and keyboard interaction", () => {
            const onHover = cy.stub().as("onHover");
            const onLeave = cy.stub().as("onLeave");
            mountCalendar({
                "onDay-hover": onHover,
                "onDay-leave": onLeave,
            });
            openCalendar();

            day("March 14, 2026").trigger("mouseover");
            cy.get("@onHover")
                .its("lastCall.args.0.trigger")
                .should("equal", "pointer");
            day("March 15, 2026").focus();
            cy.get("@onHover")
                .its("lastCall.args.0.trigger")
                .should("equal", "focus");
            cy.get("#booking_period").focus();
            cy.get("@onLeave").should("have.been.called");
        });

        it("emits the initial and changed viewport", () => {
            const onViewport = cy.stub().as("onViewport");
            mountCalendar({ "onUpdate:viewport": onViewport });
            openCalendar();

            day("March 15, 2026").should("exist");
            cy.get(".flatpickr-next-month").click();
            cy.get("@onViewport").should("have.been.called");
        });

        it("emits the Flatpickr instance when ready", () => {
            const onReady = cy.stub().as("onReady");
            mountCalendar({ onReady });

            cy.get("@onReady")
                .should("have.been.calledOnce")
                .its("lastCall.args.0")
                .should("have.property", "calendarContainer");
        });

        it("exposes only the clear operation needed by BookingPeriodStep", () => {
            const Host = {
                components: { BookingCalendar },
                setup() {
                    const calendar = ref(null);
                    const modelValue = [
                        new Date("2026-03-10"),
                        new Date("2026-03-14"),
                    ];
                    return { calendar, modelValue, viewport: MARCH_2026 };
                },
                template: `
                    <BookingCalendar
                        ref="calendar"
                        :viewport="viewport"
                        min-date="2026-03-01"
                        :model-value="modelValue"
                    />
                `,
            };
            let host;
            cy.mount(Host).then(({ wrapper }) => {
                host = wrapper;
                openCalendar();
                day("March 10, 2026").should("have.class", "startRange");
            });
            cy.then(() => host.vm.calendar.clear());
            cy.get(".flatpickr-day.selected").should("not.exist");
        });
    });
});

describe("BookingCalendar ambient date configuration", () => {
    afterEach(() => {
        window.flatpickr.setDefaults({ altFormat: "Y-m-d" });
    });

    it("uses Koha's ambient display format and Y-m-d storage format", () => {
        window.flatpickr.setDefaults({ altFormat: "d/m/Y" });
        mountCalendar();
        openCalendar();
        day("March 15, 2026").click();
        day("March 16, 2026").click();

        cy.get("#booking_period").should(
            "have.value",
            "15/03/2026 to 16/03/2026"
        );
        cy.get("#booking_period").should("have.attr", "required");
        cy.get("#booking_period").should("have.attr", "aria-required", "true");
        cy.get("#booking_period_value").should(
            "have.value",
            "2026-03-15 to 2026-03-16"
        );
    });

    it("syncs disabled state to the visible required input", () => {
        window.flatpickr.setDefaults({ altFormat: "d/m/Y" });
        mountCalendar({ inputDisabled: true }).then(({ wrapper }) => {
            cy.get("#booking_period").should("be.disabled");
            cy.then(() => wrapper.setProps({ inputDisabled: false }));
            cy.get("#booking_period").should("not.be.disabled");
        });
    });
});
