const dayjs = require("dayjs");
const isSameOrBefore = require("dayjs/plugin/isSameOrBefore");
dayjs.extend(isSameOrBefore);

describe("Booking Modal Date Picker Tests", () => {
    let testData = {};

    // Ensure RESTBasicAuth is enabled before running tests
    before(() => {
        cy.task("query", {
            sql: "UPDATE systempreferences SET value = '1' WHERE variable = 'RESTBasicAuth'",
        });
    });

    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");

        // Create fresh test data for each test using upstream pattern
        cy.task("insertSampleBiblio", {
            item_count: 2,
        })
            .then(objects => {
                testData = objects;

                // Update items to be bookable with predictable itemtypes
                const itemUpdates = [
                    // First item: BK (Books)
                    cy.task("query", {
                        sql: "UPDATE items SET bookable = 1, itype = 'BK', homebranch = 'CPL', enumchron = 'A', dateaccessioned = '2024-12-03' WHERE itemnumber = ?",
                        values: [objects.items[0].item_id],
                    }),
                    // Second item: CF (Computer Files)
                    cy.task("query", {
                        sql: "UPDATE items SET bookable = 1, itype = 'CF', homebranch = 'CPL', enumchron = 'B', dateaccessioned = '2024-12-02' WHERE itemnumber = ?",
                        values: [objects.items[1].item_id],
                    }),
                ];

                return Promise.all(itemUpdates);
            })
            .then(() => {
                // Create a test patron using upstream pattern
                return cy.task("buildSampleObject", {
                    object: "patron",
                    values: {
                        firstname: "John",
                        surname: "Doe",
                        cardnumber: `TEST${Date.now()}`,
                        category_id: "PT",
                        library_id: testData.libraries[0].library_id,
                    },
                });
            })
            .then(mockPatron => {
                testData.patron = mockPatron;

                // Insert the patron into the database
                return cy.task("query", {
                    sql: `INSERT INTO borrowers (borrowernumber, firstname, surname, cardnumber, categorycode, branchcode, dateofbirth)
                      VALUES (?, ?, ?, ?, ?, ?, ?)`,
                    values: [
                        mockPatron.patron_id,
                        mockPatron.firstname,
                        mockPatron.surname,
                        mockPatron.cardnumber,
                        mockPatron.category_id,
                        mockPatron.library_id,
                        "1990-01-01",
                    ],
                });
            });
    });

    afterEach(() => {
        // Clean up test data
        if (testData.biblio) {
            cy.task("deleteSampleObjects", testData);
        }
        if (testData.patron) {
            cy.task("query", {
                sql: "DELETE FROM borrowers WHERE borrowernumber = ?",
                values: [testData.patron.patron_id],
            });
        }
    });

    // Helper function to open modal and get to patron/pickup selection ready state
    const setupModalForDateTesting = (options = {}) => {
        // Setup API intercepts
        cy.intercept(
            "GET",
            `/api/v1/biblios/${testData.biblio.biblio_id}/pickup_locations*`
        ).as("getPickupLocations");
        cy.intercept("GET", "/api/v1/circulation_rules*").as(
            "getCirculationRules"
        );

        cy.visit(
            `/cgi-bin/koha/catalogue/detail.pl?biblionumber=${testData.biblio.biblio_id}`
        );

        // Open the modal
        cy.get('[data-bs-target="#placeBookingModal"]').first().click();
        cy.get("#placeBookingModal").should("be.visible");

        // Fill required fields to enable item selection
        cy.selectFromSelect2(
            "#booking_patron_id",
            `${testData.patron.surname}, ${testData.patron.firstname}`,
            testData.patron.cardnumber
        );
        cy.wait("@getPickupLocations");

        cy.get("#pickup_library_id").should("not.be.disabled");
        cy.selectFromSelect2ByIndex("#pickup_library_id", 0);

        // Only auto-select item if not overridden
        if (options.skipItemSelection !== true) {
            cy.get("#booking_item_id").should("not.be.disabled");
            cy.selectFromSelect2ByIndex("#booking_item_id", 1); // Select first item
            cy.wait("@getCirculationRules");

            // Verify date picker is now enabled
            cy.get("#period").should("not.be.disabled");
        }
    };

    it("should initialize flatpickr with correct future-date constraints", () => {
        setupModalForDateTesting();

        // Verify flatpickr is initialized with future-date attribute
        cy.get("#period").should(
            "have.attr",
            "data-flatpickr-futuredate",
            "true"
        );

        // Set up the flatpickr alias and open the calendar
        cy.get("#period").as("flatpickrInput");
        cy.get("@flatpickrInput").openFlatpickr();

        // Verify past dates are disabled
        const yesterday = dayjs().subtract(1, "day");

        // Test that yesterday is disabled (if it's visible in current month view)
        if (yesterday.month() === dayjs().month()) {
            cy.get("@flatpickrInput")
                .getFlatpickrDate(yesterday.toDate())
                .should("have.class", "flatpickr-disabled");
            cy.log(
                `Correctly found disabled past date: ${yesterday.format("YYYY-MM-DD")}`
            );
        }

        // Verify that future dates are not disabled
        const tomorrow = dayjs().add(1, "day");
        cy.get("@flatpickrInput")
            .getFlatpickrDate(tomorrow.toDate())
            .should("not.have.class", "flatpickr-disabled");
    });

    it("should disable dates with existing bookings for same item", () => {
        const today = dayjs().startOf("day");

        // Define multiple booking periods for the same item
        const existingBookings = [
            {
                name: "First booking period",
                start: today.add(8, "day"), // Days 8-13 (6 days)
                end: today.add(13, "day"),
            },
            {
                name: "Second booking period",
                start: today.add(18, "day"), // Days 18-22 (5 days)
                end: today.add(22, "day"),
            },
            {
                name: "Third booking period",
                start: today.add(28, "day"), // Days 28-30 (3 days)
                end: today.add(30, "day"),
            },
        ];

        // Create existing bookings in the database for the same item we'll test with
        const bookingInsertPromises = existingBookings.map(booking => {
            return cy.task("query", {
                sql: `INSERT INTO bookings (biblio_id, item_id, patron_id, start_date, end_date, pickup_library_id, status)
                      VALUES (?, ?, ?, ?, ?, ?, '1')`,
                values: [
                    testData.biblio.biblio_id,
                    testData.items[0].item_id, // Use first item
                    testData.patron.patron_id,
                    booking.start.format("YYYY-MM-DD HH:mm:ss"),
                    booking.end.format("YYYY-MM-DD HH:mm:ss"),
                    testData.libraries[0].library_id,
                ],
            });
        });

        // Wait for all bookings to be created
        cy.wrap(Promise.all(bookingInsertPromises));

        // Setup modal but skip auto-item selection so we can control which item to select
        setupModalForDateTesting({ skipItemSelection: true });

        // Select the specific item that has the existing bookings
        cy.get("#booking_item_id").should("not.be.disabled");
        cy.selectFromSelect2ByIndex("#booking_item_id", 1); // Select first actual item (not "Any item")
        cy.wait("@getCirculationRules");

        // Verify date picker is now enabled
        cy.get("#period").should("not.be.disabled");

        // Set up flatpickr alias and open the calendar
        cy.get("#period").as("flatpickrInput");
        cy.get("@flatpickrInput").openFlatpickr();

        cy.log(
            "=== PHASE 1: Testing dates before first booking period are available ==="
        );
        // Days 1-7: Should be available (before all bookings)
        const beforeAllBookings = [
            today.add(5, "day"), // Day 5
            today.add(6, "day"), // Day 6
            today.add(7, "day"), // Day 7
        ];

        beforeAllBookings.forEach(date => {
            if (
                date.isAfter(today) &&
                (date.month() === today.month() ||
                    date.month() === today.add(1, "month").month())
            ) {
                cy.get("@flatpickrInput")
                    .getFlatpickrDate(date.toDate())
                    .should("not.have.class", "flatpickr-disabled");
                cy.log(
                    `✓ Day ${date.format("YYYY-MM-DD")}: Available (before all bookings)`
                );
            }
        });

        cy.log("=== PHASE 2: Testing booked periods are disabled ===");
        // Days 8-13, 18-22, 28-30: Should be disabled (existing bookings)
        existingBookings.forEach((booking, index) => {
            cy.log(
                `Testing ${booking.name}: Days ${booking.start.format("YYYY-MM-DD")} to ${booking.end.format("YYYY-MM-DD")}`
            );

            // Test each day in the booking period
            for (
                let date = booking.start;
                date.isSameOrBefore(booking.end);
                date = date.add(1, "day")
            ) {
                if (
                    date.month() === today.month() ||
                    date.month() === today.add(1, "month").month()
                ) {
                    cy.get("@flatpickrInput")
                        .getFlatpickrDate(date.toDate())
                        .should("have.class", "flatpickr-disabled");
                    cy.log(
                        `✓ Day ${date.format("YYYY-MM-DD")}: DISABLED (existing booking)`
                    );
                }
            }
        });

        cy.log("=== PHASE 3: Testing available gaps between bookings ===");
        // Days 14-17 (gap 1) and 23-27 (gap 2): Should be available
        const betweenBookings = [
            {
                name: "Gap 1 (between Booking 1 & 2)",
                start: today.add(14, "day"),
                end: today.add(17, "day"),
            },
            {
                name: "Gap 2 (between Booking 2 & 3)",
                start: today.add(23, "day"),
                end: today.add(27, "day"),
            },
        ];

        betweenBookings.forEach(gap => {
            cy.log(
                `Testing ${gap.name}: Days ${gap.start.format("YYYY-MM-DD")} to ${gap.end.format("YYYY-MM-DD")}`
            );

            for (
                let date = gap.start;
                date.isSameOrBefore(gap.end);
                date = date.add(1, "day")
            ) {
                if (
                    date.month() === today.month() ||
                    date.month() === today.add(1, "month").month()
                ) {
                    cy.get("@flatpickrInput")
                        .getFlatpickrDate(date.toDate())
                        .should("not.have.class", "flatpickr-disabled");
                    cy.log(
                        `✓ Day ${date.format("YYYY-MM-DD")}: Available (gap between bookings)`
                    );
                }
            }
        });

        cy.log(
            "=== PHASE 4: Testing different item bookings don't conflict ==="
        );
        /*
         * DIFFERENT ITEM BOOKING TEST:
         * ============================
         * Day:  34 35 36 37 38 39 40 41 42
         * Our Item (Item 1):   O  O  O  O  O  O  O  O  O
         * Other Item (Item 2): -  X  X  X  X  X  X  -  -
         *                         ^^^^^^^^^^^^^^^^^
         *                         Different item booking
         *
         * Expected: Days 35-40 should be AVAILABLE for our item even though
         *          they're booked for a different item (Item 2)
         */

        // Create a booking for the OTHER item (different from the one we're testing)
        const differentItemBooking = {
            start: today.add(35, "day"),
            end: today.add(40, "day"),
        };

        cy.task("query", {
            sql: `INSERT INTO bookings (biblio_id, item_id, patron_id, start_date, end_date, pickup_library_id, status)
                  VALUES (?, ?, ?, ?, ?, ?, '1')`,
            values: [
                testData.biblio.biblio_id,
                testData.items[1].item_id, // Use SECOND item (different from our test item)
                testData.patron.patron_id,
                differentItemBooking.start.format("YYYY-MM-DD HH:mm:ss"),
                differentItemBooking.end.format("YYYY-MM-DD HH:mm:ss"),
                testData.libraries[0].library_id,
            ],
        });

        // Test dates that are booked for different item - should be available for our item
        cy.log(
            `Testing different item booking: Days ${differentItemBooking.start.format("YYYY-MM-DD")} to ${differentItemBooking.end.format("YYYY-MM-DD")}`
        );
        for (
            let date = differentItemBooking.start;
            date.isSameOrBefore(differentItemBooking.end);
            date = date.add(1, "day")
        ) {
            if (
                date.month() === today.month() ||
                date.month() === today.add(1, "month").month()
            ) {
                cy.get("@flatpickrInput")
                    .getFlatpickrDate(date.toDate())
                    .should("not.have.class", "flatpickr-disabled");
                cy.log(
                    `✓ Day ${date.format("YYYY-MM-DD")}: Available (booked for different item, not conflict)`
                );
            }
        }

        cy.log(
            "=== PHASE 5: Testing dates after last booking are available ==="
        );
        // Days 41+: Should be available (after all bookings)
        const afterAllBookings = today.add(41, "day");
        if (
            afterAllBookings.month() === today.month() ||
            afterAllBookings.month() === today.add(1, "month").month()
        ) {
            cy.get("@flatpickrInput")
                .getFlatpickrDate(afterAllBookings.toDate())
                .should("not.have.class", "flatpickr-disabled");
            cy.log(
                `✓ Day ${afterAllBookings.format("YYYY-MM-DD")}: Available (after all bookings)`
            );
        }

        cy.log("✓ CONFIRMED: Booking conflict detection working correctly");
    });

    it("should handle date range validation correctly", () => {
        setupModalForDateTesting();

        // Test valid date range
        const startDate = dayjs().add(2, "day");
        const endDate = dayjs().add(5, "day");

        cy.get("#period").selectFlatpickrDateRange(startDate, endDate);

        // Verify the dates were accepted (check that dates were set)
        cy.get("#booking_start_date").should("not.have.value", "");
        cy.get("#booking_end_date").should("not.have.value", "");

        // Try to submit - should succeed with valid dates
        cy.get("#placeBookingForm button[type='submit']")
            .should("not.be.disabled")
            .click();

        // Should either succeed (modal closes) or show specific validation error
        cy.get("body").then($body => {
            if ($body.find("#placeBookingModal:visible").length > 0) {
                // If modal is still visible, check for validation messages
                cy.log(
                    "Modal still visible - checking for validation feedback"
                );
            } else {
                cy.log("Modal closed - booking submission succeeded");
            }
        });
    });

    it("should handle circulation rules date calculations and visual feedback", () => {
        /**
         * Circulation Rules Behavior Tests
         * ================================
         *
         * Validate that our flatpickr correctly calculates and visualizes
         * booking periods based on circulation rules, including maximum date
         * limits and visual styling for different date periods.
         *
         * Test Coverage:
         * 1. Maximum date calculation and enforcement [issue period + (renewal period * max renewals)]
         * 2. Bold date styling for issue length and renewal lengths
         * 3. Date selection limits based on circulation rules
         * 4. Visual feedback for different booking period phases
         *
         * CIRCULATION RULES DATE CALCULATION:
         * ==================================
         *
         * Test Circulation Rules:
         * - Issue Length: 10 days (primary booking period)
         * - Renewals Allowed: 3 renewals
         * - Renewal Period: 5 days each
         * - Total Maximum Period: 10 + (3 × 5) = 25 days
         *
         * Clear Zone Date Layout (Starting Day 50):
         * ==========================================
         * Day:    48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76
         * Period: O  O  S  I  I  I  I  I  I  I  I  I  R1 R1 R1 R1 R1 R2 R2 R2 R2 R2 R3 R3 R3 R3 R3 E  O
         *            ↑  ↑                             ↑              ↑              ↑              ↑  ↑
         *            │  │                             │              │              │              │  │
         *            │  └─ Start Date (Day 50)        │              │              │              │  └─ Available (after max)
         *            └─ Available (before start)      │              │              │              └─ Max Date (Day 75)
         *                                             │              │              └─ Renewal 3 Period (Days 70-74)
         *                                             │              └─ Renewal 2 Period (Days 65-69)
         *                                             └─ Renewal 1 Period (Days 60-64)
         *
         * Expected Visual Styling:
         * - Day 50: Bold (start date)
         * - Day 59: Bold (issue period)
         * - Day 64: Bold (renewal 1 period)
         * - Day 69: Bold (renewal 2 period)
         * - Day 75: Bold (renewal 3 period, Max selectable date)
         * - Day 76+: Not selectable (beyond max date)
         *
         * Legend: S = Start, I = Issue, R1/R2/R3 = Renewal periods, E = End, O = Available
         */

        const today = dayjs().startOf("day");

        // Set up specific circulation rules for date calculation testing
        const dateTestCirculationRules = {
            bookings_lead_period: 0, // Tested elsewhere
            bookings_trail_period: 0, // Tested elsewhere
            issuelength: 10, // 10-day issue period
            renewalsallowed: 3, // 3 renewals allowed
            renewalperiod: 5, // 5 days per renewal
        };

        // Override circulation rules API call
        cy.intercept("GET", "/api/v1/circulation_rules*", {
            body: [dateTestCirculationRules],
        }).as("getDateTestRules");

        setupModalForDateTesting({ skipItemSelection: true });

        // Select item to get circulation rules
        cy.get("#booking_item_id").should("not.be.disabled");
        cy.selectFromSelect2ByIndex("#booking_item_id", 1);
        cy.wait("@getDateTestRules");

        cy.get("#period").should("not.be.disabled");
        cy.get("#period").as("dateTestFlatpickr");
        cy.get("@dateTestFlatpickr").openFlatpickr();

        // ========================================================================
        // TEST 1: Maximum Date Calculation and Enforcement
        // ========================================================================
        cy.log(
            "=== TEST 1: Testing maximum date calculation and enforcement ==="
        );

        /*
         * Maximum Date Calculation Test:
         * - Max period = issue (10) + renewals (3 × 5) = 25 days total
         * - If start date is Day 50, max end date should be Day 75 (50 + 25)
         * - Dates beyond Day 75 should not be selectable
         */

        // Test in clear zone starting at Day 50 to avoid conflicts
        const clearZoneStart = today.add(50, "day");
        const calculatedMaxDate = clearZoneStart.add(
            dateTestCirculationRules.issuelength +
                dateTestCirculationRules.renewalsallowed *
                    dateTestCirculationRules.renewalperiod,
            "day"
        ); // Day 50 + 25 = Day 75

        const beyondMaxDate = calculatedMaxDate.add(1, "day"); // Day 76

        cy.log(
            `Clear zone start: ${clearZoneStart.format("YYYY-MM-DD")} (Day 50)`
        );
        cy.log(
            `Calculated max date: ${calculatedMaxDate.format("YYYY-MM-DD")} (Day 75)`
        );
        cy.log(
            `Beyond max date: ${beyondMaxDate.format("YYYY-MM-DD")} (Day 76 - should be disabled)`
        );

        // Select the start date to establish context for bold date calculation
        cy.get("@dateTestFlatpickr").selectFlatpickrDate(
            clearZoneStart.toDate()
        );

        // Verify max date is selectable
        cy.get("@dateTestFlatpickr")
            .getFlatpickrDate(calculatedMaxDate.toDate())
            .should("not.have.class", "flatpickr-disabled")
            .and("be.visible");

        // Verify beyond max date is disabled (if in visible month range)
        if (
            beyondMaxDate.month() === clearZoneStart.month() ||
            beyondMaxDate.month() === clearZoneStart.add(1, "month").month()
        ) {
            cy.get("@dateTestFlatpickr")
                .getFlatpickrDate(beyondMaxDate.toDate())
                .should("have.class", "flatpickr-disabled");
        }

        cy.log("✓ Maximum date calculation enforced correctly");

        // ========================================================================
        // TEST 2: Bold Date Styling for Issue and Renewal Periods
        // ========================================================================
        cy.log(
            "=== TEST 2: Testing bold date styling for issue and renewal periods ==="
        );

        /*
         * Bold Date Styling Test:
         * Bold dates appear at circulation period endpoints to indicate
         * when issue/renewal periods end. We test the "title" class
         * applied to these specific dates.
         */

        // Calculate expected bold dates based on circulation rules (like original test)
        // Bold dates occur at: the start date itself, plus period endpoints
        const expectedBoldDates = [];

        // Start date is always bold (see place_booking.js boldDates = [new Date(startDate)])
        expectedBoldDates.push(clearZoneStart);

        // Issue period end (after issuelength days)
        expectedBoldDates.push(
            clearZoneStart.add(dateTestCirculationRules.issuelength, "day")
        );

        // Each renewal period end
        for (let i = 1; i <= dateTestCirculationRules.renewalsallowed; i++) {
            const renewalEndDate = clearZoneStart.add(
                dateTestCirculationRules.issuelength +
                    i * dateTestCirculationRules.renewalperiod,
                "day"
            );
            expectedBoldDates.push(renewalEndDate);
        }

        cy.log(
            `Expected bold dates: ${expectedBoldDates.map(d => d.format("YYYY-MM-DD")).join(", ")}`
        );

        // Test each expected bold date has the "title" class (like original test)
        expectedBoldDates.forEach(boldDate => {
            if (
                boldDate.month() === clearZoneStart.month() ||
                boldDate.month() === clearZoneStart.add(1, "month").month()
            ) {
                cy.get("@dateTestFlatpickr")
                    .getFlatpickrDate(boldDate.toDate())
                    .should("have.class", "title");
                cy.log(
                    `✓ Day ${boldDate.format("YYYY-MM-DD")}: Has 'title' class (bold)`
                );
            }
        });

        // Verify that only expected dates are bold (have "title" class)
        cy.get(".flatpickr-day.title").each($el => {
            const ariaLabel = $el.attr("aria-label");
            const date = dayjs(ariaLabel, "MMMM D, YYYY");
            const isExpected = expectedBoldDates.some(expected =>
                date.isSame(expected, "day")
            );
            expect(isExpected, `Unexpected bold date: ${ariaLabel}`).to.be.true;
        });

        cy.log(
            "✓ Bold date styling correctly applied to circulation rule period endpoints"
        );

        // ========================================================================
        // TEST 3: Date Range Selection Within Limits
        // ========================================================================
        cy.log(
            "=== TEST 3: Testing date range selection within circulation limits ==="
        );

        /*
         * Range Selection Test:
         * - Should be able to select valid range within max period
         * - Should accept full maximum range (25 days)
         * - Should populate start/end date fields correctly
         */

        // Clear the flatpickr selection from previous tests
        cy.get("#period").clearFlatpickr();

        // Test selecting a mid-range period (issue + 1 renewal = 15 days)
        const midRangeEnd = clearZoneStart.add(15, "day");

        cy.get("#period").selectFlatpickrDateRange(clearZoneStart, midRangeEnd);

        // Verify dates were accepted
        cy.get("#booking_start_date").should("not.have.value", "");
        cy.get("#booking_end_date").should("not.have.value", "");

        cy.log(
            `✓ Mid-range selection accepted: ${clearZoneStart.format("YYYY-MM-DD")} to ${midRangeEnd.format("YYYY-MM-DD")}`
        );

        // Test selecting full maximum range
        cy.get("#period").selectFlatpickrDateRange(
            clearZoneStart,
            calculatedMaxDate
        );

        // Verify full range was accepted
        cy.get("#booking_start_date").should("not.have.value", "");
        cy.get("#booking_end_date").should("not.have.value", "");

        cy.log(
            `✓ Full maximum range accepted: ${clearZoneStart.format("YYYY-MM-DD")} to ${calculatedMaxDate.format("YYYY-MM-DD")}`
        );

        cy.log(
            "✓ CONFIRMED: Circulation rules date calculations and visual feedback working correctly"
        );
        cy.log(
            `✓ Validated: ${dateTestCirculationRules.issuelength}-day issue + ${dateTestCirculationRules.renewalsallowed} renewals × ${dateTestCirculationRules.renewalperiod} days = ${dateTestCirculationRules.issuelength + dateTestCirculationRules.renewalsallowed * dateTestCirculationRules.renewalperiod}-day maximum period`
        );
    });

    it("should handle lead and trail periods", () => {
        /**
         * Lead and Trail Period Behaviour Tests (with Bidirectional Enhancement)
         * ======================================================================
         *
         * Test Coverage:
         * 1. Lead period visual hints (CSS classes) in clear zone
         * 2. Trail period visual hints (CSS classes) in clear zone
         * 3a. Lead period conflicts with past dates (leadDisable)
         * 3b. Lead period conflicts with existing booking ACTUAL dates (leadDisable)
         * 3c. NEW BIDIRECTIONAL: Lead period conflicts with existing booking TRAIL period (leadDisable)
         * 4a. Trail period conflicts with existing booking ACTUAL dates (trailDisable)
         * 4b. NEW BIDIRECTIONAL: Trail period conflicts with existing booking LEAD period (trailDisable)
         * 5. Max date selectable when trail period is clear of existing booking
         *
         * CRITICAL ENHANCEMENT: Bidirectional Lead/Trail Period Checking
         * ==============================================================
         * This test validates that lead/trail periods work in BOTH directions:
         * - New booking's LEAD period must not conflict with existing booking's TRAIL period
         * - New booking's TRAIL period must not conflict with existing booking's LEAD period
         * - This ensures full "protected periods" around existing bookings are respected
         *
         * PROTECTED PERIOD CONCEPT:
         * ========================
         * Each existing booking has a "protected period" = Lead + Actual + Trail
         * New bookings must ensure their Lead + Actual + Trail does not overlap
         * with ANY part of existing bookings' protected periods.
         *
         * Fixed Date Setup:
         * ================
         * - Today: June 10, 2026 (Wednesday)
         * - Timezone: Europe/London
         * - Lead Period: 2 days
         * - Trail Period: 3 days
         * - Issue Length: 3 days
         * - Renewal Period: 2 days
         * - Max Renewals: 2
         * - Max Booking Period: 3 + (2 × 2) = 7 days
         *
         * Blocker Booking: June 25-27, 2026
         * - Blocker's LEAD period: June 23-24 (2 days before start)
         * - Blocker's ACTUAL dates: June 25-27
         * - Blocker's TRAIL period: June 28-30 (3 days after end)
         * - Total PROTECTED period: June 23-30
         *
         * Timeline:
         * =========
         * June/July 2026
         * Sun Mon Tue Wed Thu Fri Sat
         *      8   9  10  11  12  13   ← 10 = TODAY
         *  14  15  16  17  18  19  20
         *  21  22  23  24  25  26  27   ← 23-24 = BLOCKER LEAD, 25-27 = BLOCKER ACTUAL
         *  28  29  30   1   2   3   4   ← 28-30 = BLOCKER TRAIL, July 3 = first clear after
         *
         * Test Scenarios:
         * ==============
         * Phase 1: Hover June 13 → Lead June 11-12 (clear) → no leadDisable
         * Phase 2: Select June 13, hover June 16 → Trail June 17-19 (clear) → no trailDisable
         * Phase 3a: Hover June 11 → Lead June 9-10, June 9 is past → leadDisable
         * Phase 3b: Hover June 29 → Lead June 27-28, June 27 is in blocker ACTUAL → leadDisable
         * Phase 3c: NEW - Hover July 1 → Lead June 29-30, overlaps blocker TRAIL → leadDisable
         * Phase 3d: NEW - Hover July 2 → Lead June 30-July 1, June 30 in blocker TRAIL → leadDisable
         * Phase 4a: Select June 20, hover June 23 → Trail June 24-26 overlaps blocker ACTUAL → trailDisable
         * Phase 4b: NEW - Select June 13, hover June 21 → Trail June 22-24, overlaps blocker LEAD → trailDisable
         * Phase 5: Select June 13, hover June 20 (max) → Trail June 21-23 (clear) → selectable
         */

        // Anchor "today" to next month so bookings stay in the future ( the API drops past ones )
        // ["Date"] avoids freezing timers, which breaks Select2
        const fixedToday = dayjs()
            .add(1, "month")
            .startOf("month")
            .hour(8)
            .toDate();
        cy.clock(fixedToday, ["Date"]);
        const today = dayjs(fixedToday);

        // Circulation rules with short periods for focused testing
        const circulationRules = {
            bookings_lead_period: 2,
            bookings_trail_period: 3,
            issuelength: 3,
            renewalsallowed: 2,
            renewalperiod: 2,
        };

        const maxBookingPeriod =
            circulationRules.issuelength +
            circulationRules.renewalsallowed * circulationRules.renewalperiod; // 7 days
        cy.log(`Max booking period: ${maxBookingPeriod} days`);

        cy.intercept("GET", "/api/v1/circulation_rules*", {
            body: [circulationRules],
        }).as("getFixedDateRules");

        // Create blocker booking 15-17 days out
        const blockerStart = today.add(15, "day").format("YYYY-MM-DD 00:00:00");
        const blockerEnd = today.add(17, "day").format("YYYY-MM-DD 23:59:59");

        cy.task("query", {
            sql: `INSERT INTO bookings (biblio_id, item_id, patron_id, start_date, end_date, pickup_library_id, status)
                  VALUES (?, ?, ?, ?, ?, ?, '1')`,
            values: [
                testData.biblio.biblio_id,
                testData.items[0].item_id,
                testData.patron.patron_id,
                blockerStart,
                blockerEnd,
                testData.libraries[0].library_id,
            ],
        });

        // Setup modal
        setupModalForDateTesting({ skipItemSelection: true });

        cy.get("#booking_item_id").should("not.be.disabled");
        cy.selectFromSelect2ByIndex("#booking_item_id", 1);
        cy.wait("@getFixedDateRules");

        cy.get("#period").should("not.be.disabled");
        cy.get("#period").as("fp");
        cy.get("@fp").openFlatpickr();

        // Helper to get a flatpickr day cell N days from "today".
        const getDate = (daysFromToday: number) =>
            cy
                .get("@fp")
                .getFlatpickrDate(today.add(daysFromToday, "day").toDate());

        // ========================================================================
        // PHASE 1: Lead Period Clear - Visual Classes
        // ========================================================================
        cy.log("=== PHASE 1: Lead period visual hints in clear zone ===");

        /**
         * Hover June 13 as potential start date
         * Lead period: June 11-12 (both after today June 10, no booking conflict)
         * Expected: leadRangeStart on June 11, leadRange on June 12, no leadDisable on June 13
         */

        getDate(3).trigger("mouseover");

        // Check lead period classes
        getDate(1)
            .should("have.class", "leadRangeStart")
            .and("have.class", "leadRange");

        getDate(2)
            .should("have.class", "leadRange")
            .and("have.class", "leadRangeEnd");

        // Hovered date should NOT have leadDisable (lead period is clear)
        getDate(3).should("not.have.class", "leadDisable");

        // ========================================================================
        // PHASE 2: Trail Period Clear - Visual Classes
        // ========================================================================
        cy.log("=== PHASE 2: Trail period visual hints in clear zone ===");

        /**
         * Select June 13 as start date (lead June 11-12 is clear)
         * Then hover June 16 as potential end date
         * Trail period calculation: trailStart = hoverDate + 1, trailEnd = hoverDate + 3
         * So: trailStart = June 17, trailEnd = June 19
         * Classes: June 17 = trailRangeStart + trailRange, June 18 = trailRange, June 19 = trailRange + trailRangeEnd
         */

        // Select June 13 as start date (same date we just hovered - lead is clear)
        getDate(3).click();

        // Hover June 16 as potential end date
        getDate(6).trigger("mouseover");

        // Check trail period classes
        getDate(7)
            .should("have.class", "trailRangeStart")
            .and("have.class", "trailRange");

        getDate(8).should("have.class", "trailRange");

        getDate(9)
            .should("have.class", "trailRangeEnd")
            .and("have.class", "trailRange");

        // Hovered date (June 16) should NOT have trailDisable (trail period is clear)
        getDate(6).should("not.have.class", "trailDisable");

        // Clear selection for next phase
        cy.get("#period").clearFlatpickr();
        cy.get("@fp").openFlatpickr();

        // ========================================================================
        // PHASE 3: Lead Period Conflict - Past Dates and Existing bookings
        // ========================================================================
        cy.log("=== PHASE 3: Lead period conflicts ===");

        /**
         * Hover June 11 as potential start date
         * Lead period: June 9-10
         * June 9 is in the past (before today June 10)
         * Expected: leadDisable on June 11 because lead period extends into past
         */

        getDate(1).trigger("mouseover");

        // June 11 should have leadDisable because lead period (June 9-10) includes past date
        getDate(1).should("have.class", "leadDisable");

        /**
         * Hover June 29 as potential start date
         * Lead period: June 27-28
         * June 27 is in the existing booking (25-27 June)
         * Expected: leadDisable on June 29 because lead period extends into existing booking
         */

        getDate(19).trigger("mouseover");

        // June 29 should have leadDisable because lead period (June 27-28) includes existing booking date
        getDate(19).should("have.class", "leadDisable");

        // ========================================================================
        // PHASE 3c: BIDIRECTIONAL - Lead Period Conflicts with Existing Booking TRAIL
        // ========================================================================

        /**
         * NEW BIDIRECTIONAL Conflict Scenario:
         * Blocker booking end: June 27
         * Blocker's TRAIL period: June 28-30 (3 days after end)
         *
         * Test start dates where NEW booking's lead overlaps with blocker's TRAIL:
         * - July 1: Lead June 29-30 → June 29-30 are in blocker trail (June 28-30) → DISABLED
         * - July 2: Lead June 30-July 1 → June 30 is in blocker trail → DISABLED
         *
         * This is the KEY enhancement: respecting existing booking's trail period!
         */

        // Hover July 1 - lead period (June 29-30) overlaps blocker's trail (June 28-30)
        getDate(21).trigger("mouseover");
        getDate(21).should("have.class", "leadDisable");

        // Hover July 2 - lead period (June 30-July 1) still overlaps blocker's trail at June 30
        getDate(22).trigger("mouseover");
        getDate(22).should("have.class", "leadDisable");

        // ========================================================================
        // PHASE 3d: First Clear Start Date After Blocker's Protected Period
        // ========================================================================

        /**
         * Verify that July 3 is the first selectable start date after blocker:
         * - July 3: Lead July 1-2 → completely clear of blocker trail (ends June 30) → no leadDisable
         */

        getDate(23).trigger("mouseover");
        getDate(23).should("not.have.class", "leadDisable");

        // ========================================================================
        // PHASE 4a: Trail Period Conflict - Existing Booking ACTUAL Dates
        // ========================================================================

        /**
         * Select June 20 as start date (lead June 18-19, both clear)
         * Then hover June 23 as potential end date
         * Trail period: June 24-26
         * Blocker booking ACTUAL: June 25-27 (partial overlap)
         * Expected: trailDisable on June 23
         */

        // Select June 20 as start date
        getDate(10).click();

        // Hover June 23 as potential end date
        getDate(13).trigger("mouseover");

        // June 23 should have trailDisable because trail period (June 24-26) overlaps blocker ACTUAL (June 25-27)
        getDate(13).should("have.class", "trailDisable");

        // Clear selection for next phase
        cy.get("#period").clearFlatpickr();
        cy.get("@fp").openFlatpickr();

        // ========================================================================
        // PHASE 4b: BIDIRECTIONAL - Trail Period Conflicts with Existing Booking LEAD
        // ========================================================================

        /**
         * NEW BIDIRECTIONAL Conflict Scenario:
         * Blocker booking start: June 25
         * Blocker's LEAD period: June 23-24 (2 days before start)
         *
         * Test end dates where NEW booking's trail overlaps with blocker's LEAD:
         * - Select June 13 as start, hover June 21 as end
         * - Trail period: June 22-24 (3 days after June 21)
         * - June 23-24 overlap with blocker LEAD (June 23-24) → DISABLED
         *
         * This is the KEY enhancement: respecting existing booking's lead period!
         */

        // Select June 13 as start date (lead June 11-12, both clear)
        getDate(3).click();

        // Hover June 21 as potential end date
        // Trail period: June 22-24, Blocker LEAD: June 23-24
        // Overlap at June 23-24 → should have trailDisable
        getDate(11).trigger("mouseover");
        getDate(11).should("have.class", "trailDisable");

        // Also test June 20 - trail June 21-23, June 23 overlaps blocker lead
        getDate(10).trigger("mouseover");
        getDate(10).should("have.class", "trailDisable");

        // Verify June 19 is clear - trail June 20-22, doesn't reach blocker lead (starts June 23)
        getDate(9).trigger("mouseover");
        getDate(9).should("not.have.class", "trailDisable");

        // Clear selection for next phase
        cy.get("#period").clearFlatpickr();
        cy.get("@fp").openFlatpickr();

        // ========================================================================
        // PHASE 5: Max Date Selectable When Trail is Clear
        // ========================================================================

        /**
         * Select June 13 as start date (lead June 11-12, both clear)
         * Max end date by circulation rules: June 20 (13 + 7 days)
         * But June 20's trail period (June 21-23) overlaps blocker's lead (June 23-24) at June 23
         * So June 20 WILL have trailDisable
         *
         * June 19's trail period (June 20-22) is clear of blocker's lead (June 23-24)
         * So June 19 should be selectable (no trailDisable)
         */

        // Select June 13 as start date
        getDate(3).click();

        // First, verify June 20 HAS trailDisable (trail June 21-23 overlaps blocker lead June 23-24)
        getDate(10).trigger("mouseover");
        getDate(10).should("have.class", "trailDisable");

        // June 19 should NOT have trailDisable (trail June 20-22 is clear of blocker lead)
        getDate(9).trigger("mouseover");
        getDate(9).should("not.have.class", "trailDisable");

        // June 19 should not be disabled by flatpickr
        getDate(9).should("not.have.class", "flatpickr-disabled");

        // Actually select June 19 to confirm booking can be made
        getDate(9).click();

        // Verify dates were accepted in the form
        cy.get("#booking_start_date").should("not.have.value", "");
        cy.get("#booking_end_date").should("not.have.value", "");

        cy.log(
            "✓ CONFIRMED: Lead/trail period behavior with bidirectional conflict detection working correctly"
        );
    });

    it("should show event dots for dates with existing bookings", () => {
        /**
         * Comprehensive Event Dots Visual Indicator Test
         * ==============================================
         *
         * This test validates the visual booking indicators (event dots) displayed on calendar dates
         * to show users which dates already have existing bookings.
         *
         * Test Coverage:
         * 1. Single booking event dots (one dot per date)
         * 2. Multiple bookings on same date (multiple dots)
         * 3. Dates without bookings (no dots)
         * 4. Item-specific dot styling with correct CSS classes
         * 5. Event dot container structure and attributes
         *
         * EVENT DOTS FUNCTIONALITY:
         * =========================
         *
         * Algorithm Overview:
         * 1. Bookings array is processed into bookingsByDate hash (date -> [item_ids])
         * 2. onDayCreate hook checks bookingsByDate[dateString] for each calendar day
         * 3. If bookings exist, creates .event-dots container with .event.item_{id} children
         * 4. Sets data attributes for booking metadata and item-specific information
         *
         * Visual Structure:
         * <span class="flatpickr-day">
         *   <div class="event-dots">
         *     <div class="event item_301" data-item-id="301"></div>
         *     <div class="event item_302" data-item-id="302"></div>
         *   </div>
         * </span>
         *
         * Event Dot Test Layout:
         * ======================
         * Day:     5  6  7  8  9 10 11 12 13 14 15 16 17
         * Booking: MM O  O  O  O  S  S  S  O  O  T  O  O
         * Dots:    •• -  -  -  -  •  •  •  -  -  •  -  -
         *
         * Legend: MM = Multiple bookings (items 301+302), S = Single booking (item 303),
         *         T = Test booking (item 301), O = Available, - = No dots, • = Event dot
         */

        const today = dayjs().startOf("day");

        // Set up circulation rules for event dots testing
        const eventDotsCirculationRules = {
            bookings_lead_period: 1, // Minimal to avoid conflicts
            bookings_trail_period: 1,
            issuelength: 7,
            renewalsallowed: 1,
            renewalperiod: 3,
        };

        cy.intercept("GET", "/api/v1/circulation_rules*", {
            body: [eventDotsCirculationRules],
        }).as("getEventDotsRules");

        // Create strategic bookings for event dots testing
        const testBookings = [
            // Multiple bookings on same dates (Days 5-6): Items 301 + 302
            {
                item_id: testData.items[0].item_id, // Will be item 301 equivalent
                start: today.add(5, "day"),
                end: today.add(6, "day"),
                name: "Multi-booking 1",
            },
            {
                item_id: testData.items[1].item_id, // Will be item 302 equivalent
                start: today.add(5, "day"),
                end: today.add(6, "day"),
                name: "Multi-booking 2",
            },
            // Single booking spanning multiple days (Days 10-12): Item 303
            {
                item_id: testData.items[0].item_id, // Reuse first item
                start: today.add(10, "day"),
                end: today.add(12, "day"),
                name: "Single span booking",
            },
            // Isolated single booking (Day 15): Item 301
            {
                item_id: testData.items[0].item_id,
                start: today.add(15, "day"),
                end: today.add(15, "day"),
                name: "Isolated booking",
            },
        ];

        // Create all test bookings in database
        testBookings.forEach((booking, index) => {
            cy.task("query", {
                sql: `INSERT INTO bookings (biblio_id, item_id, patron_id, start_date, end_date, pickup_library_id, status)
                      VALUES (?, ?, ?, ?, ?, ?, '1')`,
                values: [
                    testData.biblio.biblio_id,
                    booking.item_id,
                    testData.patron.patron_id,
                    booking.start.format("YYYY-MM-DD HH:mm:ss"),
                    booking.end.format("YYYY-MM-DD HH:mm:ss"),
                    testData.libraries[0].library_id,
                ],
            });
        });

        setupModalForDateTesting({ skipItemSelection: true });

        // Select item to trigger event dots loading
        cy.get("#booking_item_id").should("not.be.disabled");
        cy.selectFromSelect2ByIndex("#booking_item_id", 1); // Select first actual item
        cy.wait("@getEventDotsRules");

        cy.get("#period").should("not.be.disabled");
        cy.get("#period").as("eventDotsFlatpickr");
        cy.get("@eventDotsFlatpickr").openFlatpickr();

        // ========================================================================
        // TEST 1: Single Booking Event Dots (Days 10, 11, 12)
        // ========================================================================

        // Days 10-12 have single booking from same item - should create one event dot each
        const singleDotDates = [
            today.add(10, "day"),
            today.add(11, "day"),
            today.add(12, "day"),
        ];

        singleDotDates.forEach(date => {
            if (
                date.month() === today.month() ||
                date.month() === today.add(1, "month").month()
            ) {
                cy.get("@eventDotsFlatpickr")
                    .getFlatpickrDate(date.toDate())
                    .within(() => {
                        cy.get(".event-dots")
                            .should("exist")
                            .and("have.length", 1);
                        cy.get(".event-dots .event")
                            .should("exist")
                            .and("have.length", 1);
                    });
            }
        });

        // ========================================================================
        // TEST 2: Multiple Bookings on Same Date (Days 5-6)
        // ========================================================================

        // Days 5-6 have TWO different bookings (different items) - should create two dots
        const multipleDotDates = [today.add(5, "day"), today.add(6, "day")];

        multipleDotDates.forEach(date => {
            if (
                date.month() === today.month() ||
                date.month() === today.add(1, "month").month()
            ) {
                cy.get("@eventDotsFlatpickr")
                    .getFlatpickrDate(date.toDate())
                    .within(() => {
                        cy.get(".event-dots").should("exist");
                        cy.get(".event-dots .event").should("have.length", 2);
                    });
            }
        });

        // ========================================================================
        // TEST 3: Dates Without Bookings (No Event Dots)
        // ========================================================================

        // Dates without bookings should have no .event-dots container
        const emptyDates = [
            today.add(3, "day"), // Before any bookings
            today.add(8, "day"), // Between booking periods
            today.add(14, "day"), // Day before isolated booking
            today.add(17, "day"), // After all bookings
        ];

        emptyDates.forEach(date => {
            if (
                date.month() === today.month() ||
                date.month() === today.add(1, "month").month()
            ) {
                cy.get("@eventDotsFlatpickr")
                    .getFlatpickrDate(date.toDate())
                    .within(() => {
                        cy.get(".event-dots").should("not.exist");
                    });
            }
        });

        // ========================================================================
        // TEST 4: Isolated Single Booking (Day 15) - Boundary Detection
        // ========================================================================

        // Day 15 has booking (should have dot), adjacent days 14 and 16 don't (no dots)
        const isolatedBookingDate = today.add(15, "day");

        if (
            isolatedBookingDate.month() === today.month() ||
            isolatedBookingDate.month() === today.add(1, "month").month()
        ) {
            // Verify isolated booking day HAS dot
            cy.get("@eventDotsFlatpickr")
                .getFlatpickrDate(isolatedBookingDate.toDate())
                .within(() => {
                    cy.get(".event-dots").should("exist");
                    cy.get(".event-dots .event")
                        .should("exist")
                        .and("have.length", 1);
                });

            // Verify adjacent dates DON'T have dots
            [today.add(14, "day"), today.add(16, "day")].forEach(
                adjacentDate => {
                    if (
                        adjacentDate.month() === today.month() ||
                        adjacentDate.month() === today.add(1, "month").month()
                    ) {
                        cy.get("@eventDotsFlatpickr")
                            .getFlatpickrDate(adjacentDate.toDate())
                            .within(() => {
                                cy.get(".event-dots").should("not.exist");
                            });
                    }
                }
            );
        }

        cy.log(
            "✓ CONFIRMED: Event dots display correctly (single, multiple, empty dates, boundaries)"
        );
    });

    it("should maximize booking window by dynamically reducing available items during overlaps", () => {
        /**
         * Tests the "smart window maximization" algorithm for "any item" bookings.
         *
         * Key principle: Once an item is removed from the pool (becomes unavailable),
         * it is NEVER re-added even if it becomes available again later.
         *
         * Booking pattern:
         * - ITEM 0: Booked days 10-15
         * - ITEM 1: Booked days 13-20
         * - ITEM 2: Booked days 18-25
         * - ITEM 3: Booked days 1-7, then 23-30
         */

        // Anchor "today" to next month so bookings stay in the future ( the API drops past ones )
        // ["Date"] avoids freezing timers, which breaks Select2
        const fixedToday = dayjs()
            .add(1, "month")
            .startOf("month")
            .hour(8)
            .toDate();
        cy.clock(fixedToday, ["Date"]);
        const today = dayjs(fixedToday);

        let testItems = [];
        let testBiblio = null;
        let testPatron = null;

        // Circulation rules with zero lead/trail periods for simpler date testing
        const circulationRules = {
            bookings_lead_period: 0,
            bookings_trail_period: 0,
            issuelength: 14,
            renewalsallowed: 2,
            renewalperiod: 7,
        };

        // Setup: Create biblio with 4 items
        cy.task("insertSampleBiblio", { item_count: 4 })
            .then(objects => {
                testBiblio = objects.biblio;
                testItems = objects.items;

                const itemUpdates = testItems.map((item, index) => {
                    const enumchron = String.fromCharCode(65 + index);
                    return cy.task("query", {
                        sql: "UPDATE items SET bookable = 1, itype = 'BK', homebranch = 'CPL', enumchron = ?, dateaccessioned = ? WHERE itemnumber = ?",
                        values: [
                            enumchron,
                            `2024-12-0${4 - index}`,
                            item.item_id,
                        ],
                    });
                });
                return Promise.all(itemUpdates);
            })
            .then(() => {
                return cy.task("buildSampleObject", {
                    object: "patron",
                    values: {
                        firstname: "John",
                        surname: "Doe",
                        cardnumber: `TEST${Date.now()}`,
                        category_id: "PT",
                        library_id: "CPL",
                    },
                });
            })
            .then(mockPatron => {
                testPatron = mockPatron;
                return cy.task("query", {
                    sql: `INSERT INTO borrowers (borrowernumber, firstname, surname, cardnumber, categorycode, branchcode, dateofbirth)
                          VALUES (?, ?, ?, ?, ?, ?, ?)`,
                    values: [
                        mockPatron.patron_id,
                        mockPatron.firstname,
                        mockPatron.surname,
                        mockPatron.cardnumber,
                        mockPatron.category_id,
                        mockPatron.library_id,
                        "1990-01-01",
                    ],
                });
            })
            .then(() => {
                // Create strategic bookings
                const bookingInserts = [
                    // ITEM 0: Booked 10-15
                    cy.task("query", {
                        sql: `INSERT INTO bookings (biblio_id, patron_id, item_id, pickup_library_id, start_date, end_date, status)
                              VALUES (?, ?, ?, ?, ?, ?, ?)`,
                        values: [
                            testBiblio.biblio_id,
                            testPatron.patron_id,
                            testItems[0].item_id,
                            "CPL",
                            today.add(10, "day").format("YYYY-MM-DD"),
                            today.add(15, "day").format("YYYY-MM-DD"),
                            "new",
                        ],
                    }),
                    // ITEM 1: Booked 13-20
                    cy.task("query", {
                        sql: `INSERT INTO bookings (biblio_id, patron_id, item_id, pickup_library_id, start_date, end_date, status)
                              VALUES (?, ?, ?, ?, ?, ?, ?)`,
                        values: [
                            testBiblio.biblio_id,
                            testPatron.patron_id,
                            testItems[1].item_id,
                            "CPL",
                            today.add(13, "day").format("YYYY-MM-DD"),
                            today.add(20, "day").format("YYYY-MM-DD"),
                            "new",
                        ],
                    }),
                    // ITEM 2: Booked 18-25
                    cy.task("query", {
                        sql: `INSERT INTO bookings (biblio_id, patron_id, item_id, pickup_library_id, start_date, end_date, status)
                              VALUES (?, ?, ?, ?, ?, ?, ?)`,
                        values: [
                            testBiblio.biblio_id,
                            testPatron.patron_id,
                            testItems[2].item_id,
                            "CPL",
                            today.add(18, "day").format("YYYY-MM-DD"),
                            today.add(25, "day").format("YYYY-MM-DD"),
                            "new",
                        ],
                    }),
                    // ITEM 3: Booked 1-7
                    cy.task("query", {
                        sql: `INSERT INTO bookings (biblio_id, patron_id, item_id, pickup_library_id, start_date, end_date, status)
                              VALUES (?, ?, ?, ?, ?, ?, ?)`,
                        values: [
                            testBiblio.biblio_id,
                            testPatron.patron_id,
                            testItems[3].item_id,
                            "CPL",
                            today.add(1, "day").format("YYYY-MM-DD"),
                            today.add(7, "day").format("YYYY-MM-DD"),
                            "new",
                        ],
                    }),
                    // ITEM 3: Booked 23-30
                    cy.task("query", {
                        sql: `INSERT INTO bookings (biblio_id, patron_id, item_id, pickup_library_id, start_date, end_date, status)
                              VALUES (?, ?, ?, ?, ?, ?, ?)`,
                        values: [
                            testBiblio.biblio_id,
                            testPatron.patron_id,
                            testItems[3].item_id,
                            "CPL",
                            today.add(23, "day").format("YYYY-MM-DD"),
                            today.add(30, "day").format("YYYY-MM-DD"),
                            "new",
                        ],
                    }),
                ];
                return Promise.all(bookingInserts);
            })
            .then(() => {
                cy.intercept(
                    "GET",
                    `/api/v1/biblios/${testBiblio.biblio_id}/pickup_locations*`
                ).as("getPickupLocations");
                cy.intercept("GET", "/api/v1/circulation_rules*", {
                    body: [circulationRules],
                }).as("getCirculationRules");

                cy.visit(
                    `/cgi-bin/koha/catalogue/detail.pl?biblionumber=${testBiblio.biblio_id}`
                );

                cy.get('[data-bs-target="#placeBookingModal"]').first().click();
                cy.get("#placeBookingModal").should("be.visible");

                cy.selectFromSelect2(
                    "#booking_patron_id",
                    `${testPatron.surname}, ${testPatron.firstname}`,
                    testPatron.cardnumber
                );
                cy.wait("@getPickupLocations");

                cy.get("#pickup_library_id").should("not.be.disabled");
                cy.selectFromSelect2ByIndex("#pickup_library_id", 0);

                cy.get("#booking_itemtype").should("not.be.disabled");
                cy.selectFromSelect2ByIndex("#booking_itemtype", 0);
                cy.wait("@getCirculationRules");

                cy.selectFromSelect2ByIndex("#booking_item_id", 0); // "Any item"
                cy.get("#period").should("not.be.disabled");
                cy.get("#period").as("flatpickrInput");

                // Helper to check date availability - checks boundaries + random middle date
                const checkDatesAvailable = (fromDay, toDay) => {
                    const daysToCheck = [fromDay, toDay];
                    if (toDay - fromDay > 1) {
                        const randomMiddle =
                            fromDay +
                            1 +
                            Math.floor(Math.random() * (toDay - fromDay - 1));
                        daysToCheck.push(randomMiddle);
                    }
                    daysToCheck.forEach(day => {
                        cy.get("@flatpickrInput")
                            .getFlatpickrDate(today.add(day, "day").toDate())
                            .should("not.have.class", "flatpickr-disabled");
                    });
                };

                const checkDatesDisabled = (fromDay, toDay) => {
                    const daysToCheck = [fromDay, toDay];
                    if (toDay - fromDay > 1) {
                        const randomMiddle =
                            fromDay +
                            1 +
                            Math.floor(Math.random() * (toDay - fromDay - 1));
                        daysToCheck.push(randomMiddle);
                    }
                    daysToCheck.forEach(day => {
                        cy.get("@flatpickrInput")
                            .getFlatpickrDate(today.add(day, "day").toDate())
                            .should("have.class", "flatpickr-disabled");
                    });
                };

                // SCENARIO 1: Start day 5
                // Pool starts: ITEM0, ITEM1, ITEM2 (ITEM3 booked 1-7)
                // Day 10: lose ITEM0, Day 13: lose ITEM1, Day 18: lose ITEM2 → disabled
                cy.log("=== Scenario 1: Start day 5 ===");
                cy.get("@flatpickrInput").openFlatpickr();
                cy.get("@flatpickrInput")
                    .getFlatpickrDate(today.add(5, "day").toDate())
                    .click();

                checkDatesAvailable(6, 17); // Available through day 17
                checkDatesDisabled(18, 20); // Disabled from day 18

                // SCENARIO 2: Start day 8
                // Pool starts: ALL 4 items (ITEM3 booking 1-7 ended)
                // Progressive reduction until day 23 when ITEM3's second booking starts
                cy.log("=== Scenario 2: Start day 8 (all items available) ===");
                cy.get("@flatpickrInput").clearFlatpickr();
                cy.get("@flatpickrInput").openFlatpickr();
                cy.get("@flatpickrInput")
                    .getFlatpickrDate(today.add(8, "day").toDate())
                    .click();

                checkDatesAvailable(9, 22); // Can book through day 22
                checkDatesDisabled(23, 25); // Disabled from day 23

                // SCENARIO 3: Start day 19
                // Pool starts: ITEM0 (booking ended day 15), ITEM3
                // ITEM0 stays available indefinitely, ITEM3 loses at day 23
                cy.log("=== Scenario 3: Start day 19 ===");
                cy.get("@flatpickrInput").clearFlatpickr();
                cy.get("@flatpickrInput").openFlatpickr();
                cy.get("@flatpickrInput")
                    .getFlatpickrDate(today.add(19, "day").toDate())
                    .click();

                // ITEM0 remains in pool, so dates stay available past day 23
                checkDatesAvailable(20, 25);
            });

        // Cleanup
        cy.then(() => {
            if (testBiblio) {
                cy.task("query", {
                    sql: "DELETE FROM bookings WHERE biblio_id = ?",
                    values: [testBiblio.biblio_id],
                });
                cy.task("deleteSampleObjects", {
                    biblio: testBiblio,
                    items: testItems,
                });
            }
            if (testPatron) {
                cy.task("query", {
                    sql: "DELETE FROM borrowers WHERE borrowernumber = ?",
                    values: [testPatron.patron_id],
                });
            }
        });
    });

    it("should correctly handle lead/trail period conflicts for 'any item' bookings", () => {
        /**
         * Bug 37707: Lead/Trail Period Conflict Detection for "Any Item" Bookings
         * ========================================================================
         *
         * This test validates that lead/trail period conflict detection works correctly
         * when "any item of itemtype X" is selected. The key principle is:
         *
         * - Only block date selection when ALL items of the itemtype have conflicts
         * - Allow selection when at least one item is free from lead/trail conflicts
         *
         * The bug occurred because the mouseover handler was checking conflicts against
         * ALL bookings regardless of itemtype, rather than tracking per-item conflicts.
         *
         * Test Setup:
         * ===========
         * - Fixed date: June 1, 2026 (keeps all test dates in same month)
         * - 3 items of itemtype BK
         * - Lead period: 2 days, Trail period: 2 days
         * - ITEM 0: Booking on days 10-12 (June 11-13, trail period: June 14-15)
         * - ITEM 1: Booking on days 10-12 (same as item 0)
         * - ITEM 2: No bookings (always available)
         *
         * Test Scenarios:
         * ==============
         * 1. Hover day 15 (June 16): ITEM 0 and ITEM 1 have trail period conflict
         *    (lead period June 14-15 overlaps their trail June 14-15), but ITEM 2 is free
         *    → Should NOT be blocked (at least one item available)
         *
         * 2. Create booking on ITEM 2 for days 10-12, then hover day 15 again:
         *    → ALL items now have trail period conflicts
         *    → Should BE blocked
         *
         * 3. Visual feedback: Check existingBookingTrail on days 13-14 (June 14-15)
         *
         * 4. Visual feedback: Check existingBookingLead on days 8-9 (June 9-10)
         */

        // Anchor "today" to next month so bookings stay in the future ( the API drops past ones )
        const fixedToday = dayjs()
            .add(1, "month")
            .startOf("month")
            .hour(8)
            .toDate();
        cy.clock(fixedToday, ["Date"]);

        const today = dayjs(fixedToday);
        let testItems = [];
        let testBiblio = null;
        let testPatron = null;
        let testLibraries = null;

        // Circulation rules with non-zero lead/trail periods
        const circulationRules = {
            bookings_lead_period: 2,
            bookings_trail_period: 2,
            issuelength: 14,
            renewalsallowed: 2,
            renewalperiod: 7,
        };

        // Setup: Create biblio with 3 items of the same itemtype
        cy.task("insertSampleBiblio", { item_count: 3 })
            .then(objects => {
                testBiblio = objects.biblio;
                testItems = objects.items;
                testLibraries = objects.libraries;

                // Make all items the same itemtype (BK)
                const itemUpdates = testItems.map((item, index) => {
                    const enumchron = String.fromCharCode(65 + index);
                    return cy.task("query", {
                        sql: "UPDATE items SET bookable = 1, itype = 'BK', homebranch = 'CPL', enumchron = ?, dateaccessioned = ? WHERE itemnumber = ?",
                        values: [
                            enumchron,
                            `2024-12-0${4 - index}`,
                            item.item_id,
                        ],
                    });
                });
                return Promise.all(itemUpdates);
            })
            .then(() => {
                return cy.task("buildSampleObject", {
                    object: "patron",
                    values: {
                        firstname: "LeadTrail",
                        surname: "Tester",
                        cardnumber: `LT${Date.now()}`,
                        category_id: "PT",
                        library_id: "CPL",
                    },
                });
            })
            .then(mockPatron => {
                testPatron = mockPatron;
                return cy.task("query", {
                    sql: `INSERT INTO borrowers (borrowernumber, firstname, surname, cardnumber, categorycode, branchcode, dateofbirth)
                          VALUES (?, ?, ?, ?, ?, ?, ?)`,
                    values: [
                        mockPatron.patron_id,
                        mockPatron.firstname,
                        mockPatron.surname,
                        mockPatron.cardnumber,
                        mockPatron.category_id,
                        mockPatron.library_id,
                        "1990-01-01",
                    ],
                });
            })
            .then(() => {
                // Create bookings on ITEM 0 and ITEM 1 for days 10-12
                // ITEM 2 remains free
                const bookingInserts = [
                    // ITEM 0: Booked days 10-12
                    cy.task("query", {
                        sql: `INSERT INTO bookings (biblio_id, patron_id, item_id, pickup_library_id, start_date, end_date, status)
                              VALUES (?, ?, ?, ?, ?, ?, ?)`,
                        values: [
                            testBiblio.biblio_id,
                            testPatron.patron_id,
                            testItems[0].item_id,
                            "CPL",
                            today.add(10, "day").format("YYYY-MM-DD"),
                            today.add(12, "day").format("YYYY-MM-DD"),
                            "new",
                        ],
                    }),
                    // ITEM 1: Booked days 10-12 (same period)
                    cy.task("query", {
                        sql: `INSERT INTO bookings (biblio_id, patron_id, item_id, pickup_library_id, start_date, end_date, status)
                              VALUES (?, ?, ?, ?, ?, ?, ?)`,
                        values: [
                            testBiblio.biblio_id,
                            testPatron.patron_id,
                            testItems[1].item_id,
                            "CPL",
                            today.add(10, "day").format("YYYY-MM-DD"),
                            today.add(12, "day").format("YYYY-MM-DD"),
                            "new",
                        ],
                    }),
                    // ITEM 2: No booking - remains free
                ];
                return Promise.all(bookingInserts);
            })
            .then(() => {
                cy.intercept(
                    "GET",
                    `/api/v1/biblios/${testBiblio.biblio_id}/pickup_locations*`
                ).as("getPickupLocations");
                cy.intercept("GET", "/api/v1/circulation_rules*", {
                    body: [circulationRules],
                }).as("getCirculationRules");

                cy.visit(
                    `/cgi-bin/koha/catalogue/detail.pl?biblionumber=${testBiblio.biblio_id}`
                );

                cy.get('[data-bs-target="#placeBookingModal"]').first().click();
                cy.get("#placeBookingModal").should("be.visible");

                cy.selectFromSelect2(
                    "#booking_patron_id",
                    `${testPatron.surname}, ${testPatron.firstname}`,
                    testPatron.cardnumber
                );
                cy.wait("@getPickupLocations");

                cy.get("#pickup_library_id").should("not.be.disabled");
                cy.selectFromSelect2ByIndex("#pickup_library_id", 0);

                // Select itemtype BK
                cy.get("#booking_itemtype").should("not.be.disabled");
                cy.selectFromSelect2("#booking_itemtype", "Books");
                cy.wait("@getCirculationRules");

                // Select "Any item" (index 0)
                cy.selectFromSelect2ByIndex("#booking_item_id", 0);
                cy.get("#booking_item_id").should("have.value", "0");

                cy.get("#period").should("not.be.disabled");
                cy.get("#period").as("flatpickrInput");

                // ================================================================
                // SCENARIO 1: Hover day 15 - ITEM 2 is free, should NOT be blocked
                // ================================================================
                cy.log(
                    "=== Scenario 1: Day 15 should be selectable (ITEM 2 is free) ==="
                );

                cy.get("@flatpickrInput").openFlatpickr();
                cy.get("@flatpickrInput")
                    .getFlatpickrDate(today.add(15, "day").toDate())
                    .trigger("mouseover");

                // Day 15 should NOT have leadDisable class (at least one item is free)
                cy.get("@flatpickrInput")
                    .getFlatpickrDate(today.add(15, "day").toDate())
                    .should("not.have.class", "leadDisable");

                // Actually click day 15 to verify it's selectable
                cy.get("@flatpickrInput")
                    .getFlatpickrDate(today.add(15, "day").toDate())
                    .should("not.have.class", "flatpickr-disabled")
                    .click();

                // Verify day 15 was selected as start date
                cy.get("@flatpickrInput")
                    .getFlatpickrDate(today.add(15, "day").toDate())
                    .should("have.class", "selected");

                // Reset for next scenario
                cy.get("@flatpickrInput").clearFlatpickr();

                // ================================================================
                // SCENARIO 2: Add booking on ITEM 2 - ALL items now have conflicts
                // ================================================================
                cy.log(
                    "=== Scenario 2: Day 15 should be BLOCKED when all items have conflicts ==="
                );

                // Add booking on ITEM 2 for same period (days 10-12)
                cy.task("query", {
                    sql: `INSERT INTO bookings (biblio_id, patron_id, item_id, pickup_library_id, start_date, end_date, status)
                          VALUES (?, ?, ?, ?, ?, ?, ?)`,
                    values: [
                        testBiblio.biblio_id,
                        testPatron.patron_id,
                        testItems[2].item_id,
                        "CPL",
                        today.add(10, "day").format("YYYY-MM-DD"),
                        today.add(12, "day").format("YYYY-MM-DD"),
                        "new",
                    ],
                }).then(() => {
                    // Re-arm the frozen clock so the reloaded page loads with the faked today
                    cy.clock(fixedToday, ["Date"]);
                    // Reload page to get updated booking data
                    cy.visit(
                        `/cgi-bin/koha/catalogue/detail.pl?biblionumber=${testBiblio.biblio_id}`
                    );

                    cy.get('[data-bs-target="#placeBookingModal"]')
                        .first()
                        .click();
                    cy.get("#placeBookingModal").should("be.visible");

                    cy.selectFromSelect2(
                        "#booking_patron_id",
                        `${testPatron.surname}, ${testPatron.firstname}`,
                        testPatron.cardnumber
                    );
                    cy.wait("@getPickupLocations");

                    cy.get("#pickup_library_id").should("not.be.disabled");
                    cy.selectFromSelect2ByIndex("#pickup_library_id", 0);

                    // Select itemtype BK
                    cy.get("#booking_itemtype").should("not.be.disabled");
                    cy.selectFromSelect2("#booking_itemtype", "Books");
                    cy.wait("@getCirculationRules");

                    // Select "Any item" (index 0)
                    cy.selectFromSelect2ByIndex("#booking_item_id", 0);
                    cy.get("#booking_item_id").should("have.value", "0");

                    cy.get("#period").should("not.be.disabled");
                    cy.get("#period").as("flatpickrInput2");

                    cy.get("@flatpickrInput2").openFlatpickr();
                    cy.get("@flatpickrInput2")
                        .getFlatpickrDate(today.add(15, "day").toDate())
                        .trigger("mouseover");

                    // Day 15 should NOW have leadDisable class (all items have conflicts)
                    cy.get("@flatpickrInput2")
                        .getFlatpickrDate(today.add(15, "day").toDate())
                        .should("have.class", "leadDisable");

                    // ================================================================
                    // SCENARIO 3: Visual feedback - existingBookingTrail for days 13-14
                    // ================================================================
                    cy.log(
                        "=== Scenario 3: Visual feedback - Trail period display ==="
                    );

                    cy.get("@flatpickrInput2")
                        .getFlatpickrDate(today.add(13, "day").toDate())
                        .should("have.class", "existingBookingTrail");

                    cy.get("@flatpickrInput2")
                        .getFlatpickrDate(today.add(14, "day").toDate())
                        .should("have.class", "existingBookingTrail");

                    // ================================================================
                    // SCENARIO 4: Visual feedback - existingBookingLead for days 8-9
                    // ================================================================
                    cy.log(
                        "=== Scenario 4: Visual feedback - Lead period display ==="
                    );

                    cy.get("@flatpickrInput2")
                        .getFlatpickrDate(today.add(5, "day").toDate())
                        .trigger("mouseover");

                    cy.get("@flatpickrInput2")
                        .getFlatpickrDate(today.add(8, "day").toDate())
                        .should("have.class", "existingBookingLead");

                    cy.get("@flatpickrInput2")
                        .getFlatpickrDate(today.add(9, "day").toDate())
                        .should("have.class", "existingBookingLead");
                });
            });

        // Cleanup
        cy.then(() => {
            if (testBiblio) {
                cy.task("query", {
                    sql: "DELETE FROM bookings WHERE biblio_id = ?",
                    values: [testBiblio.biblio_id],
                });
                cy.task("deleteSampleObjects", {
                    biblio: testBiblio,
                    items: testItems,
                    libraries: testLibraries,
                });
            }
            if (testPatron) {
                cy.task("query", {
                    sql: "DELETE FROM borrowers WHERE borrowernumber = ?",
                    values: [testPatron.patron_id],
                });
            }
        });
    });
});
