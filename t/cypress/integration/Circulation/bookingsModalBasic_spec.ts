import dayjs from "dayjs";

describe("Booking Modal Basic Tests", () => {
    let testData = {};

    beforeEach(() => {
        // The booking calendar now renders inline (always visible,
        // two months) instead of a popup, making the modal taller than
        // Cypress's 660px default viewport height - a real browser on
        // any normal-height screen handles the resulting nested-scroll
        // (outer .modal + .modal-body, both overflow-y: auto) without
        // issue, but Cypress's own scrollIntoView() does not reliably
        // walk that chain under a position: fixed ancestor.
        cy.viewport(1280, 1600);
        cy.login();
        cy.title().should("eq", "Koha staff interface");

        // Create fresh test data for each test using upstream pattern;
        // items are born bookable with distinct item types via the builder.
        cy.task("insertSampleBiblio", {
            item_count: 3,
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
                {
                    bookable: 1,
                    item_type_id: "BK",
                    serial_issue_number: "C",
                    acquisition_date: "2024-12-01",
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

    it("should load the booking modal correctly with initial state", () => {
        // Visit the biblio detail page with our freshly created data
        cy.visit(
            `/cgi-bin/koha/catalogue/detail.pl?biblionumber=${testData.biblio.biblio_id}`
        );

        // Wait for page to load completely
        cy.get("#catalog_detail").should("be.visible");

        // The "Place booking" button should appear for bookable items
        cy.get("[data-booking-modal]").should("exist").and("be.visible");

        // Click to open the booking modal
        cy.get("booking-modal .modal").should("exist");
        cy.get("[data-booking-modal]")
            .first()
            .then($btn => $btn[0].click());

        // Wait for modal to appear
        cy.get("booking-modal .modal", { timeout: 10000 }).should("be.visible");
        cy.get("booking-modal .modal-title")
            .should("be.visible")
            .and("contain.text", "Place booking");

        // Verify modal structure and initial field states
        // Patron field should be enabled
        cy.vueSelectShouldBeEnabled("booking_patron");

        // Pickup library should be disabled initially
        cy.vueSelectShouldBeDisabled("pickup_library_id");

        // Item type should be disabled initially
        cy.vueSelectShouldBeDisabled("booking_itemtype");

        // Item should be disabled initially
        cy.vueSelectShouldBeDisabled("booking_item_id");

        // Period should show the not-ready placeholder initially, not a
        // disabled picker - the picker itself stays mounted (v-show, not
        // v-if) so Flatpickr's instance is never torn down and rebuilt as
        // calendarEnabled flips true/false while upstream selections load
        cy.get("#booking_period").should("not.be.visible");
        cy.get(".booking-calendar-placeholder").should("be.visible");

        // Verify form and submit button exist
        cy.get('button[form="form-booking"][type="submit"]').should("exist");

        cy.get(".btn-close").should("exist");
    });

    it("should enable fields progressively based on user selections", () => {
        // Setup API intercepts to wait for real API calls instead of arbitrary timeouts
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

        // Step 1: Initially only patron field should be enabled
        cy.vueSelectShouldBeEnabled("booking_patron");
        cy.vueSelectShouldBeDisabled("pickup_library_id");
        cy.vueSelectShouldBeDisabled("booking_itemtype");
        cy.vueSelectShouldBeDisabled("booking_item_id");
        cy.get(".booking-calendar-placeholder").should("be.visible");

        // Step 2: Select patron - this triggers pickup locations API call
        cy.vueSelect(
            "booking_patron",
            testData.patron.cardnumber,
            `${testData.patron.surname}, ${testData.patron.preferred_name}`
        );

        // Wait for pickup locations API call to complete
        cy.wait("@getPickupLocations");

        // Step 3: After patron selection and pickup locations load, other fields should become enabled
        cy.vueSelectShouldBeEnabled("pickup_library_id");
        cy.vueSelectShouldBeEnabled("booking_itemtype");
        cy.vueSelectShouldBeEnabled("booking_item_id");

        // Wait for circulation rules API call to complete
        cy.wait("@getCirculationRules");

        // "Any item" is a valid default — period enables without requiring
        // a specific item type or item selection
        cy.get("#booking_period").should("not.be.disabled");

        // Step 4: Select pickup location
        cy.vueSelectByIndex("pickup_library_id", 0);

        // Step 5: The workflow may apply the sole valid item type after the
        // pickup selection. Item-type selection itself is covered by the
        // dependency test below; verify this context remains calendar-ready.
        cy.get("#booking_period").should("not.be.disabled");

        // Step 6: Clearing item type keeps period enabled ("any item" still valid)
        cy.vueSelectClear("booking_itemtype");
        cy.get("#booking_period").should("not.be.disabled");

        // Step 7: Select item instead of itemtype
        cy.vueSelectByIndex("booking_item_id", 1);

        // Period stays enabled after item selection
        cy.get("#booking_period").should("not.be.disabled");
    });

    it("should handle item type and item dependencies correctly", () => {
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

        // Setup: Select patron and pickup location first
        cy.vueSelect(
            "booking_patron",
            testData.patron.cardnumber,
            `${testData.patron.surname}, ${testData.patron.preferred_name}`
        );
        cy.wait("@getPickupLocations");

        cy.vueSelectShouldBeEnabled("pickup_library_id");
        cy.vueSelectByIndex("pickup_library_id", 0);

        // Test Case 1: Select an item first → auto-populate its item type
        cy.vueSelectByIndex("booking_item_id", 1);
        cy.wait("@getCirculationRules");

        // Verify that item type gets auto-populated (value depends on which item the API returns first)
        cy.get("input#booking_itemtype")
            .closest(".v-select")
            .find(".vs__selected")
            .should("exist");

        // Verify that period field gets enabled after item selection
        cy.get("#booking_period").should("not.be.disabled");

        // Test Case 2: Reset the item selection to "Any item". The
        // item-derived type remains a valid explicit constraint.
        cy.vueSelectClear("booking_item_id");
        cy.wait("@getCirculationRules");
        cy.vueSelectShouldBeEnabled("booking_itemtype");
        cy.vueSelectShouldBeEnabled("booking_item_id");
        cy.get("#booking_period").should("not.be.disabled");

        // Test Case 3: Clear the type as well. A type-less "Any item"
        // context remains valid and exposes the unconstrained item options.
        cy.vueSelectClear("booking_itemtype");
        cy.wait("@getCirculationRules");
        cy.vueSelectShouldBeEnabled("booking_itemtype");
        cy.vueSelectShouldBeEnabled("booking_item_id");
        cy.get("#booking_period").should("not.be.disabled");

        cy.get("input#booking_item_id")
            .closest(".v-select")
            .find(".vs__dropdown-toggle")
            .click();
        cy.get("input#booking_item_id")
            .closest(".v-select")
            .find(".vs__dropdown-menu")
            .should("be.visible")
            .find(".vs__dropdown-option")
            .should("have.length.at.least", 2);
        cy.get("booking-modal .modal-title").click();

        // Test Case 4: Selecting another concrete item derives its type.
        cy.vueSelectByIndex("booking_item_id", 1);
        cy.wait("@getCirculationRules");
        cy.get("input#booking_itemtype")
            .closest(".v-select")
            .find(".vs__selected")
            .should("exist");
        cy.get("#booking_period").should("not.be.disabled");
    });

    it("should handle form validation correctly", () => {
        cy.visit(
            `/cgi-bin/koha/catalogue/detail.pl?biblionumber=${testData.biblio.biblio_id}`
        );

        // Open the modal
        cy.get("booking-modal .modal").should("exist");
        cy.get("[data-booking-modal]")
            .first()
            .then($btn => $btn[0].click());
        cy.get("booking-modal .modal", { timeout: 10000 }).should("be.visible");

        // Submit button should be disabled without required fields
        cy.get('button[form="form-booking"][type="submit"]').should(
            "be.disabled"
        );

        // Modal should still be visible
        cy.get("booking-modal .modal").should("be.visible");
    });

    it("should successfully submit a booking", () => {
        cy.visit(
            `/cgi-bin/koha/catalogue/detail.pl?biblionumber=${testData.biblio.biblio_id}`
        );

        // Open the modal
        cy.get("booking-modal .modal").should("exist");
        cy.get("[data-booking-modal]")
            .first()
            .then($btn => $btn[0].click());
        cy.get("booking-modal .modal", { timeout: 10000 }).should("be.visible");

        // Fill in the form using real data from the database

        // Step 1: Select patron
        cy.vueSelect(
            "booking_patron",
            testData.patron.cardnumber,
            `${testData.patron.surname}, ${testData.patron.preferred_name}`
        );

        // Step 2: Select pickup location
        cy.vueSelectShouldBeEnabled("pickup_library_id");
        cy.vueSelectByIndex("pickup_library_id", 0);

        // Step 3: Select a concrete bookable item
        cy.vueSelectShouldBeEnabled("booking_item_id");
        cy.vueSelectByIndex("booking_item_id", 1);

        // Step 4: Set dates using flatpickr
        cy.get("#booking_period").should("not.be.disabled");

        // Use the flatpickr helper to select date range
        // Note: Add enough days to account for lead period (3 days) to avoid past-date constraint
        const startDate = dayjs().add(5, "day");
        const endDate = dayjs().add(10, "days");

        cy.get("#booking_period").selectFlatpickrDateRange(startDate, endDate);

        // Step 5: Submit the form
        cy.get('button[form="form-booking"][type="submit"]')
            .should("not.be.disabled")
            .click();

        // Verify success - either success message or modal closure
        cy.get("booking-modal .modal", { timeout: 10000 }).should(
            "not.be.visible"
        );
    });

    it("should successfully submit an 'Any item' booking with server-side optimal item selection", () => {
        /**
         * TEST: Bug 40134 - Server-Side Optimal Item Selection for "Any Item" Bookings
         *
         * This test validates that:
         * 1. "Any item" bookings can be successfully submitted with itemtype_id
         * 2. The server performs optimal item selection based on future availability
         * 3. An appropriate item is automatically assigned by the server
         */

        // Fix the browser Date object to June 10, 2026 at 09:00 Europe/London
        // Using ["Date"] to avoid freezing timers which breaks async operations
        const fixedToday = new Date("2026-06-10T08:00:00Z"); // 09:00 BST (UTC+1)
        cy.clock(fixedToday, ["Date"]);

        // Define fixed dates for consistent testing
        const startDate = dayjs("2026-06-15"); // 5 days from fixed today
        const endDate = dayjs("2026-06-20"); // 10 days from fixed today
        cy.intercept("POST", "/api/v1/bookings").as("createAnyItemBooking");

        cy.visit(
            `/cgi-bin/koha/catalogue/detail.pl?biblionumber=${testData.biblio.biblio_id}`
        );

        // Open the modal
        cy.get("booking-modal .modal").should("exist");
        cy.get("[data-booking-modal]")
            .first()
            .then($btn => $btn[0].click());
        cy.get("booking-modal .modal", { timeout: 10000 }).should("be.visible");

        // Step 1: Select patron
        cy.vueSelect(
            "booking_patron",
            testData.patron.cardnumber,
            `${testData.patron.surname}, ${testData.patron.preferred_name}`
        );

        // Step 2: Keep the patron-library pickup default selected. Choosing
        // an arbitrary first location is unstable because that location may
        // not accept any of this biblio's items.
        cy.vueSelectShouldBeEnabled("pickup_library_id");
        cy.get("input#pickup_library_id")
            .closest(".v-select")
            .find(".vs__selected")
            .should("exist");

        // Step 3: Derive a valid item type from a concrete pickable item.
        cy.vueSelectShouldBeEnabled("booking_item_id");
        cy.vueSelectByIndex("booking_item_id", 0);
        cy.get("input#booking_itemtype")
            .closest(".v-select")
            .find(".vs__selected")
            .should("exist");

        // Step 4: Clear the item while retaining its type, producing the
        // type-constrained "Any item" payload this test exercises.
        cy.vueSelectClear("booking_item_id");
        cy.get("input#booking_item_id")
            .closest(".v-select")
            .find(".vs__selected")
            .should("not.exist");
        cy.get("input#booking_itemtype")
            .closest(".v-select")
            .find(".vs__selected")
            .should("exist");

        // Step 5: Set dates using flatpickr
        cy.get("#booking_period").should("not.be.disabled");

        cy.get("#booking_period").selectFlatpickrDateRange(startDate, endDate);

        // Step 6: Submit the form. The retrying not.be.disabled assertion
        // waits for the onChange handlers to finish processing.
        cy.get('button[form="form-booking"][type="submit"]')
            .should("not.be.disabled")
            .click();

        cy.wait("@createAnyItemBooking").then(({ request, response }) => {
            expect(response.statusCode).to.be.oneOf([200, 201]);
            expect(request.body.item_id).to.equal(undefined);
            expect(request.body.itemtype_id).to.not.equal(undefined);
        });
        cy.get("booking-modal .modal", { timeout: 10000 }).should(
            "not.be.visible"
        );

        // Verify that a booking was created and the server assigned an optimal item
        cy.task("query", {
            sql: `SELECT * FROM bookings
                  WHERE biblio_id = ?
                  AND patron_id = ?
                  AND start_date = ?
                  ORDER BY booking_id DESC
                  LIMIT 1`,
            values: [
                testData.biblio.biblio_id,
                testData.patron.patron_id,
                "2026-06-15", // Fixed start date
            ],
        }).then(result => {
            expect(result).to.have.length(1);
            const booking = result[0];

            // Verify the booking has an item_id assigned (not null)
            expect(booking.item_id).to.not.equal(null);
            expect(booking.item_id).to.be.oneOf([
                testData.items[0].item_id,
                testData.items[1].item_id,
            ]);

            // Verify booking dates match what we selected
            expect(booking.start_date).to.include("2026-06-15");
            expect(booking.end_date).to.include("2026-06-20");

            // Clean up the test booking
            cy.task("query", {
                sql: "DELETE FROM bookings WHERE booking_id = ?",
                values: [booking.booking_id],
            });
        });
    });

    it("should handle basic form interactions correctly", () => {
        cy.visit(
            `/cgi-bin/koha/catalogue/detail.pl?biblionumber=${testData.biblio.biblio_id}`
        );

        // Open the modal
        cy.get("booking-modal .modal").should("exist");
        cy.get("[data-booking-modal]")
            .first()
            .then($btn => $btn[0].click());
        cy.get("booking-modal .modal", { timeout: 10000 }).should("be.visible");

        // Test basic form interactions without complex flatpickr scenarios

        // Step 1: Select patron
        cy.vueSelect(
            "booking_patron",
            testData.patron.cardnumber,
            `${testData.patron.surname}, ${testData.patron.preferred_name}`
        );

        // Step 2: Select pickup location
        cy.vueSelectShouldBeEnabled("pickup_library_id");
        cy.vueSelectByIndex("pickup_library_id", 0);

        // Step 3: Select a concrete item
        cy.vueSelectShouldBeEnabled("booking_item_id");
        cy.vueSelectByIndex("booking_item_id", 1);

        // Step 4: Verify period field becomes enabled
        cy.get("#booking_period").should("not.be.disabled");

        // Step 5: Verify we can close the modal
        cy.get("booking-modal .modal .btn-close").first().click();
        cy.get("booking-modal .modal").should("not.be.visible");
    });

    it("should handle date selection and API submission correctly", () => {
        /**
         * Date Selection and API Submission Test
         * =======================================
         *
         * In the Vue version, there are no hidden fields for dates.
         * Instead, dates are stored in the pinia store and sent via API.
         * We verify dates via API intercept body assertions.
         */

        // Set up API intercepts
        cy.intercept(
            "GET",
            `/api/v1/biblios/${testData.biblio.biblio_id}/pickup_locations*`
        ).as("getPickupLocations");
        cy.intercept("GET", "/api/v1/circulation_rules*").as(
            "getCirculationRules"
        );
        cy.intercept("POST", "/api/v1/bookings").as("createBooking");

        // Visit the page and open booking modal
        cy.visit(
            `/cgi-bin/koha/catalogue/detail.pl?biblionumber=${testData.biblio.biblio_id}`
        );

        // Open booking modal
        cy.get("booking-modal .modal").should("exist");
        cy.get("[data-booking-modal]")
            .first()
            .then($btn => $btn[0].click());
        cy.get("booking-modal .modal", { timeout: 10000 }).should("be.visible");

        // Fill required fields progressively
        cy.vueSelect(
            "booking_patron",
            testData.patron.cardnumber,
            `${testData.patron.surname}, ${testData.patron.preferred_name}`
        );
        cy.wait("@getPickupLocations");

        cy.vueSelectShouldBeEnabled("pickup_library_id");
        cy.vueSelectByIndex("pickup_library_id", 0);

        cy.vueSelectShouldBeEnabled("booking_item_id");
        cy.vueSelectByIndex("booking_item_id", 1); // Select a concrete item
        cy.wait("@getCirculationRules");

        // Verify date picker is enabled
        cy.get("#booking_period").should("not.be.disabled");

        // Define test dates
        const startDate = dayjs().add(3, "day");
        const endDate = dayjs().add(6, "day");

        // Select date range in flatpickr
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

        // Verify the period field is populated
        cy.get("#booking_period").should("exist").and("not.have.value", "");

        cy.get('button[form="form-booking"][type="submit"]')
            .should("not.be.disabled")
            .click();

        // Submitting sends the selected range to the API; the payload carries
        // each calendar date as a library-timezone day-boundary ISO string.
        cy.wait("@createBooking").then(({ request, response }) => {
            expect(response.statusCode, "create succeeds").to.be.oneOf([
                200, 201,
            ]);
            expect(request.body.start_date).to.include(
                startDate.format("YYYY-MM-DD")
            );
            expect(request.body.end_date).to.include(
                endDate.format("YYYY-MM-DD")
            );
        });
        cy.get("booking-modal .modal").should("not.be.visible");
    });

    it("should edit an existing booking successfully", () => {
        /**
         * Booking Edit Functionality Test
         * ==============================
         *
         * In the Vue version, edit mode is triggered by setting properties
         * on the booking-modal element via window.openBookingModal().
         */

        const today = dayjs().startOf("day");

        // Create an existing booking to edit using the shared test data
        const originalStartDate = today.add(10, "day");
        const originalEndDate = originalStartDate.add(3, "day");

        cy.then(() => {
            return cy.task("insertSampleBooking", {
                item: testData.items[0],
                patron: testData.patron,
                pickup_library_id: testData.libraries[0].library_id,
                start_date: originalStartDate.toISOString(),
                end_date: originalEndDate.toISOString(),
            });
        }).then(({ booking }) => {
            // Store the booking for editing; the `booking` key is picked up
            // by deleteSampleObjects for cleanup.
            testData.existingBooking = {
                booking_id: booking.booking_id,
                start_date: originalStartDate.startOf("day").toISOString(),
                end_date: originalEndDate.endOf("day").toISOString(),
            };
            testData.booking = booking;
        });

        // Use real API calls for all booking operations since we created real database data
        // Only mock checkouts if it causes JavaScript errors
        cy.intercept("GET", "/api/v1/checkouts*", { body: [] }).as(
            "getCheckouts"
        );

        // Intercept the patron fetch so we can wait for pre-population
        cy.intercept("GET", "/api/v1/patrons/*").as("getPatron");

        // Visit the page
        cy.visit(
            `/cgi-bin/koha/catalogue/detail.pl?biblionumber=${testData.biblio.biblio_id}`
        );
        cy.title().should("contain", "Koha");

        // Open edit modal by calling window.openBookingModal with booking properties
        cy.get("booking-modal .modal").should("exist");
        cy.then(() => {
            cy.window().then(win => {
                win.openBookingModal({
                    booking: testData.existingBooking.booking_id.toString(),
                    patron: testData.patron.patron_id.toString(),
                    itemnumber: testData.items[0].item_id.toString(),
                    pickup_library: testData.libraries[0].library_id,
                    start_date: testData.existingBooking.start_date,
                    end_date: testData.existingBooking.end_date,
                    biblionumber: testData.biblio.biblio_id.toString(),
                });
            });
        });

        // Wait for the patron fetch to complete before checking pre-populated fields
        cy.wait("@getPatron");

        // Verify edit modal setup
        cy.get("booking-modal .modal", { timeout: 10000 }).should("be.visible");
        cy.get("booking-modal .modal-title").should("contain", "Edit booking");

        // Verify core edit fields are pre-populated with display values,
        // not the raw IDs supplied through data attributes.
        cy.vueSelectShouldHaveValue("booking_patron", testData.patron.surname);
        cy.vueSelectShouldHaveValue(
            "booking_item_id",
            String(testData.items[0].external_id)
        );
        cy.get("#booking_period")
            .should("not.have.value", "")
            .and($input => {
                expect($input[0]._flatpickr.selectedDates).to.have.length(2);
            });

        // Wildcard match: the booking id is only known inside the async
        // insertSampleBooking callback above.
        cy.intercept("PUT", "/api/v1/bookings/*").as("updateBooking");

        cy.get("booking-modal .modal .btn-primary")
            .should("not.be.disabled")
            .click();

        // Editing through the modal must round-trip to the API and close it.
        cy.wait("@updateBooking").its("response.statusCode").should("eq", 200);
        cy.get("booking-modal .modal").should("not.be.visible");
    });

    it("should refresh edit modal state across consecutive openings", () => {
        const today = dayjs().startOf("day");
        let secondPatron;
        let firstBookingId;
        let secondBookingId;

        const firstBooking = {
            start: today.add(8, "day"),
            end: today.add(10, "day"),
            patron_id: testData.patron.patron_id,
            patron_label: testData.patron.surname,
        };

        cy.task("insertSamplePatron", {
            library: { library_id: testData.libraries[0].library_id },
        }).then(patronResult => {
            secondPatron = patronResult.patron;
            testData.patrons = testData.patrons || [];
            testData.patrons.push(secondPatron);
        });

        cy.then(() =>
            cy
                .task("insertSampleBooking", {
                    item: testData.items[0],
                    patron: testData.patron,
                    pickup_library_id: testData.libraries[0].library_id,
                    start_date: firstBooking.start.toISOString(),
                    end_date: firstBooking.end.toISOString(),
                })
                .then(({ booking }) => {
                    firstBookingId = booking.booking_id;
                    testData.bookings = testData.bookings || [];
                    testData.bookings.push(booking);
                })
        );

        cy.then(() => {
            const secondBooking = {
                start: today.add(15, "day"),
                end: today.add(17, "day"),
                patron_id: secondPatron.patron_id,
                patron_label: secondPatron.surname,
            };

            return cy
                .task("insertSampleBooking", {
                    item: testData.items[1],
                    patron: secondPatron,
                    pickup_library_id: testData.libraries[0].library_id,
                    start_date: secondBooking.start.toISOString(),
                    end_date: secondBooking.end.toISOString(),
                })
                .then(({ booking }) => {
                    secondBookingId = booking.booking_id;
                    testData.bookings = testData.bookings || [];
                    testData.bookings.push(booking);
                })
                .then(() => secondBooking);
        }).then(secondBooking => {
            // Intercept patron fetches so we can wait for pre-population
            cy.intercept("GET", "/api/v1/patrons/*").as("getPatron");

            cy.visit(
                `/cgi-bin/koha/catalogue/detail.pl?biblionumber=${testData.biblio.biblio_id}`
            );
            cy.get("booking-modal .modal").should("exist");

            // First open: booking A
            cy.window().then(win => {
                win.openBookingModal({
                    booking: String(firstBookingId),
                    patron: String(firstBooking.patron_id),
                    itemnumber: String(testData.items[0].item_id),
                    pickup_library: testData.libraries[0].library_id,
                    start_date: firstBooking.start.startOf("day").toISOString(),
                    end_date: firstBooking.end.endOf("day").toISOString(),
                    biblionumber: String(testData.biblio.biblio_id),
                });
            });

            cy.wait("@getPatron");
            cy.get("booking-modal .modal", { timeout: 10000 }).should(
                "be.visible"
            );
            cy.vueSelectShouldHaveValue(
                "booking_patron",
                firstBooking.patron_label
            );

            cy.get("booking-modal .modal .btn-close").first().click();
            cy.get("booking-modal .modal").should("not.be.visible");
            cy.get("body").should("not.have.class", "modal-open");

            // Second open: booking B (must not stay stale with booking A data)
            cy.window().then(win => {
                win.openBookingModal({
                    booking: String(secondBookingId),
                    patron: String(secondBooking.patron_id),
                    itemnumber: String(testData.items[1].item_id),
                    pickup_library: testData.libraries[0].library_id,
                    start_date: secondBooking.start
                        .startOf("day")
                        .toISOString(),
                    end_date: secondBooking.end.endOf("day").toISOString(),
                    biblionumber: String(testData.biblio.biblio_id),
                });
            });

            cy.wait("@getPatron");
            cy.get("booking-modal .modal", { timeout: 10000 }).should(
                "be.visible"
            );
            cy.vueSelectShouldHaveValue(
                "booking_patron",
                secondBooking.patron_label
            );
        });
    });

    it("should handle booking failure gracefully", () => {
        /**
         * Comprehensive Error Handling and Recovery Test
         */

        const today = dayjs().startOf("day");

        const primaryErrorScenario = {
            name: "Validation Error (400)",
            statusCode: 400,
            body: {
                error: "Invalid booking period",
                errors: [
                    {
                        message: "End date must be after start date",
                        path: "/end_date",
                    },
                ],
            },
        };

        // Setup API intercepts for error testing
        cy.intercept(
            "GET",
            `/api/v1/biblios/${testData.biblio.biblio_id}/pickup_locations*`
        ).as("getPickupLocations");
        cy.intercept("GET", "/api/v1/circulation_rules*", {
            body: [
                {
                    branchcode: testData.libraries[0].library_id,
                    categorycode: "PT",
                    itemtype: "BK",
                    issuelength: 14,
                    renewalsallowed: 2,
                    renewalperiod: 7,
                },
            ],
        }).as("getCirculationRules");

        // Setup failed booking API response
        cy.intercept("POST", "/api/v1/bookings", {
            statusCode: primaryErrorScenario.statusCode,
            body: primaryErrorScenario.body,
        }).as("failedBooking");

        // Visit the page and open booking modal
        cy.visit(
            `/cgi-bin/koha/catalogue/detail.pl?biblionumber=${testData.biblio.biblio_id}`
        );
        cy.get("booking-modal .modal").should("exist");
        cy.get("[data-booking-modal]")
            .first()
            .then($btn => $btn[0].click());
        cy.get("booking-modal .modal", { timeout: 10000 }).should("be.visible");

        // PHASE 1: Complete Booking Form with Valid Data
        cy.log("=== PHASE 1: Filling booking form with valid data ===");

        // Step 1: Select patron
        cy.vueSelect(
            "booking_patron",
            testData.patron.cardnumber,
            `${testData.patron.surname}, ${testData.patron.preferred_name}`
        );
        cy.wait("@getPickupLocations");

        // Step 2: Select pickup location
        cy.vueSelectShouldBeEnabled("pickup_library_id");
        cy.vueSelectByIndex("pickup_library_id", 0);

        // Step 3: Select a concrete item (triggers circulation rules)
        cy.vueSelectShouldBeEnabled("booking_item_id");
        cy.vueSelectByIndex("booking_item_id", 1);
        cy.wait("@getCirculationRules");

        // Step 4: Set booking dates
        cy.get("#booking_period").should("not.be.disabled");
        const startDate = today.add(7, "day");
        const endDate = today.add(10, "day");
        cy.get("#booking_period").selectFlatpickrDateRange(startDate, endDate);

        // PHASE 2: Submit Form and Trigger Error Response
        cy.log(
            "=== PHASE 2: Submitting form and triggering error response ==="
        );

        // Submit the form and trigger the error
        cy.get('button[form="form-booking"][type="submit"]').click();
        cy.wait("@failedBooking");

        // PHASE 3: Validate Error Handling Behavior
        cy.log("=== PHASE 3: Validating error handling behavior ===");

        // Verify error feedback is displayed (Vue uses .alert-danger within the modal)
        cy.get("booking-modal .modal .alert-danger").should("exist");

        // Verify modal remains open on error (allows user to retry)
        cy.get("booking-modal .modal").should("be.visible");

        // PHASE 4: Test Error Recovery (Successful Retry)
        cy.log("=== PHASE 4: Testing error recovery workflow ===");

        // Setup successful booking intercept for retry attempt
        cy.intercept("POST", "/api/v1/bookings", {
            statusCode: 201,
            body: {
                booking_id: 9002,
                patron_id: testData.patron.patron_id.toString(),
                item_id: testData.items[0].item_id.toString(),
                pickup_library_id: testData.libraries[0].library_id,
                start_date: startDate.startOf("day").toISOString(),
                end_date: endDate.endOf("day").toISOString(),
                biblio_id: testData.biblio.biblio_id,
            },
        }).as("successfulRetry");

        // Retry the submission (same form, no changes needed)
        cy.get('button[form="form-booking"][type="submit"]').click();
        cy.wait("@successfulRetry");

        // Verify successful retry behavior
        cy.get("booking-modal .modal").should("not.be.visible");

        // The page listener handles the island's booking-saved event.
        cy.get("#transient_result").should(
            "contain",
            "Booking successfully placed"
        );
    });

    it("should reset modal state after canceling", () => {
        cy.visit(
            `/cgi-bin/koha/catalogue/detail.pl?biblionumber=${testData.biblio.biblio_id}`
        );

        cy.get("booking-modal .modal").should("exist");
        cy.get("[data-booking-modal]")
            .first()
            .then($btn => $btn[0].click());
        cy.get("booking-modal .modal", { timeout: 10000 }).should("be.visible");

        // Fill some fields
        cy.vueSelect(
            "booking_patron",
            testData.patron.cardnumber,
            `${testData.patron.surname}, ${testData.patron.preferred_name}`
        );
        cy.vueSelectShouldBeEnabled("pickup_library_id");
        cy.vueSelectByIndex("pickup_library_id", 0);

        // Close modal and wait for Bootstrap transition to fully complete
        cy.get("booking-modal .modal .btn-close").first().click();
        cy.get("booking-modal .modal").should("not.be.visible");
        cy.get("body").should("not.have.class", "modal-open");

        // Reopen and verify state is reset
        cy.get("[data-booking-modal]")
            .first()
            .then($btn => $btn[0].click());
        cy.get("booking-modal .modal.show", { timeout: 10000 }).should(
            "be.visible"
        );

        cy.vueSelectShouldBeEnabled("booking_patron");
        cy.vueSelectShouldBeDisabled("pickup_library_id");
        cy.vueSelectShouldBeDisabled("booking_itemtype");
        cy.vueSelectShouldBeDisabled("booking_item_id");
        cy.get(".booking-calendar-placeholder").should("be.visible");
        cy.get('button[form="form-booking"][type="submit"]').should(
            "be.disabled"
        );
    });

    it("should show capacity warning for zero-day circulation rules", () => {
        cy.intercept(
            "GET",
            `/api/v1/biblios/${testData.biblio.biblio_id}/pickup_locations*`
        ).as("getPickupLocations");
        cy.intercept("GET", "/api/v1/circulation_rules*", {
            body: [
                {
                    library_id: testData.libraries[0].library_id,
                    item_type_id: "BK",
                    patron_category_id: testData.patron.category_id,
                    issuelength: 0,
                    renewalsallowed: 0,
                    renewalperiod: 0,
                    bookings_lead_period: 0,
                    bookings_trail_period: 0,
                    calculated_period_days: 0,
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
            `${testData.patron.surname}, ${testData.patron.preferred_name}`
        );
        cy.wait("@getPickupLocations");

        cy.vueSelectShouldBeEnabled("pickup_library_id");
        cy.vueSelectByIndex("pickup_library_id", 0);

        cy.vueSelectShouldBeEnabled("booking_item_id");
        cy.vueSelectByIndex("booking_item_id", 1);
        cy.wait("@getCirculationRules");

        cy.get("booking-modal .modal .alert-warning")
            .scrollIntoView()
            .should("be.visible")
            .and("contain", "Bookings are not permitted");
        cy.get(".booking-calendar-placeholder").should("be.visible");
        cy.get('button[form="form-booking"][type="submit"]').should(
            "be.disabled"
        );
    });

    it("should show error on 409 conflict response", () => {
        cy.intercept(
            "GET",
            `/api/v1/biblios/${testData.biblio.biblio_id}/pickup_locations*`
        ).as("getPickupLocations");
        cy.intercept("GET", "/api/v1/circulation_rules*").as(
            "getCirculationRules"
        );
        cy.intercept("POST", "/api/v1/bookings", {
            statusCode: 409,
            body: { error: "Booking conflict detected" },
        }).as("conflictBooking");

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
            `${testData.patron.surname}, ${testData.patron.preferred_name}`
        );
        cy.wait("@getPickupLocations");

        cy.vueSelectShouldBeEnabled("pickup_library_id");
        cy.vueSelectByIndex("pickup_library_id", 0);

        cy.vueSelectShouldBeEnabled("booking_item_id");
        cy.vueSelectByIndex("booking_item_id", 1);
        cy.wait("@getCirculationRules");

        cy.get("#booking_period").should("not.be.disabled");
        const startDate = dayjs().add(5, "day");
        const endDate = dayjs().add(10, "day");
        cy.get("#booking_period").selectFlatpickrDateRange(startDate, endDate);

        cy.get('button[form="form-booking"][type="submit"]')
            .should("not.be.disabled")
            .click();
        cy.wait("@conflictBooking");

        cy.get("booking-modal .modal .alert-danger").should("exist");
        cy.get("booking-modal .modal").should("be.visible");
    });

    it("should show error on 500 server error response", () => {
        cy.intercept(
            "GET",
            `/api/v1/biblios/${testData.biblio.biblio_id}/pickup_locations*`
        ).as("getPickupLocations");
        cy.intercept("GET", "/api/v1/circulation_rules*").as(
            "getCirculationRules"
        );
        cy.intercept("POST", "/api/v1/bookings", {
            statusCode: 500,
            body: { error: "Internal server error" },
        }).as("serverError");

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
            `${testData.patron.surname}, ${testData.patron.preferred_name}`
        );
        cy.wait("@getPickupLocations");

        cy.vueSelectShouldBeEnabled("pickup_library_id");
        cy.vueSelectByIndex("pickup_library_id", 0);

        cy.vueSelectShouldBeEnabled("booking_item_id");
        cy.vueSelectByIndex("booking_item_id", 1);
        cy.wait("@getCirculationRules");

        cy.get("#booking_period").should("not.be.disabled");
        const startDate = dayjs().add(5, "day");
        const endDate = dayjs().add(10, "day");
        cy.get("#booking_period").selectFlatpickrDateRange(startDate, endDate);

        cy.get('button[form="form-booking"][type="submit"]')
            .should("not.be.disabled")
            .click();
        cy.wait("@serverError");

        cy.get("booking-modal .modal .alert-danger").should("exist");
        cy.get("booking-modal .modal").should("be.visible");
    });
});
