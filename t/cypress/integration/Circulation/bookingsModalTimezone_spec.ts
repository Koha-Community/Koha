const dayjs = require("dayjs");
const utc = require("dayjs/plugin/utc");
const timezone = require("dayjs/plugin/timezone");
dayjs.extend(utc);
dayjs.extend(timezone);

// Pin for cy.clock(..., ["Date"]): the 10th of next month at 09:00 local.
// Anchoring "today" to a fixed day-of-month keeps every relative offset
// used below inside the current or next calendar month, so the date
// assertions can run unconditionally instead of being silently skipped
// when a real late-in-month "today" pushes them out of view. Deriving
// the pin from the real date (rather than hardcoding one) keeps the
// bookings these tests create in the future.
const pinnedToday = () =>
    dayjs().add(1, "month").date(10).hour(9).minute(0).second(0).millisecond(0);

// The library's configured timezone (window.$timezone(), server-rendered
// from KohaDates.tz), captured once from a live staff page. The day-boundary
// contract anchors bookings to this zone, so fixtures must be built with it.
let libraryTz = "UTC";

// Serialize a local dayjs day as the day-boundary instants the modal submits
// (see BookingModal handleSubmit): the calendar date re-anchored in the
// library timezone. Fixtures below store bookings under this contract so the
// specs exercise the same data shape production bookings have.
const libraryDayStart = d =>
    dayjs.tz(d.format("YYYY-MM-DD"), libraryTz).startOf("day").toISOString();
const libraryDayEnd = d =>
    dayjs.tz(d.format("YYYY-MM-DD"), libraryTz).endOf("day").toISOString();

describe("Booking Modal Timezone Tests", () => {
    let testData = {};

    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");

        // Read the server timezone from the live page; the day-boundary
        // fixtures below are built with it.
        cy.window().then(win => {
            libraryTz = win.$timezone();
        });

        // Create fresh test data for each test; the item is born bookable
        // via the builder.
        cy.task("insertSampleBiblio", {
            item_count: 1,
            item_values: {
                bookable: 1,
                item_type_id: "BK",
                serial_issue_number: "A",
                acquisition_date: "2024-12-03",
            },
        })
            .then(objects => {
                testData = objects;
                return cy.task("insertSamplePatron", {
                    library: testData.libraries[0],
                });
            })
            .then(patronResult => {
                testData.patron = patronResult.patron;
            });
    });

    afterEach(() => {
        // Clean up test data
        if (testData.biblio) {
            cy.task("deleteSampleObjects", testData);
        }
    });

    // Helper function to setup modal
    const setupModal = () => {
        cy.intercept(
            "GET",
            `/api/v1/biblios/${testData.biblio.biblio_id}/pickup_locations*`
        ).as("getPickupLocations");
        cy.intercept("GET", "/api/v1/circulation_rules*", {
            body: [
                {
                    bookings_lead_period: 0,
                    bookings_trail_period: 0,
                    issuelength: 14,
                    renewalsallowed: 2,
                    renewalperiod: 7,
                },
            ],
        }).as("getCirculationRules");

        cy.visit(
            `/cgi-bin/koha/catalogue/detail.pl?biblionumber=${testData.biblio.biblio_id}`
        );

        cy.get("booking-modal .modal").should("exist");
        cy.get("[data-booking-modal]")
            .first()
            .then($btn => $btn[0].click());
        cy.get("booking-modal .modal", { timeout: 10000 }).should("be.visible");

        cy.vueSelect(
            "booking_patron",
            testData.patron.cardnumber,
            `${testData.patron.surname} ${testData.patron.firstname}`
        );
        cy.wait("@getPickupLocations");

        cy.vueSelectShouldBeEnabled("pickup_library_id");
        cy.vueSelectByIndex("pickup_library_id", 0);

        cy.vueSelectShouldBeEnabled("booking_item_id");
        cy.vueSelectByIndex("booking_item_id", 0);
        cy.wait("@getCirculationRules");

        cy.get("#booking_period").should("not.be.disabled");
    };

    /**
     * TIMEZONE TEST 1: Date Index Creation Consistency
     */
    it("should display bookings on correct calendar dates regardless of timezone offset", () => {
        cy.log("=== Testing date index creation consistency ===");

        const fixedToday = pinnedToday();
        cy.clock(fixedToday.toDate(), ["Date"]);
        const today = fixedToday.startOf("day");

        const bookingDate = today.add(10, "day");

        // Create booking via the API builder
        cy.task("insertSampleBooking", {
            item: testData.items[0],
            patron: testData.patron,
            pickup_library_id: testData.libraries[0].library_id,
            start_date: libraryDayStart(bookingDate),
            end_date: libraryDayEnd(bookingDate),
        });

        setupModal();

        cy.get("#booking_period").as("flatpickrInput");
        cy.get("@flatpickrInput").openFlatpickr();

        // The date should be disabled (has existing booking) on the correct day
        cy.get("@flatpickrInput")
            .getFlatpickrDate(bookingDate.toDate())
            .should("have.class", "flatpickr-disabled");

        // Verify the day carries the booked marker class (visual indicator)
        cy.get("@flatpickrInput")
            .getFlatpickrDate(bookingDate.toDate())
            .should("have.class", "booking-day--booked");

        // Verify adjacent dates are NOT disabled (no date shift)
        const dayBefore = bookingDate.subtract(1, "day");
        const dayAfter = bookingDate.add(1, "day");

        cy.get("@flatpickrInput")
            .getFlatpickrDate(dayBefore.toDate())
            .should("not.have.class", "flatpickr-disabled");

        cy.get("@flatpickrInput")
            .getFlatpickrDate(dayAfter.toDate())
            .should("not.have.class", "flatpickr-disabled");
    });

    /**
     * TIMEZONE TEST 2: Multi-Day Booking Span
     */
    it("should correctly span multi-day bookings without timezone-induced extra days", () => {
        const fixedToday = pinnedToday();
        cy.clock(fixedToday.toDate(), ["Date"]);
        const today = fixedToday.startOf("day");

        // Create a 3-day booking: should span exactly 3 days (15, 16, 17)
        const bookingStart = today.add(15, "day");
        const bookingEnd = today.add(17, "day");

        cy.task("insertSampleBooking", {
            item: testData.items[0],
            patron: testData.patron,
            pickup_library_id: testData.libraries[0].library_id,
            start_date: libraryDayStart(bookingStart),
            end_date: libraryDayEnd(bookingEnd),
        });

        setupModal();

        cy.get("#booking_period").as("flatpickrInput");
        cy.get("@flatpickrInput").openFlatpickr();

        // All three days should be disabled with booking marker dots
        const expectedDays = [
            bookingStart,
            bookingStart.add(1, "day"),
            bookingStart.add(2, "day"),
        ];

        expectedDays.forEach(date => {
            cy.get("@flatpickrInput")
                .getFlatpickrDate(date.toDate())
                .should("have.class", "flatpickr-disabled");

            cy.get("@flatpickrInput")
                .getFlatpickrDate(date.toDate())
                .should("have.class", "booking-day--booked");
        });

        // The day before and after should NOT be disabled
        const dayBefore = bookingStart.subtract(1, "day");
        const dayAfter = bookingEnd.add(1, "day");

        cy.get("@flatpickrInput")
            .getFlatpickrDate(dayBefore.toDate())
            .should("not.have.class", "flatpickr-disabled");

        cy.get("@flatpickrInput")
            .getFlatpickrDate(dayAfter.toDate())
            .should("not.have.class", "flatpickr-disabled");
    });

    /**
     * TIMEZONE TEST 3: Date Comparison Consistency
     */
    it("should correctly detect conflicts using timezone-aware date comparisons", () => {
        const fixedToday = pinnedToday();
        cy.clock(fixedToday.toDate(), ["Date"]);
        const today = fixedToday.startOf("day");

        // Create an existing booking for days 20-22
        const existingStart = today.add(20, "day");
        const existingEnd = today.add(22, "day");

        cy.task("insertSampleBooking", {
            item: testData.items[0],
            patron: testData.patron,
            pickup_library_id: testData.libraries[0].library_id,
            start_date: libraryDayStart(existingStart),
            end_date: libraryDayEnd(existingEnd),
        });

        setupModal();

        cy.get("#booking_period").as("flatpickrInput");
        cy.get("@flatpickrInput").openFlatpickr();

        // Test: Date within existing booking should be disabled
        const conflictDate = existingStart.add(1, "day");
        const beforeBooking = existingStart.subtract(1, "day");
        const afterBooking = existingEnd.add(1, "day");

        cy.get("@flatpickrInput")
            .getFlatpickrDate(conflictDate.toDate())
            .should("have.class", "flatpickr-disabled");

        // Dates before and after booking should be available
        cy.get("@flatpickrInput")
            .getFlatpickrDate(beforeBooking.toDate())
            .should("not.have.class", "flatpickr-disabled");

        cy.get("@flatpickrInput")
            .getFlatpickrDate(afterBooking.toDate())
            .should("not.have.class", "flatpickr-disabled");
    });

    /**
     * TIMEZONE TEST 4: API Submission Round-Trip
     *
     * In the Vue version, dates are stored in the pinia store and submitted
     * via API. We verify dates via the flatpickr display value and API intercept.
     */
    it("should correctly round-trip dates through API without timezone shifts", () => {
        const today = dayjs().startOf("day");

        // Select a date range in the future
        const startDate = today.add(25, "day");
        const endDate = today.add(27, "day");

        setupModal();

        cy.intercept("POST", `/api/v1/bookings`).as("createBooking");

        cy.get("#booking_period").selectFlatpickrDateRange(startDate, endDate);

        // Verify the dates were selected correctly via the flatpickr instance (format-agnostic)
        cy.get("#booking_period").should($el => {
            const fp = $el[0]._flatpickr;
            expect(fp.selectedDates.length).to.eq(2);
            expect(dayjs(fp.selectedDates[0]).format("YYYY-MM-DD")).to.eq(
                startDate.format("YYYY-MM-DD")
            );
            expect(dayjs(fp.selectedDates[1]).format("YYYY-MM-DD")).to.eq(
                endDate.format("YYYY-MM-DD")
            );
        });

        // Actually submit and assert the payload carries the selected
        // calendar days as library-timezone day boundaries — the contract
        // that keeps the DATE stable across the server's round-trip. The
        // exact-match assertion pins the shape in every runner timezone.
        cy.get('button[form="form-booking"][type="submit"]')
            .should("not.be.disabled")
            .click();

        cy.wait("@createBooking").then(({ request, response }) => {
            expect(response.statusCode).to.eq(201);
            expect(request.body.start_date).to.eq(libraryDayStart(startDate));
            expect(request.body.end_date).to.eq(libraryDayEnd(endDate));
        });
    });

    /**
     * TIMEZONE TEST 5: Cross-Month Boundary
     */
    it("should correctly handle bookings that span month boundaries", () => {
        const today = dayjs().startOf("day");

        // Find the last day of current or next month
        let testMonth = today.month() === 11 ? today : today.add(1, "month");
        const lastDayOfMonth = testMonth.endOf("month").startOf("day");
        const firstDayOfNextMonth = lastDayOfMonth.add(1, "day");

        // Create a booking that spans the month boundary
        const bookingStart = lastDayOfMonth.subtract(1, "day");
        const bookingEnd = firstDayOfNextMonth.add(1, "day");

        cy.task("insertSampleBooking", {
            item: testData.items[0],
            patron: testData.patron,
            pickup_library_id: testData.libraries[0].library_id,
            start_date: libraryDayStart(bookingStart),
            end_date: libraryDayEnd(bookingEnd),
        });

        setupModal();

        cy.get("#booking_period").as("flatpickrInput");
        cy.get("@flatpickrInput").openFlatpickr();

        // Test last day of first month is disabled
        cy.get("@flatpickrInput")
            .getFlatpickrDate(lastDayOfMonth.toDate())
            .should("have.class", "flatpickr-disabled");

        // Navigate to next month and test first day is also disabled
        cy.get(".flatpickr-next-month").click();

        cy.get("@flatpickrInput")
            .getFlatpickrDate(firstDayOfNextMonth.toDate())
            .should("have.class", "flatpickr-disabled");
    });
});
