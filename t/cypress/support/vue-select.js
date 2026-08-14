// VueSelectHelpers.js - Reusable Cypress functions for vue-select dropdowns

/**
 * Helper functions for interacting with vue-select dropdown components in Cypress tests.
 *
 * Uses direct Vue component instance access to bypass flaky DOM event chains.
 * This approach is deterministic because it sets vue-select's reactive data
 * properties directly, which triggers Vue's watcher → $emit('search') → API call
 * without depending on synthetic Cypress events reaching v-on handlers reliably.
 *
 * vue-select DOM structure:
 *   div.v-select (.vs--disabled when disabled)
 *     div.vs__dropdown-toggle
 *       div.vs__selected-options
 *         span.vs__selected (selected value display)
 *         input.vs__search[id="<inputId>"] (search input)
 *       div.vs__actions
 *         button.vs__clear (clear button)
 *     ul.vs__dropdown-menu[role="listbox"]
 *       li.vs__dropdown-option (each option)
 *       li.vs__dropdown-option--highlight (focused option)
 */

/**
 * Type in a vue-select search input and pick an option by matching text.
 * Uses direct Vue instance access to set the search value, bypassing
 * unreliable DOM event propagation through vue-select internals.
 *
 * @param {string} inputId - The ID of the vue-select search input (without #)
 * @param {string} searchText - Text to type into the search input
 * @param {string} selectText - Text of the option to select (partial match)
 * @param {Object} [options] - Additional options
 * @param {number} [options.timeout=10000] - Timeout for waiting on results
 *
 * @example
 *   cy.vueSelect("booking_patron", "Doe", "Doe John");
 */
Cypress.Commands.add(
    "vueSelect",
    (inputId, searchText, selectText, options = {}) => {
        const { timeout = 10000 } = options;

        // Ensure the v-select component is enabled and interactive before proceeding
        cy.get(`input#${inputId}`)
            .closest(".v-select")
            .should("not.have.class", "vs--disabled");

        // Set search value directly on the Vue component instance.
        // This triggers vue-select's ajax mixin watcher which emits the
        // @search event, calling the parent's debounced search handler.
        cy.get(`input#${inputId}`)
            .closest(".v-select")
            .then($vs => {
                const vueInstance = $vs[0].__vueParentComponent;
                if (vueInstance?.proxy) {
                    vueInstance.proxy.open = true;
                    vueInstance.proxy.search = searchText;
                } else {
                    throw new Error(
                        `Could not access Vue instance on v-select for #${inputId}`
                    );
                }
            });

        // Wait for dropdown with matching option to appear
        cy.get(`input#${inputId}`)
            .closest(".v-select")
            .find(".vs__dropdown-menu", { timeout })
            .should("be.visible");

        cy.get(`input#${inputId}`)
            .closest(".v-select")
            .find(".vs__dropdown-option", { timeout })
            .should("have.length.at.least", 1);

        // Click the matching option using native DOM click to avoid detached DOM issues
        cy.get(`input#${inputId}`)
            .closest(".v-select")
            .then($vs => {
                const option = Array.from(
                    $vs[0].querySelectorAll(".vs__dropdown-option")
                ).find(el => el.textContent.includes(selectText));
                expect(option, `Option containing "${selectText}" should exist`)
                    .to.exist;
                option.click();
            });

        // Verify selection was made (selected text visible)
        cy.get(`input#${inputId}`)
            .closest(".v-select")
            .find(".vs__selected")
            .should("exist");
    }
);

/**
 * Pick a vue-select option by its 0-based index in the dropdown.
 * Opens the dropdown via the Vue instance then clicks the option by index.
 *
 * @param {string} inputId - The ID of the vue-select search input (without #)
 * @param {number} index - 0-based index of the option to select
 * @param {Object} [options] - Additional options
 * @param {number} [options.timeout=10000] - Timeout for waiting on results
 *
 * @example
 *   cy.vueSelectByIndex("pickup_library_id", 0);
 */
Cypress.Commands.add("vueSelectByIndex", (inputId, index, options = {}) => {
    const { timeout = 10000 } = options;

    // Ensure the v-select component is enabled before interacting
    cy.get(`input#${inputId}`)
        .closest(".v-select")
        .should("not.have.class", "vs--disabled");

    // Open the dropdown via Vue instance for deterministic behavior
    cy.get(`input#${inputId}`)
        .closest(".v-select")
        .then($vs => {
            const vueInstance = $vs[0].__vueParentComponent;
            if (vueInstance?.proxy) {
                vueInstance.proxy.open = true;
            } else {
                // Fallback to click if Vue instance not accessible
                $vs[0].querySelector(`#${inputId}`)?.click();
            }
        });

    // Wait for dropdown and enough options to exist
    cy.get(`input#${inputId}`)
        .closest(".v-select")
        .find(".vs__dropdown-menu", { timeout })
        .should("be.visible");

    cy.get(`input#${inputId}`)
        .closest(".v-select")
        .find(".vs__dropdown-option", { timeout })
        .should("have.length.at.least", index + 1);

    // Click the option at the given index using native DOM click
    cy.get(`input#${inputId}`)
        .closest(".v-select")
        .then($vs => {
            const options = $vs[0].querySelectorAll(".vs__dropdown-option");
            options[index].click();
        });
});

/**
 * Clear the current selection in a vue-select dropdown.
 *
 * @param {string} inputId - The ID of the vue-select search input (without #)
 *
 * @example
 *   cy.vueSelectClear("booking_itemtype");
 */
Cypress.Commands.add("vueSelectClear", inputId => {
    cy.get(`input#${inputId}`)
        .closest(".v-select")
        .then($vs => {
            const clearBtn = $vs[0].querySelector(".vs__clear");
            if (clearBtn) {
                clearBtn.click();
            }
        });
});

/**
 * Assert that a vue-select displays a specific selected value text.
 *
 * @param {string} inputId - The ID of the vue-select search input (without #)
 * @param {string} text - Expected display text of the selected value
 *
 * @example
 *   cy.vueSelectShouldHaveValue("booking_itemtype", "Books");
 */
Cypress.Commands.add(
    "vueSelectShouldHaveValue",
    (inputId, text, options = {}) => {
        const { timeout = 10000 } = options;
        cy.get(`input#${inputId}`)
            .closest(".v-select")
            .find(".vs__selected", { timeout })
            .should("contain.text", text);
    }
);

/**
 * Assert that a vue-select dropdown is disabled.
 *
 * @param {string} inputId - The ID of the vue-select search input (without #)
 *
 * @example
 *   cy.vueSelectShouldBeDisabled("pickup_library_id");
 */
Cypress.Commands.add("vueSelectShouldBeDisabled", inputId => {
    cy.get(`input#${inputId}`)
        .closest(".v-select")
        .should("have.class", "vs--disabled");
});

/**
 * Assert that a vue-select dropdown is enabled (not disabled).
 *
 * @param {string} inputId - The ID of the vue-select search input (without #)
 *
 * @example
 *   cy.vueSelectShouldBeEnabled("booking_patron");
 */
Cypress.Commands.add("vueSelectShouldBeEnabled", inputId => {
    cy.get(`input#${inputId}`)
        .closest(".v-select")
        .should("not.have.class", "vs--disabled");
});
