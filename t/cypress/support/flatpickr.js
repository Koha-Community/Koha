// flatpickrHelpers.js - Enhanced Reusable Cypress functions for Flatpickr date pickers

// Import dayjs for date handling
const dayjs = require("dayjs");

// Note: Using browser's natural timezone to match flatpickr behavior
// The modal handles timezone conversions between API (UTC) and flatpickr (local)

/**
 * Enhanced helper functions for interacting with Flatpickr date picker components in Cypress tests
 * Uses click-driven interactions with improved reliability and native retry mechanisms
 * Supports all standard Flatpickr operations including date selection, range selection,
 * navigation, hover interactions, and assertions.
 *
 * CHAINABILITY:
 * All Flatpickr helper commands are fully chainable. You can:
 * - Chain multiple Flatpickr operations (open, navigate, select)
 * - Chain Flatpickr commands with standard Cypress commands
 * - Split complex interactions into multiple steps for better reliability
 *
 * Examples:
 * cy.get('#myDatepicker')
 *   .openFlatpickr()
 *   .selectFlatpickrDate('2023-05-15');
 *
 * cy.get('#rangePicker')
 *   .openFlatpickr()
 *   .selectFlatpickrDateRange('2023-06-01', '2023-06-15')
 *   .should('have.value', '2023-06-01 to 2023-06-15');
 */

// --- Internal Utility Functions ---

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

/**
 * Generates a Cypress selector for a specific day element within the Flatpickr calendar
 * based on its aria-label. This is a low-level internal helper.
 * @param {dayjs.Dayjs|string|Date} date - The date to generate selector for
 */
const _getFlatpickrDateSelector = date => {
    const dayjsDate = dayjs(date);
    const month = monthNames[dayjsDate.month()];
    const day = dayjsDate.date();
    const year = dayjsDate.year();
    const formattedLabel = `${month} ${day}, ${year}`;
    return `.flatpickr-day[aria-label="${formattedLabel}"]`;
};

/**
 * Ensures the Flatpickr calendar is open. If not, it clicks the input to open it.
 * Uses Cypress's built-in retry mechanism for reliability.
 */
const ensureCalendarIsOpen = ($el, timeout = 10000) => {
    return $el.then($input => {
        const inputToClick = $input.is(":visible")
            ? $input
            : $input.parents().find(".flatpickr-input:visible").first();

        if (!inputToClick.length) {
            throw new Error(
                `Flatpickr: Could not find visible input element for selector '${$input.selector}' to open calendar.`
            );
        }

        // Use Cypress's retry mechanism to check if calendar is already open
        return cy.get("body").then(() => {
            return cy.get(".flatpickr-calendar").then($calendar => {
                const isVisible =
                    $calendar.length > 0 &&
                    $calendar.hasClass("open") &&
                    $calendar.is(":visible");

                if (!isVisible) {
                    cy.wrap(inputToClick).click();
                }

                // Wait for calendar to be open and visible with retry
                return cy
                    .get(".flatpickr-calendar.open", { timeout })
                    .should("be.visible")
                    .then(() => cy.wrap($input));
            });
        });
    });
};

/**
 * Ensures the specified date is visible in the current calendar view.
 * Navigates to the correct month/year if necessary.
 * @param {dayjs.Dayjs|string|Date} targetDate - The target date
 */
const ensureDateIsVisible = (targetDate, $input, timeout = 10000) => {
    const dayjsDate = dayjs(targetDate);
    const targetYear = dayjsDate.year();
    const targetMonth = dayjsDate.month();

    return cy
        .get(".flatpickr-calendar.open", { timeout })
        .should("be.visible")
        .then($calendar => {
            const fpInstance = $input[0]._flatpickr;
            if (!fpInstance) {
                throw new Error(
                    `Flatpickr: Cannot find flatpickr instance on element. Make sure it's initialized with flatpickr.`
                );
            }
            const currentMonth = fpInstance.currentMonth;
            const currentYear = fpInstance.currentYear;

            // Check if we need to navigate
            if (currentMonth !== targetMonth || currentYear !== targetYear) {
                return navigateToMonthAndYear(dayjsDate, $input, timeout);
            }

            // Already in correct month/year, just verify the date is visible
            const selector = _getFlatpickrDateSelector(dayjsDate);
            return cy.get(selector, { timeout: 5000 }).should("be.visible");
        });
};

/**
 * Navigates the Flatpickr calendar to the target month and year.
 * Uses native retry mechanisms and verifies target date is in view.
 * @param {dayjs.Dayjs|string|Date} targetDate - The target date
 */
const navigateToMonthAndYear = (targetDate, $input, timeout = 10000) => {
    const dayjsDate = dayjs(targetDate);
    const targetYear = dayjsDate.year();
    const targetMonth = dayjsDate.month();

    return cy
        .get(".flatpickr-calendar.open", { timeout })
        .should("be.visible")
        .then($calendar => {
            const fpInstance = $input[0]._flatpickr;
            if (!fpInstance) {
                throw new Error(
                    `Flatpickr: Cannot find flatpickr instance on element. Make sure it's initialized with flatpickr.`
                );
            }
            const currentMonth = fpInstance.currentMonth;
            const currentYear = fpInstance.currentYear;

            const monthDiff =
                (targetYear - currentYear) * 12 + (targetMonth - currentMonth);

            if (monthDiff === 0) {
                // Already in correct month, verify target date is visible
                const selector = _getFlatpickrDateSelector(dayjsDate);
                return cy.get(selector, { timeout: 5000 }).should("be.visible");
            }

            // Use flatpickr's changeMonth method for faster navigation
            fpInstance.changeMonth(monthDiff, true);

            // Verify navigation succeeded by checking target date is now visible
            const selector = _getFlatpickrDateSelector(dayjsDate);
            return cy
                .get(selector, { timeout: 5000 })
                .should("be.visible")
                .should($el => {
                    // Ensure the element is actually the date we want
                    expect($el).to.have.length(1);
                    expect($el.attr("aria-label")).to.contain(
                        dayjsDate.date().toString()
                    );
                });
        });
};

// --- User-Facing Helper Commands ---

/**
 * Helper to open a Flatpickr calendar.
 */
Cypress.Commands.add(
    "openFlatpickr",
    { prevSubject: "optional" },
    (subject, selector, timeout = 10000) => {
        const $el = subject ? cy.wrap(subject) : cy.get(selector);
        return ensureCalendarIsOpen($el, timeout);
    }
);

/**
 * Helper to close an open Flatpickr calendar.
 */
Cypress.Commands.add("closeFlatpickr", { prevSubject: true }, subject => {
    return cy.wrap(subject).then($input => {
        // Wait for flatpickr to be initialized and then close it
        return cy
            .wrap($input)
            .should($el => {
                expect($el[0]).to.have.property("_flatpickr");
            })
            .then(() => {
                $input[0]._flatpickr.close();
                return cy.wrap(subject);
            });
    });
});

/**
 * Helper to navigate to a specific month and year in a Flatpickr calendar.
 */
Cypress.Commands.add(
    "navigateToFlatpickrMonth",
    { prevSubject: true },
    (subject, targetDate, timeout = 10000) => {
        return ensureCalendarIsOpen(cy.wrap(subject), timeout).then($input => {
            const dayjsDate = dayjs(targetDate);
            return navigateToMonthAndYear(dayjsDate, $input, timeout).then(() =>
                cy.wrap($input)
            );
        });
    }
);

/**
 * Helper to get the Flatpickr mode ('single', 'range', 'multiple').
 */
Cypress.Commands.add("getFlatpickrMode", { prevSubject: true }, subject => {
    return cy.wrap(subject).then($input => {
        const fpInstance = $input[0]._flatpickr;
        if (!fpInstance) {
            throw new Error(
                `Flatpickr: Cannot find flatpickr instance on element ${$input.selector}. Make sure it's initialized with flatpickr.`
            );
        }
        return fpInstance.config.mode;
    });
});

/**
 * Helper to select a specific date in a Flatpickr.
 */
Cypress.Commands.add(
    "selectFlatpickrDate",
    { prevSubject: true },
    (subject, date, timeout = 10000) => {
        return ensureCalendarIsOpen(cy.wrap(subject), timeout).then($input => {
            const dayjsDate = dayjs(date);

            return ensureDateIsVisible(dayjsDate, $input, timeout).then(() => {
                // Click the date - break chain to avoid DOM detachment
                cy.get(_getFlatpickrDateSelector(dayjsDate))
                    .should("be.visible")
                    .click();

                // Re-query and validate selection based on mode
                return cy
                    .wrap($input)
                    .getFlatpickrMode()
                    .then(mode => {
                        if (mode === "single") {
                            const expectedDate = dayjsDate.format("YYYY-MM-DD");

                            cy.wrap($input).should("have.value", expectedDate);
                            cy.get(".flatpickr-calendar.open").should(
                                "not.exist",
                                { timeout: 5000 }
                            );
                            return cy.wrap($input);
                        } else if (mode === "range") {
                            // In range mode, first selection keeps calendar open - re-query element
                            // Wait for complex date recalculations (e.g., booking availability) to complete
                            cy.get(_getFlatpickrDateSelector(dayjsDate)).should(
                                $el => {
                                    expect($el).to.have.class("selected");
                                },
                                { timeout: 5000 }
                            );
                            cy.get(".flatpickr-calendar.open").should(
                                "be.visible"
                            );
                            return cy.wrap($input);
                        }

                        return cy.wrap($input);
                    });
            });
        });
    }
);

/**
 * Helper to select a date range in a Flatpickr range picker.
 */
Cypress.Commands.add(
    "selectFlatpickrDateRange",
    { prevSubject: true },
    (subject, startDate, endDate, timeout = 10000) => {
        return ensureCalendarIsOpen(cy.wrap(subject), timeout).then($input => {
            const startDayjsDate = dayjs(startDate);
            const endDayjsDate = dayjs(endDate);

            // Validate range mode first
            return cy
                .wrap($input)
                .getFlatpickrMode()
                .then(mode => {
                    if (mode !== "range") {
                        throw new Error(
                            `Flatpickr: This flatpickr instance is not in range mode. Current mode: ${mode}. Cannot select range.`
                        );
                    }

                    // Select start date - break chain to avoid DOM detachment
                    return ensureDateIsVisible(
                        startDayjsDate,
                        $input,
                        timeout
                    ).then(() => {
                        cy.get(_getFlatpickrDateSelector(startDayjsDate))
                            .should("be.visible")
                            .click();

                        // Wait for complex date recalculations (e.g., booking availability) to complete
                        cy.get(
                            _getFlatpickrDateSelector(startDayjsDate)
                        ).should(
                            $el => {
                                expect($el).to.have.class("selected");
                                expect($el).to.have.class("startRange");
                            },
                            { timeout: 5000 }
                        );

                        // Ensure calendar stays open
                        cy.get(".flatpickr-calendar.open").should("be.visible");

                        // Navigate to end date and select it
                        return ensureDateIsVisible(
                            endDayjsDate,
                            $input,
                            timeout
                        ).then(() => {
                            cy.get(_getFlatpickrDateSelector(endDayjsDate))
                                .should("be.visible")
                                .click();

                            cy.get(".flatpickr-calendar.open").should(
                                "not.exist",
                                { timeout: 5000 }
                            );

                            // Validate final range selection
                            const expectedRange = `${startDayjsDate.format("YYYY-MM-DD")} to ${endDayjsDate.format("YYYY-MM-DD")}`;
                            cy.wrap($input).should("have.value", expectedRange);

                            return cy.wrap($input);
                        });
                    });
                });
        });
    }
);

/**
 * Helper to hover over a specific date in a Flatpickr calendar.
 */
Cypress.Commands.add(
    "hoverFlatpickrDate",
    { prevSubject: true },
    (subject, date, timeout = 10000) => {
        return ensureCalendarIsOpen(cy.wrap(subject), timeout).then($input => {
            const dayjsDate = dayjs(date);

            return ensureDateIsVisible(dayjsDate, $input, timeout).then(() => {
                cy.get(_getFlatpickrDateSelector(dayjsDate))
                    .should("be.visible")
                    .trigger("mouseover");

                return cy.wrap($input);
            });
        });
    }
);

// --- Enhanced Assertion Commands ---

/**
 * Helper to get a specific Flatpickr day element by its date.
 */
Cypress.Commands.add(
    "getFlatpickrDate",
    { prevSubject: true },
    (subject, date, timeout = 10000) => {
        const dayjsDate = dayjs(date);

        if (!dayjsDate.isValid()) {
            throw new Error(
                `getFlatpickrDate: Invalid date provided. Received: ${date}`
            );
        }

        return ensureCalendarIsOpen(cy.wrap(subject), timeout).then($input => {
            return ensureDateIsVisible(dayjsDate, $input, timeout).then(() => {
                // Instead of returning the element directly, return a function that re-queries
                // This ensures subsequent .should() calls get a fresh element reference
                const selector = _getFlatpickrDateSelector(dayjsDate);
                return cy
                    .get(selector, { timeout: 5000 })
                    .should("be.visible")
                    .should($el => {
                        // Ensure the element is actually the date we want
                        expect($el).to.have.length(1);
                        expect($el.attr("aria-label")).to.contain(
                            dayjsDate.date().toString()
                        );
                    });
            });
        });
    }
);

/**
 * Assertion helper to check if a Flatpickr date is disabled.
 */
Cypress.Commands.add(
    "flatpickrDateShouldBeDisabled",
    { prevSubject: true },
    (subject, date) => {
        return cy
            .wrap(subject)
            .getFlatpickrDate(date)
            .should("have.class", "flatpickr-disabled")
            .then(() => cy.wrap(subject));
    }
);

/**
 * Assertion helper to check if a Flatpickr date is enabled.
 */
Cypress.Commands.add(
    "flatpickrDateShouldBeEnabled",
    { prevSubject: true },
    (subject, date) => {
        return cy
            .wrap(subject)
            .getFlatpickrDate(date)
            .should("not.have.class", "flatpickr-disabled")
            .then(() => cy.wrap(subject));
    }
);

/**
 * Assertion helper to check if a Flatpickr date is selected.
 */
Cypress.Commands.add(
    "flatpickrDateShouldBeSelected",
    { prevSubject: true },
    (subject, date) => {
        return cy
            .wrap(subject)
            .getFlatpickrDate(date)
            .should("have.class", "selected")
            .then(() => cy.wrap(subject));
    }
);

/**
 * Assertion helper to check if a Flatpickr date is not selected.
 */
Cypress.Commands.add(
    "flatpickrDateShouldNotBeSelected",
    { prevSubject: true },
    (subject, date) => {
        return cy
            .wrap(subject)
            .getFlatpickrDate(date)
            .should("not.have.class", "selected")
            .then(() => cy.wrap(subject));
    }
);

/**
 * Assertion helper to check if a Flatpickr date is today.
 */
Cypress.Commands.add(
    "flatpickrDateShouldBeToday",
    { prevSubject: true },
    (subject, date) => {
        return cy
            .wrap(subject)
            .getFlatpickrDate(date)
            .should("have.class", "today")
            .then(() => cy.wrap(subject));
    }
);

/**
 * Assertion helper to check if a Flatpickr date is in a range (has inRange class).
 */
Cypress.Commands.add(
    "flatpickrDateShouldBeInRange",
    { prevSubject: true },
    (subject, date) => {
        return cy
            .wrap(subject)
            .getFlatpickrDate(date)
            .should("have.class", "inRange")
            .then(() => cy.wrap(subject));
    }
);

/**
 * Assertion helper to check if a Flatpickr date is the start of a range.
 */
Cypress.Commands.add(
    "flatpickrDateShouldBeRangeStart",
    { prevSubject: true },
    (subject, date) => {
        return cy
            .wrap(subject)
            .getFlatpickrDate(date)
            .should("have.class", "startRange")
            .then(() => cy.wrap(subject));
    }
);

/**
 * Assertion helper to check if a Flatpickr date is the end of a range.
 */
Cypress.Commands.add(
    "flatpickrDateShouldBeRangeEnd",
    { prevSubject: true },
    (subject, date) => {
        return cy
            .wrap(subject)
            .getFlatpickrDate(date)
            .should("have.class", "endRange")
            .then(() => cy.wrap(subject));
    }
);

/**
 * Helper to get the selected dates from a Flatpickr instance.
 * Returns the selected dates as an array of YYYY-MM-DD formatted strings.
 */
Cypress.Commands.add(
    "getFlatpickrSelectedDates",
    { prevSubject: true },
    subject => {
        return cy.wrap(subject).then($input => {
            const fpInstance = $input[0]._flatpickr;
            if (!fpInstance) {
                throw new Error(
                    `Flatpickr: Cannot find flatpickr instance on element. Make sure it's initialized with flatpickr.`
                );
            }

            const selectedDates = fpInstance.selectedDates.map(date =>
                dayjs(date).format("YYYY-MM-DD")
            );

            return selectedDates;
        });
    }
);

/**
 * Helper to clear a Flatpickr input by setting its value to empty.
 * Works with hidden inputs by using the Flatpickr API directly.
 */
Cypress.Commands.add("clearFlatpickr", { prevSubject: true }, subject => {
    return cy.wrap(subject).then($input => {
        // Wait for flatpickr to be initialized and then clear it
        return cy
            .wrap($input)
            .should($el => {
                expect($el[0]).to.have.property("_flatpickr");
            })
            .then(() => {
                $input[0]._flatpickr.clear();
                return cy.wrap(subject);
            });
    });
});
