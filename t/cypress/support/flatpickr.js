/* global Cypress, cy, expect */

// flatpickrHelpers.js - Enhanced Reusable Cypress functions for Flatpickr date pickers

import dayjs from "dayjs";

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

/** Resolve the instance from either Flatpickr's bound or alternate input. */
const _getFlatpickrInstance = $input => {
    const element = $input?.[0];
    if (!element) return null;
    if (element._flatpickr) return element._flatpickr;

    const container = element.closest(".booking-flatpickr-wrapper");
    if (!container) return null;
    const boundInput = Array.from(container.querySelectorAll("input")).find(
        input => input._flatpickr
    );
    return boundInput?._flatpickr ?? null;
};

/**
 * Ensures the Flatpickr calendar is open. If not, it clicks the input to open it.
 * Uses Cypress's built-in retry mechanism for reliability.
 */
const ensureCalendarIsOpen = ($el, timeout = 10000) => {
    return $el.then($input => {
        // Check whether the calendar is already open BEFORE resolving a
        // clickable input: when it is, no input is needed at all — and the
        // input may legitimately fail Cypress's visibility check at that
        // moment (e.g. scrolled out of the modal's overflow clip by the
        // open calendar itself).
        return cy.get("body").then(() => {
            return cy.get(".flatpickr-calendar").then($calendar => {
                const isVisible =
                    $calendar.length > 0 &&
                    $calendar.hasClass("open") &&
                    $calendar.is(":visible");

                if (!isVisible) {
                    // With a dateformat syspref configured, flatpickr runs
                    // in altInput mode: the bound input goes hidden and a
                    // visible alt input (which does NOT carry the
                    // flatpickr-input class) takes its place. Ask the
                    // instance for it before falling back to a DOM search.
                    const fp = _getFlatpickrInstance($input);
                    const $alt =
                        fp && fp.altInput
                            ? Cypress.$(fp.altInput)
                            : Cypress.$();
                    const inputToClick = $input.is(":visible")
                        ? $input
                        : $alt.is(":visible")
                          ? $alt
                          : $input
                                .parents()
                                .find(".flatpickr-input:visible")
                                .first();

                    if (!inputToClick.length) {
                        throw new Error(
                            `Flatpickr: Could not find visible input element for selector '${$input.selector}' to open calendar.`
                        );
                    }

                    cy.wrap(inputToClick).scrollIntoView().click();
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
        .then(() => {
            const fpInstance = _getFlatpickrInstance($input);
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
        .then(() => {
            const fpInstance = _getFlatpickrInstance($input);
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
 * Helper to get the Flatpickr mode ('single', 'range', 'multiple').
 */
Cypress.Commands.add("getFlatpickrMode", { prevSubject: true }, subject => {
    return cy.wrap(subject).then($input => {
        const fpInstance = _getFlatpickrInstance($input);
        if (!fpInstance) {
            throw new Error(
                "Flatpickr: Cannot find flatpickr instance on element. Make sure it's initialized with flatpickr."
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
                // Click the date - use native click to avoid DOM detachment from Vue re-renders
                cy.get(_getFlatpickrDateSelector(dayjsDate))
                    .should("be.visible")
                    .then($el => $el[0].click());

                // Re-query and validate selection based on mode
                return cy
                    .wrap($input)
                    .getFlatpickrMode()
                    .then(mode => {
                        if (mode === "single") {
                            // Validate via flatpickr instance (format-agnostic)
                            cy.wrap($input).should($el => {
                                const fp = _getFlatpickrInstance($el);
                                expect(fp.selectedDates.length).to.eq(1);
                                expect(
                                    dayjs(fp.selectedDates[0]).format(
                                        "YYYY-MM-DD"
                                    )
                                ).to.eq(dayjsDate.format("YYYY-MM-DD"));
                            });
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

                    // Click start date
                    return ensureDateIsVisible(
                        startDayjsDate,
                        $input,
                        timeout
                    ).then(() => {
                        cy.get(_getFlatpickrDateSelector(startDayjsDate))
                            .should("be.visible")
                            .then($el => $el[0].click());

                        // Validate start date registered via instance state
                        cy.wrap($input).should($el => {
                            const fp = _getFlatpickrInstance($el);
                            expect(fp.selectedDates).to.have.length(1);
                            expect(
                                dayjs(fp.selectedDates[0]).format("YYYY-MM-DD")
                            ).to.eq(startDayjsDate.format("YYYY-MM-DD"));
                        });

                        // Wait for async side effects to settle — the booking
                        // modal's onChange handler schedules a delayed calendar
                        // navigation (navigateCalendarIfNeeded, 100ms) that can
                        // jump the view to a different month.
                        cy.wait(150);

                        // Navigate to end date (may need to switch months if
                        // the calendar navigated away) and click it
                        return ensureDateIsVisible(
                            endDayjsDate,
                            $input,
                            timeout
                        ).then(() => {
                            cy.get(_getFlatpickrDateSelector(endDayjsDate))
                                .should("be.visible")
                                .then($el => $el[0].click());

                            // Validate range completed via instance state
                            cy.wrap($input).should($el => {
                                const fp = _getFlatpickrInstance($el);
                                expect(fp.selectedDates.length).to.eq(2);
                                expect(
                                    dayjs(fp.selectedDates[0]).format(
                                        "YYYY-MM-DD"
                                    )
                                ).to.eq(startDayjsDate.format("YYYY-MM-DD"));
                                expect(
                                    dayjs(fp.selectedDates[1]).format(
                                        "YYYY-MM-DD"
                                    )
                                ).to.eq(endDayjsDate.format("YYYY-MM-DD"));
                            });

                            // Close calendar if it stayed open
                            cy.get("body").then($body => {
                                if (
                                    $body.find(".flatpickr-calendar.open")
                                        .length > 0
                                ) {
                                    _getFlatpickrInstance($input).close();
                                }
                            });

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
                // Use native dispatchEvent to avoid detached DOM errors from Vue re-renders
                cy.get(_getFlatpickrDateSelector(dayjsDate))
                    .should("be.visible")
                    .then($el => {
                        $el[0].dispatchEvent(
                            new MouseEvent("mouseover", { bubbles: true })
                        );
                    });

                return cy.wrap($input);
            });
        });
    }
);

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
 * Helper to clear a Flatpickr input by setting its value to empty.
 * Works with hidden inputs by using the Flatpickr API directly.
 */
Cypress.Commands.add("clearFlatpickr", { prevSubject: true }, subject => {
    return cy.wrap(subject).then($input => {
        // Wait for flatpickr to be initialized and then clear it
        return cy
            .wrap($input)
            .should($el => {
                expect(Boolean(_getFlatpickrInstance($el))).to.equal(true);
            })
            .then(() => {
                _getFlatpickrInstance($input).clear();
                return cy.wrap(subject);
            });
    });
});
