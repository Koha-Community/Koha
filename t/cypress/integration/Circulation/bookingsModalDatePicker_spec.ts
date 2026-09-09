import dayjs from "dayjs";
import isSameOrBefore from "dayjs/plugin/isSameOrBefore";
dayjs.extend(isSameOrBefore);

// Pin for cy.clock(..., ["Date"]): the 10th of next month at 09:00 local.
// Anchoring "today" to a fixed day-of-month keeps every relative offset
// used below inside the current or next calendar month, so the date
// assertions can run unconditionally instead of being silently skipped
// when a real late-in-month "today" pushes them out of view. Deriving
// the pin from the real date (rather than hardcoding one) keeps the
// bookings these tests create in the future.
const pinnedToday = () =>
    dayjs().add(1, "month").date(10).hour(9).minute(0).second(0).millisecond(0);

describe("Booking Modal Date Picker Tests", () => {
    let testData = {};

    beforeEach(() => {
        cy.login();
        cy.title().should("eq", "Koha staff interface");

        // Create fresh test data for each test using upstream pattern;
        // items are born bookable with predictable item types via the builder.
        cy.task("insertSampleBiblio", {
            item_count: 2,
            item_values: [
                {
                    bookable: 1,
                    item_type_id: "BK",
                    serial_issue_number: "A",
                    acquisition_date: "2024-12-03",
                },
                {
                    bookable: 1,
                    item_type_id: "CF",
                    serial_issue_number: "B",
                    acquisition_date: "2024-12-02",
                },
            ],
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
        cy.get("booking-modal .modal").should("exist");
        cy.get("[data-booking-modal]")
            .first()
            .then($btn => $btn[0].click());
        cy.get("booking-modal .modal", { timeout: 10000 }).should("be.visible");

        // Fill required fields to enable item selection
        cy.vueSelect(
            "booking_patron",
            testData.patron.cardnumber,
            `${testData.patron.surname} ${testData.patron.firstname}`
        );
        cy.wait("@getPickupLocations");

        cy.vueSelectShouldBeEnabled("pickup_library_id");
        cy.vueSelectByIndex("pickup_library_id", 0);

        // Only auto-select item if not overridden
        if (options.skipItemSelection !== true) {
            cy.vueSelectShouldBeEnabled("booking_item_id");
            cy.vueSelectByIndex("booking_item_id", 1); // Select second item (CF)
            cy.wait("@getCirculationRules");

            // Verify date picker is now enabled
            cy.get("#booking_period").should("not.be.disabled");
        }
    };

    it("supports keyboard range selection and restores focus", () => {
        const fixedToday = pinnedToday();
        cy.clock(fixedToday.toDate(), ["Date"]);

        setupModalForDateTesting();

        cy.get("#booking_period")
            .focus()
            .then($input => {
                // Focusing Flatpickr opens its overlay over the input before
                // Cypress can perform a second actionability check. Dispatch
                // the browser event directly and include the legacy numeric
                // fields still read by Koha's global shortcut library.
                const event = new KeyboardEvent("keydown", {
                    key: "Enter",
                    code: "Enter",
                    bubbles: true,
                    cancelable: true,
                });
                Object.defineProperties(event, {
                    keyCode: { value: 13 },
                    which: { value: 13 },
                });
                $input[0].dispatchEvent(event);
            });
        cy.get(".flatpickr-calendar.open").should("be.visible");
        cy.focused()
            .should("have.class", "flatpickr-day")
            .then($start => {
                const element = $start[0] as HTMLElement & { dateObj: Date };
                cy.wrap(dayjs(element.dateObj).format("YYYY-MM-DD")).as(
                    "keyboardStart"
                );
            });

        cy.focused().trigger("keydown", {
            key: "Enter",
            code: "Enter",
            keyCode: 13,
            which: 13,
        });
        cy.focused().trigger("keydown", {
            key: "ArrowRight",
            code: "ArrowRight",
            keyCode: 39,
            which: 39,
        });
        cy.get("@keyboardStart").then(start => {
            cy.focused().should($end => {
                const element = $end[0] as HTMLElement & { dateObj: Date };
                expect(dayjs(element.dateObj).format("YYYY-MM-DD")).to.equal(
                    dayjs(String(start)).add(1, "day").format("YYYY-MM-DD")
                );
            });
        });
        cy.focused().trigger("keydown", {
            key: "Enter",
            code: "Enter",
            keyCode: 13,
            which: 13,
        });

        cy.get(".flatpickr-calendar.open").should("not.exist");
        cy.focused().should("have.attr", "id", "booking_period");
        cy.get("#booking_period").should("not.have.value", "");
    });

    it("closes on Escape and on a click elsewhere in the same modal", () => {
        // The calendar is appended inside the booking modal (Bootstrap's
        // focus trap otherwise clips/redirects it - see BookingCalendar's
        // buildConfig). Bootstrap's modal-dialog content stops click
        // propagation to keep its own backdrop-dismiss logic from firing
        // on clicks inside the dialog, which also swallowed Flatpickr's
        // own outside-click listener for any click elsewhere in that same
        // modal - only a click fully outside the modal still closed it.
        const fixedToday = pinnedToday();
        cy.clock(fixedToday.toDate(), ["Date"]);

        setupModalForDateTesting();

        cy.get("#booking_period").click();
        cy.get(".flatpickr-calendar.open").should("be.visible");
        cy.get("#booking_period").trigger("keydown", {
            key: "Escape",
            code: "Escape",
            keyCode: 27,
            which: 27,
        });
        cy.get(".flatpickr-calendar.open").should("not.exist");

        cy.get("#booking_period").click();
        cy.get(".flatpickr-calendar.open").should("be.visible");
        cy.get("booking-modal .modal .modal-header").click();
        cy.get(".flatpickr-calendar.open").should("not.exist");
    });

    it("should initialize flatpickr with correct future-date constraints", () => {
        const fixedToday = pinnedToday();
        cy.clock(fixedToday.toDate(), ["Date"]);

        setupModalForDateTesting();

        // Set up the flatpickr alias and open the calendar
        cy.get("#booking_period").as("flatpickrInput");
        cy.get("@flatpickrInput").openFlatpickr();

        // Verify past dates are disabled
        const yesterday = fixedToday.subtract(1, "day");
        cy.get("@flatpickrInput")
            .getFlatpickrDate(yesterday.toDate())
            .should("have.class", "flatpickr-disabled");

        // Verify that future dates are not disabled
        const tomorrow = fixedToday.add(1, "day");
        cy.get("@flatpickrInput")
            .getFlatpickrDate(tomorrow.toDate())
            .should("not.have.class", "flatpickr-disabled");
    });

    it("should disable dates with existing bookings for same item", () => {
        const fixedToday = pinnedToday();
        cy.clock(fixedToday.toDate(), ["Date"]);
        const today = fixedToday.startOf("day");

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

        // Create existing bookings for the same item we'll test with
        existingBookings.forEach(booking => {
            cy.task("insertSampleBooking", {
                item: testData.items[0],
                patron: testData.patron,
                pickup_library_id: testData.libraries[0].library_id,
                start_date: booking.start.toISOString(),
                end_date: booking.end.toISOString(),
            });
        });

        // Setup modal but skip auto-item selection so we can control which item to select
        setupModalForDateTesting({ skipItemSelection: true });

        // Select the specific item that has the existing bookings (by barcode, not index)
        cy.vueSelectShouldBeEnabled("booking_item_id");
        cy.vueSelect(
            "booking_item_id",
            testData.items[0].external_id,
            testData.items[0].external_id
        );
        cy.wait("@getCirculationRules");

        // Verify date picker is now enabled
        cy.get("#booking_period").should("not.be.disabled");

        // Set up flatpickr alias and open the calendar
        cy.get("#booking_period").as("flatpickrInput");
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
            cy.get("@flatpickrInput")
                .getFlatpickrDate(date.toDate())
                .should("not.have.class", "flatpickr-disabled");
        });

        cy.log("=== PHASE 2: Testing booked periods are disabled ===");
        // Days 8-13, 18-22, 28-30: Should be disabled (existing bookings)
        existingBookings.forEach(booking => {
            cy.log(
                `Testing ${booking.name}: Days ${booking.start.format("YYYY-MM-DD")} to ${booking.end.format("YYYY-MM-DD")}`
            );

            // Test each day in the booking period
            for (
                let date = booking.start;
                date.isSameOrBefore(booking.end);
                date = date.add(1, "day")
            ) {
                cy.get("@flatpickrInput")
                    .getFlatpickrDate(date.toDate())
                    .should("have.class", "flatpickr-disabled");
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
                cy.get("@flatpickrInput")
                    .getFlatpickrDate(date.toDate())
                    .should("not.have.class", "flatpickr-disabled");
            }
        });

        cy.log(
            "=== PHASE 4: Testing different item bookings don't conflict ==="
        );

        // Create a booking for the OTHER item (different from the one we're testing)
        const differentItemBooking = {
            start: today.add(35, "day"),
            end: today.add(40, "day"),
        };

        cy.task("insertSampleBooking", {
            // Use SECOND item (different from our test item)
            item: testData.items[1],
            patron: testData.patron,
            pickup_library_id: testData.libraries[0].library_id,
            start_date: differentItemBooking.start.toISOString(),
            end_date: differentItemBooking.end.toISOString(),
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
            cy.get("@flatpickrInput")
                .getFlatpickrDate(date.toDate())
                .should("not.have.class", "flatpickr-disabled");
        }

        cy.log(
            "=== PHASE 5: Testing dates after last booking are available ==="
        );
        // Days 41+: Should be available (after all bookings)
        const afterAllBookings = today.add(41, "day");
        cy.get("@flatpickrInput")
            .getFlatpickrDate(afterAllBookings.toDate())
            .should("not.have.class", "flatpickr-disabled");
    });

    it("should handle date range validation correctly", () => {
        setupModalForDateTesting();

        cy.intercept("POST", "/api/v1/bookings").as("createBooking");

        // Test valid date range
        const startDate = dayjs().add(2, "day");
        const endDate = dayjs().add(5, "day");

        cy.get("#booking_period").selectFlatpickrDateRange(startDate, endDate);

        // Verify the dates were accepted (check that period field has value)
        cy.get("#booking_period").should("not.have.value", "");

        // Submit: no conflicting bookings exist in this test, so a valid
        // range must be accepted by the server and close the modal.
        cy.get('button[form="form-booking"][type="submit"]')
            .should("not.be.disabled")
            .click();

        cy.wait("@createBooking").its("response.statusCode").should("eq", 201);
        cy.get("booking-modal .modal").should("not.be.visible");
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
         *
         * CIRCULATION RULES DATE CALCULATION:
         * ==================================
         *
         * Test Circulation Rules:
         * - Issue Length: 10 days (primary booking period)
         * - Renewals Allowed: 3 renewals
         * - Renewal Period: 5 days each
         * - Total Maximum Period: 10 + (3 × 5) = 25 days
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
        cy.vueSelectShouldBeEnabled("booking_item_id");
        cy.vueSelectByIndex("booking_item_id", 1);
        cy.wait("@getDateTestRules");

        cy.get("#booking_period").should("not.be.disabled");
        cy.get("#booking_period").as("dateTestFlatpickr");
        cy.get("@dateTestFlatpickr").openFlatpickr();

        // ========================================================================
        // TEST 1: Maximum Date Calculation and Enforcement
        // ========================================================================
        cy.log(
            "=== TEST 1: Testing maximum date calculation and enforcement ==="
        );

        // Test in clear zone starting at Day 50 to avoid conflicts
        const clearZoneStart = today.add(50, "day");
        // Start date counts as day 1 (Koha convention), so max end = start + (maxPeriod - 1)
        const maxPeriod =
            dateTestCirculationRules.issuelength +
            dateTestCirculationRules.renewalsallowed *
                dateTestCirculationRules.renewalperiod; // 10 + 3*5 = 25
        const calculatedMaxDate = clearZoneStart.add(maxPeriod - 1, "day"); // Day 50 + 24 = Day 74

        const beyondMaxDate = calculatedMaxDate.add(1, "day"); // Day 75

        cy.log(
            `Clear zone start: ${clearZoneStart.format("YYYY-MM-DD")} (Day 50)`
        );
        cy.log(
            `Calculated max date: ${calculatedMaxDate.format("YYYY-MM-DD")} (Day 74)`
        );
        cy.log(
            `Beyond max date: ${beyondMaxDate.format("YYYY-MM-DD")} (Day 75 - should be disabled)`
        );

        // Select the start date to establish context for bold date calculation
        cy.get("@dateTestFlatpickr").selectFlatpickrDate(
            clearZoneStart.toDate()
        );

        // Verify max date enforcement via the flatpickr disable function.
        // We query the disable function directly rather than navigating the
        // calendar DOM, because the booking modal's reactive system
        // (onMonthChange → visibleRangeRef → syncInstanceDatesFromStore →
        // fp.jumpToDate) races with test navigation and pulls the calendar
        // back to the start date's month.
        cy.get("@dateTestFlatpickr").should($el => {
            const fp = $el[0]._flatpickr;
            const disableFn = fp.config.disable[0];
            expect(disableFn(calculatedMaxDate.toDate())).to.eq(
                false,
                `Max date ${calculatedMaxDate.format("YYYY-MM-DD")} should be selectable`
            );
            expect(disableFn(beyondMaxDate.toDate())).to.eq(
                true,
                `Beyond max date ${beyondMaxDate.format("YYYY-MM-DD")} should be disabled`
            );
        });

        // ========================================================================
        // TEST 2: Bold Date Styling for Issue and Renewal Periods
        // ========================================================================
        cy.log(
            "=== TEST 2: Testing bold date styling for issue and renewal periods ==="
        );

        // Vue version uses "booking-loan-boundary" class instead of "title"
        const expectedBoldDates = [];

        // Start date is always bold
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

        // The full boundary-set math is pinned by the
        // useBookingCalendarMaps component spec; here we verify the class
        // lands in the DOM for dates in the currently visible month.
        // Query calendarContainer directly to avoid navigation races (the
        // booking modal's onMonthChange handler can jump the calendar away).
        cy.get("@dateTestFlatpickr").should($el => {
            const fp = $el[0]._flatpickr;
            // Ensure calendar shows the start date's month
            if (
                fp.currentMonth !== clearZoneStart.month() ||
                fp.currentYear !== clearZoneStart.year()
            ) {
                fp.jumpToDate(clearZoneStart.toDate());
                throw new Error("Jumped to target month, retrying assertion");
            }

            expectedBoldDates
                .filter(d => d.month() === clearZoneStart.month())
                .forEach(boldDate => {
                    const label = `${boldDate.format("MMMM D, YYYY")}`;
                    const el = fp.calendarContainer.querySelector(
                        `.flatpickr-day[aria-label="${label}"]`
                    );
                    expect(
                        el,
                        `Day ${boldDate.format("YYYY-MM-DD")} should exist`
                    ).to.not.equal(null);
                    expect(
                        el.classList.contains("booking-loan-boundary"),
                        `Day ${boldDate.format("YYYY-MM-DD")} should have booking-loan-boundary class`
                    ).to.equal(true);
                });

            // Verify no unexpected bold dates in the current view
            const boldElements = fp.calendarContainer.querySelectorAll(
                ".flatpickr-day.booking-loan-boundary"
            );
            boldElements.forEach(boldEl => {
                const ariaLabel = boldEl.getAttribute("aria-label");
                const date = dayjs(ariaLabel, "MMMM D, YYYY");
                const isExpected = expectedBoldDates.some(expected =>
                    date.isSame(expected, "day")
                );
                expect(
                    isExpected,
                    `Unexpected bold date: ${ariaLabel}`
                ).to.equal(true);
            });
        });

        // ========================================================================
        // TEST 3: Date Range Selection Within Limits
        // ========================================================================
        cy.log(
            "=== TEST 3: Testing date range selection within circulation limits ==="
        );

        // Clear the flatpickr selection from previous tests
        cy.get("#booking_period").clearFlatpickr();

        // Test selecting a mid-range period (issue + 1 renewal = 15 days)
        const midRangeEnd = clearZoneStart.add(15, "day");

        cy.get("#booking_period").selectFlatpickrDateRange(
            clearZoneStart,
            midRangeEnd
        );

        // Verify dates were accepted (period field has value)
        cy.get("#booking_period").should("not.have.value", "");

        // Test selecting full maximum range
        cy.get("#booking_period").selectFlatpickrDateRange(
            clearZoneStart,
            calculatedMaxDate
        );

        // Verify full range was accepted
        cy.get("#booking_period").should("not.have.value", "");
    });

    it("should handle lead and trail periods", () => {
        /**
         * Lead and Trail Period Behaviour Tests
         * ======================================================================
         *
         * In the Vue version, lead/trail periods are indicated via:
         * - booking-day--lead / booking-day--trail day classes, applied to
         *   every existing booking's window but unstyled unless it's the
         *   one directly adjacent to the hovered gap
         *   (booking-day--existing-lead-adjacent / --existing-trail-adjacent)
         * - booking-day--my-lead-buffer / --my-trail-buffer previewing my
         *   own prospective booking's buffer relative to the hovered
         *   candidate - both bands preview together even before a start
         *   date is chosen (see PHASE 1)
         * - flatpickr-disabled class for dates that cannot be selected
         *
         * The Vue version disables dates with lead/trail conflicts via the
         * disable function rather than applying leadDisable/trailDisable classes.
         *
         * Fixed Date Setup:
         * ================
         * - Today: June 10, 2026 (Wednesday)
         * - Lead Period: 2 days
         * - Trail Period: 3 days
         * - Issue Length: 3 days
         * - Renewal Period: 2 days
         * - Max Renewals: 2
         * - Max Booking Period: 3 + (2 × 2) = 7 days
         *
         * Blocker Booking: June 25-27, 2026
         */

        // Fix the browser Date object to June 10, 2026 at 09:00 Europe/London
        const fixedToday = new Date("2026-06-10T08:00:00Z"); // 09:00 BST (UTC+1)
        cy.clock(fixedToday, ["Date"]);
        cy.log(`Fixed today: June 10, 2026`);

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

        // Real rules, scoped to the itemtype of the item under test: the
        // availability map is computed server-side from the same rules the
        // client fetches, so a client-only intercept cannot stand in for
        // them anymore.
        cy.task("insertSampleCirculationRules", {
            item_type_id: testData.items[0].item_type_id,
            rules: circulationRules,
        }).then(objects => {
            testData.circulation_rules = objects.circulation_rules;
        });
        cy.intercept("GET", "/api/v1/circulation_rules*").as(
            "getFixedDateRules"
        );

        // Create blocker booking: June 25-27, 2026 (local time)
        cy.task("insertSampleBooking", {
            item: testData.items[0],
            patron: testData.patron,
            pickup_library_id: testData.libraries[0].library_id,
            start_date: dayjs("2026-06-25").startOf("day").toISOString(),
            end_date: dayjs("2026-06-27").endOf("day").toISOString(),
        });

        // Setup modal
        setupModalForDateTesting({ skipItemSelection: true });

        // Select the item that has the blocker booking (items[0] = index 0)
        cy.vueSelectShouldBeEnabled("booking_item_id");
        cy.vueSelectByIndex("booking_item_id", 0);
        cy.wait("@getFixedDateRules");

        cy.get("#booking_period").should("not.be.disabled");

        // The constraint-info box states the active lead/trail day counts
        // up front, permanently - not just on hover.
        cy.get(".booking-constraint-info")
            .should("contain.text", "Lead period: 2 days before start")
            .and("contain.text", "Trail period: 3 days after return");

        cy.get("#booking_period").as("fp");
        cy.get("@fp").openFlatpickr();

        // Helpers that use native events to avoid detached DOM errors from Vue re-renders
        const monthNames = [
            "January",
            "February",
            "March",
            "April",
            "May",
            "June",
            "July",
            "August",
            "September",
            "October",
            "November",
            "December",
        ];
        const getDateSelector = (isoDate: string) => {
            const d = dayjs(isoDate);
            return `.flatpickr-day[aria-label="${monthNames[d.month()]} ${d.date()}, ${d.year()}"]`;
        };
        // PHASE 3 uses getDateByISO which navigates to the target month;
        // these helpers run in subsequent phases that may target dates in a
        // different month. Ensure the calendar is on the target month before
        // querying so the day cell is in the visible grid (not just the
        // overflow row).
        const ensureCalendarMonth = (isoDate: string) => {
            cy.get("@fp").then($input => {
                const fp = (
                    $input[0] as HTMLInputElement & {
                        _flatpickr?: {
                            currentMonth: number;
                            currentYear: number;
                            jumpToDate: (d: string) => void;
                        };
                    }
                )._flatpickr;
                const target = dayjs(isoDate);
                if (
                    fp &&
                    (fp.currentMonth !== target.month() ||
                        fp.currentYear !== target.year())
                ) {
                    // Pass an ISO string (parsed via flatpickr's dateFormat
                    // config) rather than a Date instance: cy.clock stubs the
                    // AUT's Date constructor, so a Date built in the runner
                    // context fails flatpickr's `instanceof Date` check
                    // across the iframe boundary.
                    fp.jumpToDate(target.format("YYYY-MM-DD"));
                }
            });
        };
        const hoverDateByISO = (isoDate: string) => {
            ensureCalendarMonth(isoDate);
            cy.get(getDateSelector(isoDate))
                .should("be.visible")
                .then($el => {
                    $el[0].dispatchEvent(
                        new MouseEvent("mouseover", { bubbles: true })
                    );
                });
        };
        const clickDateByISO = (isoDate: string) => {
            ensureCalendarMonth(isoDate);
            cy.get(getDateSelector(isoDate))
                .should("be.visible")
                .then($el => $el[0].click());
        };
        const getDateByISO = (isoDate: string) => {
            const date = new Date(isoDate);
            return cy.get("@fp").getFlatpickrDate(date);
        };

        // ========================================================================
        // PHASE 1: Lead Period - Hover shows lead markers
        // ========================================================================
        cy.log("=== PHASE 1: Lead period visual hints on hover ===");

        // Hover June 13 as potential start date
        // Lead period: June 11-12 (both after today June 10, no booking conflict)
        hoverDateByISO("2026-06-13");

        // June 11-12 are clear, so June 13 should NOT be disabled
        getDateByISO("2026-06-13").should(
            "not.have.class",
            "flatpickr-disabled"
        );

        // Both bands preview around the hovered candidate even before a
        // start is chosen - lead before it (June 11-12), trail after it
        // (June 14-16, trailDays=3) - matching the old UI's behaviour.
        getDateByISO("2026-06-11")
            .should("have.class", "booking-day--my-lead-buffer")
            .and("have.class", "booking-day--run-start");
        getDateByISO("2026-06-12")
            .should("have.class", "booking-day--my-lead-buffer")
            .and("have.class", "booking-day--run-end");
        getDateByISO("2026-06-14")
            .should("have.class", "booking-day--my-trail-buffer")
            .and("have.class", "booking-day--run-start");
        getDateByISO("2026-06-15")
            .should("have.class", "booking-day--my-trail-buffer")
            .and("not.have.class", "booking-day--run-start")
            .and("not.have.class", "booking-day--run-end");
        getDateByISO("2026-06-16")
            .should("have.class", "booking-day--my-trail-buffer")
            .and("have.class", "booking-day--run-end");

        // The feedback bar is pure instruction now - day counts live
        // permanently in the booking-constraint-info box instead.
        cy.get(".booking-hover-feedback").should(
            "have.text",
            "Select a start date"
        );

        // ========================================================================
        // PHASE 2: Trail Period - Hover shows trail markers
        // ========================================================================
        cy.log("=== PHASE 2: Trail period visual hints on hover ===");

        // Select June 13 as start date
        clickDateByISO("2026-06-13");

        // Hover June 16 as potential end date
        // Trail period: June 17-19 (clear of any bookings)
        hoverDateByISO("2026-06-16");

        // June 16 should not be disabled (trail is clear)
        getDateByISO("2026-06-16").should(
            "not.have.class",
            "flatpickr-disabled"
        );

        // Clear selection for next phase
        cy.get("#booking_period").clearFlatpickr();
        cy.get("@fp").openFlatpickr();

        // ========================================================================
        // PHASE 3: Lead Period Conflict - Existing bookings
        // ========================================================================
        cy.log("=== PHASE 3: Lead period conflicts ===");

        // Hover June 14 - Lead period (June 12-13), both after today, no booking conflict
        // Note: June 11 would be disabled by minimum advance booking (today+leadDays=June 12),
        // so we test with June 14 which is past the minimum advance period.
        hoverDateByISO("2026-06-14");
        getDateByISO("2026-06-14").should(
            "not.have.class",
            "flatpickr-disabled"
        );

        // Hover June 29 - Lead period (June 27-28), June 27 is in blocker booking
        hoverDateByISO("2026-06-29");
        getDateByISO("2026-06-29").should("have.class", "flatpickr-disabled");

        // ========================================================================
        // PHASE 3c: BIDIRECTIONAL - Lead Period Conflicts with Existing Booking TRAIL
        // ========================================================================

        // July 1: Lead June 29-30 → overlaps blocker trail (June 28-30) → DISABLED
        hoverDateByISO("2026-07-01");
        getDateByISO("2026-07-01").should("have.class", "flatpickr-disabled");

        // July 2: Lead June 30-July 1 → June 30 in blocker trail → DISABLED
        hoverDateByISO("2026-07-02");
        getDateByISO("2026-07-02").should("have.class", "flatpickr-disabled");

        // ========================================================================
        // PHASE 3d: First Clear Start Date After Blocker's Protected Period
        // ========================================================================

        // July 3: Lead July 1-2 → clear of blocker trail → NOT disabled
        hoverDateByISO("2026-07-03");
        getDateByISO("2026-07-03").should(
            "not.have.class",
            "flatpickr-disabled"
        );

        // ========================================================================
        // PHASE 4a: Trail Period Conflict - Existing Booking ACTUAL Dates
        // ========================================================================

        // Select June 20 as start date (lead June 18-19, both clear)
        clickDateByISO("2026-06-20");

        // Hover June 23 - Trail (June 24-26) overlaps blocker ACTUAL (June 25-27)
        hoverDateByISO("2026-06-23");
        getDateByISO("2026-06-23").should("have.class", "flatpickr-disabled");

        // Clear selection for next phase
        cy.get("#booking_period").clearFlatpickr();
        cy.get("@fp").openFlatpickr();

        // ========================================================================
        // PHASE 4b: BIDIRECTIONAL - Trail Period Conflicts with Existing Booking LEAD
        // ========================================================================

        // Select June 13 as start (lead June 11-12, both clear)
        clickDateByISO("2026-06-13");

        // Hover June 21 - Trail (June 22-24) overlaps blocker LEAD (June 23-24) → DISABLED
        hoverDateByISO("2026-06-21");
        getDateByISO("2026-06-21").should("have.class", "flatpickr-disabled");

        // June 20 - Trail (June 21-23), June 23 overlaps blocker lead → DISABLED
        hoverDateByISO("2026-06-20");
        getDateByISO("2026-06-20").should("have.class", "flatpickr-disabled");

        // June 19 - Trail (June 20-22) doesn't reach blocker lead (starts June 23) → NOT disabled
        hoverDateByISO("2026-06-19");
        getDateByISO("2026-06-19").should(
            "not.have.class",
            "flatpickr-disabled"
        );

        // Clear selection for next phase
        cy.get("#booking_period").clearFlatpickr();
        cy.get("@fp").openFlatpickr();

        // ========================================================================
        // PHASE 5: Max Date Selectable When Trail is Clear
        // ========================================================================

        // Select June 13 as start date
        clickDateByISO("2026-06-13");

        // June 20: trail (June 21-23) overlaps blocker lead (June 23-24) → DISABLED
        hoverDateByISO("2026-06-20");
        getDateByISO("2026-06-20").should("have.class", "flatpickr-disabled");

        // June 19: trail (June 20-22) clear of blocker lead → NOT disabled
        hoverDateByISO("2026-06-19");
        getDateByISO("2026-06-19").should(
            "not.have.class",
            "flatpickr-disabled"
        );

        // Actually select June 19 to confirm booking can be made
        clickDateByISO("2026-06-19");

        // Verify dates were accepted in the form
        cy.get("#booking_period").should("not.have.value", "");
    });

    it("should mark dates with existing bookings", () => {
        /**
         * Booking Day Marker Visual Indicator Test
         * =======================================
         *
         * No item is pre-selected in this test, so both items[0] and
         * items[1] are relevant. A date only carries booking-day--booked
         * once every relevant item is booked there (mirrors
         * disabledByDate's allBlocked test) - a date with only one of the
         * two items booked carries booking-day--partial instead, since
         * the other item is still free and the date remains selectable.
         */

        const fixedToday = pinnedToday();
        cy.clock(fixedToday.toDate(), ["Date"]);
        const today = fixedToday.startOf("day");

        // Set up circulation rules for marker testing
        const markerCirculationRules = {
            bookings_lead_period: 1,
            bookings_trail_period: 1,
            issuelength: 7,
            renewalsallowed: 1,
            renewalperiod: 3,
        };

        cy.intercept("GET", "/api/v1/circulation_rules*", {
            body: [markerCirculationRules],
        }).as("getMarkerRules");

        // Create strategic bookings for marker testing
        const testBookings = [
            // Multiple bookings on same dates (Days 5-6): Items 0 + 1
            {
                item_id: testData.items[0].item_id,
                start: today.add(5, "day"),
                end: today.add(6, "day"),
                name: "Multi-booking 1",
            },
            {
                item_id: testData.items[1].item_id,
                start: today.add(5, "day"),
                end: today.add(6, "day"),
                name: "Multi-booking 2",
            },
            // Single booking spanning multiple days (Days 10-12): Item 0
            {
                item_id: testData.items[0].item_id,
                start: today.add(10, "day"),
                end: today.add(12, "day"),
                name: "Single span booking",
            },
            // Isolated single booking (Day 15): Item 0
            {
                item_id: testData.items[0].item_id,
                start: today.add(15, "day"),
                end: today.add(15, "day"),
                name: "Isolated booking",
            },
        ];

        // Create all test bookings via the API builder
        testBookings.forEach(booking => {
            cy.task("insertSampleBooking", {
                item: {
                    item_id: booking.item_id,
                    biblio_id: testData.biblio.biblio_id,
                },
                patron: testData.patron,
                pickup_library_id: testData.libraries[0].library_id,
                start_date: booking.start.toISOString(),
                end_date: booking.end.toISOString(),
            });
        });

        setupModalForDateTesting({ skipItemSelection: true });

        // Keep the item clear so availability and marker aggregation cover
        // both booked items rather than filtering to one concrete item.
        cy.wait("@getMarkerRules");
        cy.get("#booking_period").should("not.be.disabled");
        cy.get("#booking_period").as("markerFlatpickr");
        cy.get("@markerFlatpickr").openFlatpickr();

        // ========================================================================
        // TEST 1: Single Booking Marker Dots (Days 10, 11, 12)
        // ========================================================================
        // Only items[0] is booked here - items[1] is still free, so these
        // dates read as partial, not fully booked.

        const singleDotDates = [
            today.add(10, "day"),
            today.add(11, "day"),
            today.add(12, "day"),
        ];

        singleDotDates.forEach(date => {
            cy.get("@markerFlatpickr")
                .getFlatpickrDate(date.toDate())
                .should("have.class", "booking-day--partial");
        });

        // ========================================================================
        // TEST 2: Multiple Bookings on Same Date (Days 5-6)
        // ========================================================================

        const multipleDotDates = [today.add(5, "day"), today.add(6, "day")];

        multipleDotDates.forEach(date => {
            cy.get("@markerFlatpickr")
                .getFlatpickrDate(date.toDate())
                .should("have.class", "booking-day--booked");
        });

        // ========================================================================
        // TEST 3: Dates Without Bookings (No Marker Dots)
        // ========================================================================

        const emptyDates = [
            today.add(3, "day"), // Before any bookings
            today.add(8, "day"), // Between booking periods
            today.add(14, "day"), // Day before isolated booking
            today.add(17, "day"), // After all bookings
        ];

        emptyDates.forEach(date => {
            cy.get("@markerFlatpickr")
                .getFlatpickrDate(date.toDate())
                .should("not.have.class", "booking-day--booked")
                .and("not.have.class", "booking-day--partial");
        });

        // ========================================================================
        // TEST 4: Isolated Single Booking (Day 15) - Boundary Detection
        // ========================================================================
        // Only items[0] is booked here too - partial, not fully booked.

        const isolatedBookingDate = today.add(15, "day");

        // Verify isolated booking day HAS marker dot
        cy.get("@markerFlatpickr")
            .getFlatpickrDate(isolatedBookingDate.toDate())
            .should("have.class", "booking-day--partial");

        // Verify adjacent dates DON'T have marker dots
        [today.add(14, "day"), today.add(16, "day")].forEach(adjacentDate => {
            cy.get("@markerFlatpickr")
                .getFlatpickrDate(adjacentDate.toDate())
                .should("not.have.class", "booking-day--booked")
                .and("not.have.class", "booking-day--partial");
        });
    });

    it("should maximize booking window by dynamically reducing available items during overlaps", () => {
        /**
         * Tests the "smart window maximization" algorithm for "any item" bookings.
         *
         * Key principle: Once an item is removed from the pool (becomes unavailable),
         * it is NEVER re-added even if it becomes available again later.
         */

        // Fix the browser Date object to June 10, 2026 at 09:00 Europe/London
        const fixedToday = new Date("2026-06-10T08:00:00Z"); // 09:00 BST (UTC+1)
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

        // Setup: Create biblio with 4 bookable items via the builder
        let testLibrary = null;
        cy.task("insertSampleBiblio", {
            item_count: 4,
            item_values: [0, 1, 2, 3].map(index => ({
                bookable: 1,
                item_type_id: "BK",
                serial_issue_number: String.fromCharCode(65 + index),
                acquisition_date: `2024-12-0${4 - index}`,
            })),
        })
            .then(objects => {
                testBiblio = objects.biblio;
                testItems = objects.items;
                testLibrary = objects.libraries[0];

                return cy.task("insertSamplePatron", {
                    library: testLibrary,
                });
            })
            .then(patronResult => {
                testPatron = patronResult.patron;
            })
            .then(() => {
                // Create strategic bookings sequentially
                const bookings = [
                    { item: testItems[0], start: 10, end: 15 }, // ITEM 0
                    { item: testItems[1], start: 13, end: 20 }, // ITEM 1
                    { item: testItems[2], start: 18, end: 25 }, // ITEM 2
                    { item: testItems[3], start: 1, end: 7 }, // ITEM 3
                    { item: testItems[3], start: 23, end: 30 }, // ITEM 3
                ];
                let chain = cy.wrap(null);
                bookings.forEach(b => {
                    chain = chain.then(() =>
                        cy.task("insertSampleBooking", {
                            item: b.item,
                            patron: testPatron,
                            pickup_library_id: testLibrary.library_id,
                            start_date: today
                                .add(b.start, "day")
                                .startOf("day")
                                .toISOString(),
                            end_date: today
                                .add(b.end, "day")
                                .endOf("day")
                                .toISOString(),
                        })
                    );
                });
                return chain;
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

                cy.get("booking-modal .modal").should("exist");
                cy.get("[data-booking-modal]")
                    .first()
                    .then($btn => $btn[0].click());
                cy.get("booking-modal .modal", {
                    timeout: 10000,
                }).should("be.visible");

                cy.vueSelect(
                    "booking_patron",
                    testPatron.cardnumber,
                    `${testPatron.surname} ${testPatron.firstname}`
                );
                cy.wait("@getPickupLocations");

                cy.vueSelectShouldBeEnabled("pickup_library_id");
                cy.vueSelectByIndex("pickup_library_id", 0);

                // Keep the concrete item clear. The workflow may derive a
                // sole effective type, but type-less Any-item is valid too.
                cy.wait("@getCirculationRules");
                cy.get("#booking_period").should("not.be.disabled");
                cy.get("#booking_period").as("flatpickrInput");

                // Helper to check date availability
                const checkDatesAvailable = (fromDay, toDay) => {
                    const daysToCheck = [fromDay, toDay];
                    if (toDay - fromDay > 1) {
                        // Deterministic midpoint: random probes make
                        // failures unreproducible.
                        daysToCheck.push(
                            fromDay + Math.floor((toDay - fromDay) / 2)
                        );
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
                        // Deterministic midpoint: random probes make
                        // failures unreproducible.
                        daysToCheck.push(
                            fromDay + Math.floor((toDay - fromDay) / 2)
                        );
                    }
                    daysToCheck.forEach(day => {
                        cy.get("@flatpickrInput")
                            .getFlatpickrDate(today.add(day, "day").toDate())
                            .should("have.class", "flatpickr-disabled");
                    });
                };

                // SCENARIO 1: Start day 5
                cy.log("=== Scenario 1: Start day 5 ===");
                cy.get("@flatpickrInput").openFlatpickr();
                cy.get("@flatpickrInput").selectFlatpickrDate(
                    today.add(5, "day").toDate()
                );

                checkDatesAvailable(6, 17);
                checkDatesDisabled(18, 20);

                // SCENARIO 2: Start day 8
                cy.log("=== Scenario 2: Start day 8 (all items available) ===");
                cy.get("@flatpickrInput").clearFlatpickr();
                cy.get("@flatpickrInput").openFlatpickr();
                cy.get("@flatpickrInput").selectFlatpickrDate(
                    today.add(8, "day").toDate()
                );

                checkDatesAvailable(9, 22);
                checkDatesDisabled(23, 25);

                // SCENARIO 3: Start day 19
                cy.log("=== Scenario 3: Start day 19 ===");
                cy.get("@flatpickrInput").clearFlatpickr();
                cy.get("@flatpickrInput").openFlatpickr();
                cy.get("@flatpickrInput").selectFlatpickrDate(
                    today.add(19, "day").toDate()
                );

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
                    patron: testPatron,
                });
            }
        });
    });

    it("should correctly handle lead/trail period conflicts for 'any item' bookings", () => {
        /**
         * Bug 37707: Lead/Trail Period Conflict Detection for "Any Item" Bookings
         */

        // Keep the fixture ahead of the server's real date so availability
        // includes the bookings created below.
        const fixedToday = pinnedToday();
        cy.clock(fixedToday.toDate(), ["Date"]);

        const today = fixedToday.startOf("day");
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

        // Setup: Create biblio with 3 bookable items of the same itemtype (BK)
        cy.task("insertSampleBiblio", {
            item_count: 3,
            item_values: [0, 1, 2].map(index => ({
                bookable: 1,
                item_type_id: "BK",
                serial_issue_number: String.fromCharCode(65 + index),
                acquisition_date: `2024-12-0${4 - index}`,
            })),
        })
            .then(objects => {
                testBiblio = objects.biblio;
                testItems = objects.items;
                testLibraries = objects.libraries;

                return cy.task("insertSamplePatron", {
                    library: testLibraries[0],
                });
            })
            .then(patronResult => {
                testPatron = patronResult.patron;
            })
            .then(() => {
                // Create bookings on ITEM 0 and ITEM 1 for days 10-12
                return cy
                    .task("insertSampleBooking", {
                        item: testItems[0],
                        patron: testPatron,
                        pickup_library_id: testLibraries[0].library_id,
                        start_date: today
                            .add(10, "day")
                            .startOf("day")
                            .toISOString(),
                        end_date: today
                            .add(12, "day")
                            .endOf("day")
                            .toISOString(),
                    })
                    .then(() =>
                        cy.task("insertSampleBooking", {
                            item: testItems[1],
                            patron: testPatron,
                            pickup_library_id: testLibraries[0].library_id,
                            start_date: today
                                .add(10, "day")
                                .startOf("day")
                                .toISOString(),
                            end_date: today
                                .add(12, "day")
                                .endOf("day")
                                .toISOString(),
                        })
                    );
            })
            .then(() => {
                cy.intercept(
                    "GET",
                    `/api/v1/biblios/${testBiblio.biblio_id}/pickup_locations*`
                ).as("getPickupLocations");
                // Booking lead/trail rules support library and item-type
                // scope, not patron-category scope. Keep item type wildcard
                // so this works in both item-level item-type modes.
                cy.task("insertSampleCirculationRules", {
                    library_id: testLibraries[0].library_id,
                    rules: circulationRules,
                }).then(objects => {
                    testData.circulation_rules = objects.circulation_rules;
                });
                cy.intercept("GET", "/api/v1/circulation_rules*", request => {
                    if (
                        request.query.library_id ===
                            testLibraries[0].library_id &&
                        request.query.patron_category_id ===
                            testPatron.category_id
                    ) {
                        request.alias = "getTestCirculationRules";
                    }
                });
                cy.intercept(
                    "GET",
                    `/api/v1/biblios/${testBiblio.biblio_id}/booking_availability*`,
                    request => {
                        if (
                            request.query.pickup_library_id ===
                                testLibraries[0].library_id &&
                            request.query.patron_id ===
                                String(testPatron.patron_id)
                        ) {
                            request.alias = "getTestBookingAvailability";
                        }
                    }
                );

                cy.visit(
                    `/cgi-bin/koha/catalogue/detail.pl?biblionumber=${testBiblio.biblio_id}`
                );

                cy.get("booking-modal .modal").should("exist");
                cy.get("[data-booking-modal]")
                    .first()
                    .then($btn => $btn[0].click());
                cy.get("booking-modal .modal", {
                    timeout: 10000,
                }).should("be.visible");

                cy.vueSelect(
                    "booking_patron",
                    testPatron.cardnumber,
                    `${testPatron.surname} ${testPatron.firstname}`
                );
                cy.wait("@getPickupLocations");

                cy.vueSelectShouldBeEnabled("pickup_library_id");
                cy.vueSelect(
                    "pickup_library_id",
                    testLibraries[0].name,
                    testLibraries[0].name
                );

                // Keep the concrete item clear. The workflow may derive a
                // sole effective type, but type-less Any-item is valid too.
                cy.wait("@getTestCirculationRules");
                cy.wait("@getTestBookingAvailability");
                cy.get("#booking_period").should("not.be.disabled");
                cy.get("#booking_period").as("flatpickrInput");

                // ================================================================
                // SCENARIO 1: Hover day 15 - ITEM 2 is free, should NOT be blocked
                // ================================================================
                cy.log(
                    "=== Scenario 1: Day 15 should be selectable (ITEM 2 is free) ==="
                );

                cy.get("@flatpickrInput").openFlatpickr();
                cy.get("@flatpickrInput").hoverFlatpickrDate(
                    today.add(15, "day").toDate()
                );

                // Day 15 should NOT be disabled (at least one item is free)
                cy.get("@flatpickrInput")
                    .getFlatpickrDate(today.add(15, "day").toDate())
                    .should("not.have.class", "flatpickr-disabled");

                // Actually click day 15 to verify it's selectable
                cy.get("@flatpickrInput").selectFlatpickrDate(
                    today.add(15, "day").toDate()
                );

                // Reset for next scenario
                cy.get("@flatpickrInput").clearFlatpickr();

                // ================================================================
                // SCENARIO 2: Add booking on ITEM 2 - ALL items now have conflicts
                // ================================================================
                cy.log(
                    "=== Scenario 2: Day 15 should be BLOCKED when all items have conflicts ==="
                );

                // Add booking on ITEM 2 for same period (days 10-12)
                cy.task("insertSampleBooking", {
                    item: testItems[2],
                    patron: testPatron,
                    pickup_library_id: testLibraries[0].library_id,
                    start_date: today
                        .add(10, "day")
                        .startOf("day")
                        .toISOString(),
                    end_date: today.add(12, "day").endOf("day").toISOString(),
                }).then(() => {
                    // Use phase-specific aliases so queued requests from the
                    // first modal cannot satisfy the post-update waits.
                    cy.intercept(
                        "GET",
                        "/api/v1/circulation_rules*",
                        request => {
                            if (
                                request.query.library_id ===
                                    testLibraries[0].library_id &&
                                request.query.patron_category_id ===
                                    testPatron.category_id
                            ) {
                                request.alias = "getUpdatedCirculationRules";
                            }
                        }
                    );
                    cy.intercept(
                        "GET",
                        `/api/v1/biblios/${testBiblio.biblio_id}/booking_availability*`,
                        request => {
                            if (
                                request.query.pickup_library_id ===
                                    testLibraries[0].library_id &&
                                request.query.patron_id ===
                                    String(testPatron.patron_id)
                            ) {
                                request.alias = "getUpdatedBookingAvailability";
                            }
                        }
                    );

                    // A full page load replaces the patched Date constructor.
                    cy.clock(fixedToday.toDate(), ["Date"]);
                    cy.visit(
                        `/cgi-bin/koha/catalogue/detail.pl?biblionumber=${testBiblio.biblio_id}`
                    );

                    cy.get("booking-modal .modal").should("exist");
                    cy.get("[data-booking-modal]")
                        .first()
                        .then($btn => $btn[0].click());
                    cy.get("booking-modal .modal", {
                        timeout: 10000,
                    }).should("be.visible");

                    cy.vueSelect(
                        "booking_patron",
                        testPatron.cardnumber,
                        `${testPatron.surname} ${testPatron.firstname}`
                    );
                    cy.wait("@getPickupLocations");

                    cy.vueSelectShouldBeEnabled("pickup_library_id");
                    cy.vueSelect(
                        "pickup_library_id",
                        testLibraries[0].name,
                        testLibraries[0].name
                    );

                    // Keep the concrete item clear. The workflow may derive a
                    // sole effective type, but type-less Any-item is valid too.
                    cy.wait("@getUpdatedCirculationRules").then(
                        ({ request, response }) => {
                            expect(
                                request.query.library_id,
                                "rules library context"
                            ).to.equal(testLibraries[0].library_id);
                            expect(
                                request.query.patron_category_id,
                                "rules patron-category context"
                            ).to.equal(testPatron.category_id);
                            expect(
                                Number(
                                    response?.body?.[0]?.bookings_lead_period
                                ),
                                "effective lead period"
                            ).to.equal(2);
                            expect(
                                Number(
                                    response?.body?.[0]?.bookings_trail_period
                                ),
                                "effective trail period"
                            ).to.equal(2);
                        }
                    );
                    cy.wait("@getUpdatedBookingAvailability").then(
                        ({ response }) => {
                            for (const offset of [13, 14]) {
                                const date = today
                                    .add(offset, "day")
                                    .format("YYYY-MM-DD");
                                for (const item of testItems) {
                                    expect(
                                        response?.body?.availability?.[date]?.[
                                            String(item.item_id)
                                        ]?.blockers?.trail,
                                        `trail blocker for item ${item.item_id} on ${date}`
                                    ).to.equal(1);
                                }
                            }
                        }
                    );
                    cy.get("#booking_period").should("not.be.disabled");
                    cy.get("#booking_period").as("flatpickrInput2");

                    cy.get("@flatpickrInput2").openFlatpickr();
                    cy.get("@flatpickrInput2").hoverFlatpickrDate(
                        today.add(15, "day").toDate()
                    );

                    // Day 15 should NOW be disabled (all items have conflicts)
                    cy.get("@flatpickrInput2")
                        .getFlatpickrDate(today.add(15, "day").toDate())
                        .should("have.class", "flatpickr-disabled");

                    // ================================================================
                    // SCENARIO 3: Visual feedback - trail period hover classes
                    // ================================================================
                    cy.log(
                        "=== Scenario 3: Visual feedback - Trail period hover classes ==="
                    );

                    // Hover a date whose trail overlaps with bookings
                    // Day 13 is the closest adjacent trail day, so hovering
                    // it (or the gap it sits in) colours it in
                    cy.get("@flatpickrInput2").hoverFlatpickrDate(
                        today.add(13, "day").toDate()
                    );
                    cy.get("@flatpickrInput2")
                        .getFlatpickrDate(today.add(13, "day").toDate())
                        .should(
                            "have.class",
                            "booking-day--existing-trail-adjacent"
                        );

                    // ================================================================
                    // SCENARIO 4: Visual feedback - lead period hover classes
                    // ================================================================
                    cy.log(
                        "=== Scenario 4: Visual feedback - Lead period hover classes ==="
                    );

                    // Hover a date whose lead period overlaps with bookings
                    cy.get("@flatpickrInput2").hoverFlatpickrDate(
                        today.add(8, "day").toDate()
                    );
                    cy.get("@flatpickrInput2")
                        .getFlatpickrDate(today.add(8, "day").toDate())
                        .should(
                            "have.class",
                            "booking-day--existing-lead-adjacent"
                        );
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
                    patron: testPatron,
                });
            }
        });
    });
});
