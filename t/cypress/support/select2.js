// Select2Helpers.js - Reusable Cypress functions for Select2 dropdowns

/**
 * Helper functions for interacting with Select2 dropdown components in Cypress tests
 * Supports AJAX-based Select2s, triggering all standard Select2 events, and
 * multiple selection methods including index and text matching (partial/full)
 *
 * CHAINABILITY:
 * All Select2 helper commands are fully chainable. You can:
 * - Chain multiple Select2 operations (search, then select)
 * - Chain Select2 commands with standard Cypress commands
 * - Split complex interactions into multiple steps for better reliability
 *
 * Examples:
 *   cy.get('#mySelect')
 *     .select2({ search: 'foo' })
 *     .select2({ select: 'FooBar' });
 *
 *   cy.get('#mySelect')
 *     .select2({ search: 'bar' })
 *     .select2({ selectIndex: 0 })
 *     .should('have.value', 'bar_value');
 */

/**
 * Main Select2 interaction command to perform operations on Select2 dropdowns
 * @param {string|JQuery} [subject] - Optional jQuery element (when used with .select2())
 * @param {Object} options - Configuration options for the Select2 operation
 * @param {string} [options.search] - Search text to enter in the search box
 * @param {string|Object} [options.select] - Text to select or object with matcher options
 * @param {number} [options.selectIndex] - Index of the option to select (0-based)
 * @param {string} [options.selector] - CSS selector to find the select element (when not using subject)
 * @param {boolean} [options.clearSelection=false] - Whether to clear the current selection first
 * @param {Function} [options.matcher] - Custom matcher function for complex option selection
 * @param {number} [options.timeout=10000] - Timeout for AJAX responses in milliseconds
 * @param {boolean} [options.multiple=false] - Whether the select2 allows multiple selections
 * @param {number} [options.minSearchLength=3] - Minimum length of search text needed for Ajax select2
 * @returns {Cypress.Chainable} - Returns a chainable Cypress object for further commands
 *
 * @example
 * // Basic usage
 * cy.get('#mySelect').select2({ search: 'foo', select: 'FooBar' });
 *
 * @example
 * // Chained operations (more reliable, especially for AJAX Select2)
 * cy.get('#mySelect')
 *   .select2({ search: 'foo' })
 *   .select2({ select: 'FooBar' });
 *
 * @example
 * // With custom matcher
 * cy.get('#mySelect').select2({
 *   search: 'special',
 *   matcher: (option) => option.text.includes('Special Edition')
 * });
 */
Cypress.Commands.add(
    "select2",
    {
        prevSubject: "optional",
    },
    (subject, options) => {
        // Default configuration
        const defaults = {
            search: null,
            select: null,
            selectIndex: null,
            selector: null,
            clearSelection: false,
            matcher: null,
            timeout: 10000,
            multiple: false,
            minSearchLength: 3,
        };

        // Merge passed options with defaults
        const config = { ...defaults, ...options };

        // Handle selecting the target Select2 element
        let $originalSelect;
        if (subject) {
            $originalSelect = subject;
            // Store the element ID as a data attribute for chaining
            cy.wrap(subject).then($el => {
                const selectId = $el.attr("id");
                if (selectId) {
                    Cypress.$($el).attr("data-select2-helper-id", selectId);
                }
            });
        } else if (config.selector) {
            $originalSelect = cy.get(config.selector);
        } else {
            throw new Error(
                "Either provide a subject or a selector to identify the Select2 element"
            );
        }

        return cy.wrap($originalSelect).then($el => {
            const selectId = $el.attr("id") || $el.data("select2-helper-id");

            if (!selectId) {
                throw new Error(
                    "Select element must have an ID attribute for the Select2 helper to work correctly"
                );
            }

            // Handle clearing the selection if requested
            if (config.clearSelection) {
                cy.window().then(win => {
                    win.$(`select#${selectId}`).val(null).trigger("change");
                });

                if (
                    config.search === null &&
                    config.select === null &&
                    config.selectIndex === null &&
                    config.matcher === null
                ) {
                    return cy.get(`select#${selectId}`);
                }
            }

            // Find the Select2 container and click to open dropdown
            cy.get(`select#${selectId}`)
                .siblings(".select2-container")
                .first()
                .find(".select2-selection")
                .first()
                .click({ force: true });

            // Handle search functionality
            if (config.search !== null) {
                // Wait for search field to appear and type search text
                cy.get(".select2-search--dropdown .select2-search__field")
                    .first()
                    .should("be.visible")
                    .type(config.search, { force: true });

                // Check minimum search length requirements
                if (config.search.length < config.minSearchLength) {
                    cy.log(
                        `Warning: Search text "${config.search}" may be too short for Ajax select2 (minimum typically ${config.minSearchLength} characters)`
                    );
                }

                // Wait for results container to exist
                cy.get(".select2-results__options", {
                    timeout: config.timeout,
                }).should("exist");

                // Wait for options to be loaded and not in loading state
                cy.get(".select2-results__option", {
                    timeout: config.timeout,
                }).should($options => {
                    // Must have at least one option
                    expect($options).to.have.length.at.least(1);

                    const firstOptionText = $options
                        .first()
                        .text()
                        .toLowerCase();

                    // Should not be in loading states
                    expect(firstOptionText).to.not.include("searching");
                    expect(firstOptionText).to.not.include("loading");
                    expect(firstOptionText).to.not.include("please wait");

                    // Log if no results found, but don't fail here
                    if (
                        firstOptionText.includes("no results") ||
                        firstOptionText.includes("please enter")
                    ) {
                        cy.log(
                            `Warning: No results found for search: "${config.search}"`
                        );
                    }
                });
            }

            // Handle selection based on the provided options
            if (
                config.select !== null ||
                config.selectIndex !== null ||
                config.matcher !== null
            ) {
                // Wait for valid selectable options to be available and store matching logic
                cy.get(".select2-results__option")
                    .should($options => {
                        expect($options).to.have.length.at.least(1);

                        const firstOptionText = $options
                            .first()
                            .text()
                            .toLowerCase();

                        // Should not be in loading or error states for selection
                        expect(firstOptionText).to.not.include("searching");
                        expect(firstOptionText).to.not.include("loading");
                        expect(firstOptionText).to.not.include("please wait");
                        expect(firstOptionText.length).to.be.greaterThan(0);

                        // Should have selectable options (not just error messages)
                        if (
                            firstOptionText.includes("no results") ||
                            firstOptionText.includes("please enter")
                        ) {
                            throw new Error(
                                `No selectable options found for search: "${config.search}"`
                            );
                        }

                        // Perform selection logic and store the result for later use
                        let optionIndex = -1;

                        // Select by index
                        if (config.selectIndex !== null) {
                            expect(config.selectIndex).to.be.at.least(0);
                            expect(config.selectIndex).to.be.below(
                                $options.length
                            );
                            optionIndex = config.selectIndex;
                        }
                        // Select by custom matcher function
                        else if (
                            config.matcher !== null &&
                            typeof config.matcher === "function"
                        ) {
                            for (let i = 0; i < $options.length; i++) {
                                const $option = $options.eq(i);
                                const optionContent = {
                                    text: $option.text().trim(),
                                    html: $option.html(),
                                    element: $option[0],
                                };

                                if (config.matcher(optionContent, i)) {
                                    optionIndex = i;
                                    break;
                                }
                            }
                        }
                        // Select by text (default)
                        else if (config.select !== null) {
                            if (typeof config.select === "string") {
                                const selectText = config.select;

                                // Try exact match first
                                for (let i = 0; i < $options.length; i++) {
                                    if (
                                        Cypress.$($options[i]).text().trim() ===
                                        selectText
                                    ) {
                                        optionIndex = i;
                                        break;
                                    }
                                }

                                // Fall back to partial match if no exact match
                                if (optionIndex === -1) {
                                    for (let i = 0; i < $options.length; i++) {
                                        if (
                                            Cypress.$($options[i])
                                                .text()
                                                .trim()
                                                .includes(selectText)
                                        ) {
                                            optionIndex = i;
                                            break;
                                        }
                                    }
                                }
                            }
                            // Handle object format for advanced matching
                            else if (typeof config.select === "object") {
                                const matchType =
                                    config.select.matchType || "partial";
                                const text = config.select.text;

                                if (!text) {
                                    throw new Error(
                                        'When using object format for selection, "text" property is required'
                                    );
                                }

                                let matcher;
                                switch (matchType) {
                                    case "exact":
                                        matcher = optText => optText === text;
                                        break;
                                    case "startsWith":
                                        matcher = optText =>
                                            optText.startsWith(text);
                                        break;
                                    case "endsWith":
                                        matcher = optText =>
                                            optText.endsWith(text);
                                        break;
                                    case "partial":
                                    default:
                                        matcher = optText =>
                                            optText.includes(text);
                                }

                                for (let i = 0; i < $options.length; i++) {
                                    const optionText = Cypress.$($options[i])
                                        .text()
                                        .trim();
                                    if (matcher(optionText)) {
                                        optionIndex = i;
                                        break;
                                    }
                                }
                            }
                        }

                        // Ensure we found an option to select
                        if (optionIndex === -1) {
                            throw new Error(
                                `Could not find any option matching the selection criteria. Search: "${config.search}", Select: "${config.select}"`
                            );
                        }

                        // Store the determined index as a data attribute on the first option element
                        // This survives the should() retry cycles and can be read by subsequent commands
                        Cypress.$($options[0]).attr(
                            "data-select2-target-index",
                            optionIndex
                        );

                        // Return true to satisfy the should() assertion
                        return true;
                    })
                    .then($options => {
                        // Retrieve the stored index from the data attribute
                        const targetIndex = parseInt(
                            Cypress.$($options[0]).attr(
                                "data-select2-target-index"
                            ),
                            10
                        );

                        // Click the option at the determined index
                        return cy
                            .get(".select2-results__option")
                            .eq(targetIndex)
                            .click({ force: true });
                    });

                // Verify the selection was applied
                // Wait for the dropdown to close first (indicates selection is processing)
                cy.get(".select2-dropdown").should("not.exist");

                // Verify the selection was applied to the underlying select element
                // The .should() assertion will automatically retry until the change event has been processed
                cy.get(`select#${selectId}`).should($el => {
                    const value = $el.val();

                    // For multiple selects, value might be an array
                    if (Array.isArray(value)) {
                        expect(value).to.have.length.at.least(1);
                        expect(value[0]).to.not.be.null;
                        expect(value[0]).to.not.equal("");
                    } else {
                        expect(value).to.not.be.null;
                        expect(value).to.not.equal("");
                    }
                });
            }

            // Return the original select element for chaining
            return cy.get(`select#${selectId}`);
        });
    }
);

/**
 * Helper to clear a Select2 selection
 * Can be used as a standalone command or as part of a chain
 *
 * @param {string} selector - jQuery-like selector for the original select element
 * @returns {Cypress.Chainable} - Returns a chainable Cypress object for further commands
 *
 * @example
 * // Standalone usage
 * cy.clearSelect2('#tagSelect');
 *
 * @example
 * // As part of a chain
 * cy.get('#tagSelect')
 *   .select2({ select: 'Mystery' })
 *   .clearSelect2('#tagSelect')
 *   .select2({ select: 'Fantasy' });
 */
Cypress.Commands.add("clearSelect2", selector => {
    return cy.get(selector).select2({ clearSelection: true });
});

/**
 * Helper to search in a Select2 dropdown without making a selection
 * Useful for testing search functionality or as part of a multi-step interaction
 *
 * @param {string} selector - jQuery-like selector for the original select element
 * @param {string} searchText - Text to search for
 * @returns {Cypress.Chainable} - Returns a chainable Cypress object for further commands
 *
 * @example
 * // Standalone usage to test search functionality
 * cy.searchSelect2('#authorSelect', 'Gaiman');
 *
 * @example
 * // Chained with selection - more reliable for AJAX Select2s
 * cy.get('#publisherSelect')
 *   .searchSelect2('#publisherSelect', "O'Reilly")
 *   .select2({ selectIndex: 0 });
 */
Cypress.Commands.add("searchSelect2", (selector, searchText) => {
    return cy.get(selector).select2({ search: searchText });
});

/**
 * Helper to select an option in a Select2 dropdown by text
 * Combines search and select in one command, but can be less reliable for AJAX Select2s
 *
 * @param {string} selector - jQuery-like selector for the original select element
 * @param {string|Object} selectText - Text to select or object with matcher options
 * @param {string} [searchText=null] - Optional text to search for before selecting
 * @returns {Cypress.Chainable} - Returns a chainable Cypress object for further commands
 *
 * @example
 * // Basic usage
 * cy.selectFromSelect2('#authorSelect', 'J.R.R. Tolkien');
 *
 * @example
 * // With search text
 * cy.selectFromSelect2('#publisherSelect', 'O\'Reilly Media', 'O\'Reilly');
 *
 * @example
 * // Using advanced matching options
 * cy.selectFromSelect2('#bookSelect',
 *   { text: 'The Hobbit', matchType: 'exact' },
 *   'Hobbit'
 * );
 *
 * @example
 * // Chainable with other Cypress commands
 * cy.selectFromSelect2('#categorySelect', 'Fiction')
 *   .should('have.value', 'fiction')
 *   .and('be.visible');
 */
Cypress.Commands.add(
    "selectFromSelect2",
    (selector, selectText, searchText = null) => {
        return cy.get(selector).select2({
            search: searchText,
            select: selectText,
        });
    }
);

/**
 * Helper to select an option in a Select2 dropdown by index
 * Useful when the exact text is unknown or when needing to select a specific item by position
 *
 * @param {string} selector - jQuery-like selector for the original select element
 * @param {number} index - Index of the option to select (0-based)
 * @param {string} [searchText=null] - Optional text to search for before selecting
 * @returns {Cypress.Chainable} - Returns a chainable Cypress object for further commands
 *
 * @example
 * // Select the first item in dropdown
 * cy.selectFromSelect2ByIndex('#categorySelect', 0);
 *
 * @example
 * // Search first, then select by index
 * cy.selectFromSelect2ByIndex('#bookSelect', 2, 'Fiction');
 *
 * @example
 * // Chain with assertions
 * cy.selectFromSelect2ByIndex('#authorSelect', 0)
 *   .should('not.have.value', '')
 *   .and('be.visible');
 */
Cypress.Commands.add(
    "selectFromSelect2ByIndex",
    (selector, index, searchText = null) => {
        return cy.get(selector).select2({
            search: searchText,
            selectIndex: index,
        });
    }
);

/**
 * Helper to select an option in a Select2 dropdown using a custom matcher function
 * Most flexible option for complex Select2 structures with nested elements or specific attributes
 *
 * @param {string} selector - jQuery-like selector for the original select element
 * @param {Function} matcherFn - Custom function to match against option content
 * @param {string} [searchText=null] - Optional text to search for before selecting
 * @returns {Cypress.Chainable} - Returns a chainable Cypress object for further commands
 *
 * @example
 * // Select option with specific data attribute
 * cy.selectFromSelect2WithMatcher('#bookSelect',
 *   (option) => option.element.hasAttribute('data-special') &&
 *               option.text.includes('Special Edition'),
 *   'Lord of the Rings'
 * );
 *
 * @example
 * // Select option that contains both title and author
 * cy.selectFromSelect2WithMatcher('#bookSelect',
 *   (option) => option.text.includes('Tolkien') && option.text.includes('Hobbit'),
 *   'Tolkien'
 * );
 *
 * @example
 * // Chain with other commands
 * cy.selectFromSelect2WithMatcher('#publisherSelect',
 *   (option) => option.html.includes('<em>Premium</em>'),
 *   'Premium'
 * ).then(() => {
 *   cy.get('#premium-options').should('be.visible');
 * });
 */
Cypress.Commands.add(
    "selectFromSelect2WithMatcher",
    (selector, matcherFn, searchText = null) => {
        return cy.get(selector).select2({
            search: searchText,
            matcher: matcherFn,
        });
    }
);
