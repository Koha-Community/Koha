(function (global, $) {
    /**
     * Initializes a combobox widget with the given configuration.
     *
     * @param {Object} config - Configuration object for the combobox.
     * @param {string} config.inputId - The ID of the input element acting as the combobox.
     * @param {string} config.dropdownId - The ID of the dropdown element containing the options.
     * @param {Array<Object>} [config.data=[]] - Array of options to populate the dropdown. Each object should have a key matching the `displayProperty` and an optional unique identifier key matching the `valueProperty`.
     * @param {string} [config.displayProperty='name'] - The property of the option objects to be displayed in the dropdown.
     * @param {string} [config.valueProperty='id'] - The property of the option objects to use as the value of the input. If not set, `useKeyAsValue` must be true.
     * @param {boolean} [config.useKeyAsValue=false] - Whether to use the option's key (either HTML data-* or JavaScript `valueProperty`) as the value of the input (default: false).
     * @param {string} [config.placeholder='Select or type a value'] - Placeholder text for the input element.
     * @param {string} [config.labelId=''] - Optional ID of the associated label element.
     *
     * @example
     * ```html
     * <div class="combobox-container">
     *     <label for="generic-combobox" class="form-label">Choose an Option:</label>
     *     <input type="text" id="generic-combobox" class="form-control" placeholder="Select or type an option" />
     *     <ul id="generic-list" class="dropdown-menu position-fixed">
     *         <li>
     *             <button type="button" class="dropdown-item" data-id="1">Option 1</button>
     *         </li>
     *         <li>
     *             <button type="button" class="dropdown-item" data-id="2">Option 2</button>
     *         </li>
     *     </ul>
     * </div>
     * <script>
     * [% Asset.js("js/combobox.js" | $raw %]
     * comboBox({
     *     inputId: 'generic-combobox',
     *     dropdownId: 'generic-list',
     *     data: [{ name: 'Option 3', id: '3' }, { name: 'Option 4', id: '4' }],
     *     displayProperty: 'name',
     *     valueProperty: 'id',
     *     useKeyAsValue: true,
     * });
     * // or using jQuery
     * $("#generic-combobox").comboBox({ ... });
     * </script>
     * ```
     */
    function comboBox(config) {
        const {
            inputId,
            dropdownId,
            data = [],
            displayProperty = "name",
            valueProperty = "id",
            placeholder = "Select or type a value",
            labelId = "",
            useKeyAsValue = false,
        } = config;

        const input = document.getElementById(inputId);
        const dropdownMenu = document.getElementById(dropdownId);
        if (!input || !dropdownMenu) {
            console.error("Invalid element IDs provided for combobox");
            return;
        }

        const bootstrapDropdown = new bootstrap.Dropdown(input, {
            autoClose: false,
        });

        // Existing options from HTML
        const existingOptions = Array.from(dropdownMenu.querySelectorAll("li"))
            .map(li => {
                const actionElement = li.querySelector("button, a");
                return actionElement
                    ? {
                          [displayProperty]: actionElement.textContent.trim(),
                          [valueProperty]:
                              actionElement.dataset?.[valueProperty],
                      }
                    : null;
            })
            .filter(option => option !== null);

        let selectedValue = null;
        let query = "";
        let focusedIndex = -1;

        const combinedData = [...existingOptions, ...data];
        if (!combinedData?.length) {
            dropdownMenu.style.display = "none";
            return {
                getSelectedValue: () => selectedValue,
                reset,
            };
        }

        // Setup input attributes
        input.setAttribute("placeholder", placeholder);
        input.setAttribute("aria-expanded", "false");
        input.setAttribute("autocomplete", "off");
        input.setAttribute("role", "combobox");
        input.setAttribute("aria-haspopup", "listbox");
        input.setAttribute("aria-controls", dropdownId);
        if (labelId) {
            input.setAttribute("aria-labelledby", labelId);
        }
        input.classList.add("form-control");

        dropdownMenu.classList.add("dropdown-menu");
        dropdownMenu.setAttribute("role", "listbox");

        const group = input.closest(".combobox-container");
        group.addEventListener("focusin", () =>
            input.setAttribute("aria-expanded", "true")
        );
        group.addEventListener("focusout", e => {
            setTimeout(() => {
                if (!group.contains(document.activeElement)) {
                    hideDropdown();
                }
            }, 0);
        });

        input.addEventListener("input", handleInputChange);
        input.addEventListener("focus", () => showDropdown());
        input.addEventListener("keydown", handleKeyNavigation);
        dropdownMenu.addEventListener("click", handleOptionSelect);

        /**
         * Shows the dropdown and updates the options.
         */
        function showDropdown() {
            bootstrapDropdown.show();
            input.setAttribute("aria-expanded", "true");
            updateDropdown();
        }

        /**
         * Hides the dropdown and resets focus.
         */
        function hideDropdown() {
            bootstrapDropdown.hide();
            input.setAttribute("aria-expanded", "false");
            focusedIndex = -1;
            input.removeAttribute("aria-activedescendant");
        }

        /**
         * Handles input changes, updates the query and dropdown.
         *
         * @param {Event} event - The input event.
         */
        function handleInputChange(event) {
            query = event.target.value.toLowerCase();
            updateDropdown();
        }

        /**
         * Handles option selection from the dropdown.
         *
         * @param {Event} event - The click event.
         */
        function handleOptionSelect(event) {
            const actionElement = event.target.closest("button, a");
            if (
                actionElement &&
                actionElement.classList.contains("dropdown-item")
            ) {
                input.value = useKeyAsValue
                    ? actionElement.dataset?.[valueProperty]
                    : actionElement.textContent;
                selectedValue = combinedData.find(
                    item =>
                        item[displayProperty] ===
                        actionElement.textContent.trim()
                );
                hideDropdown();
            }
        }

        /**
         * Updates the dropdown based on the current query.
         */
        function updateDropdown() {
            dropdownMenu.innerHTML = "";
            const filteredData = query
                ? combinedData.filter(item =>
                      item[displayProperty].toLowerCase().includes(query)
                  )
                : combinedData;

            if (filteredData.length === 0 && query !== "") {
                const noResultItem = document.createElement("li");
                noResultItem.innerHTML =
                    '<button type="button" class="dropdown-item text-muted" disabled>No matches found</button>';
                noResultItem.setAttribute("role", "option");
                dropdownMenu.appendChild(noResultItem);
                return;
            }

            filteredData.forEach((item, index) => {
                const optionItem = document.createElement("li");
                optionItem.setAttribute("role", "option");
                optionItem.innerHTML = `<button type="button" class="dropdown-item combobox-option" id="${inputId}-option-${index}" data-index="${index}" data-${
                    valueProperty ?? "id"
                }="${item[valueProperty] || ""}">${
                    item[displayProperty]
                }</button>`;
                dropdownMenu.appendChild(optionItem);
            });
        }

        /**
         * Handles keyboard navigation within the dropdown.
         *
         * @param {KeyboardEvent} event - The keyboard event.
         */
        function handleKeyNavigation(event) {
            const items = dropdownMenu.querySelectorAll(".dropdown-item");
            if (!items || items.length === 0) return;

            switch (event.key) {
                case "ArrowDown":
                case "ArrowUp":
                    event.preventDefault();
                    if (event.altKey) {
                        if (event.key === "ArrowDown") showDropdown();
                        if (event.key === "ArrowUp") hideDropdown();
                        return;
                    }
                    focusedIndex =
                        (focusedIndex +
                            (event.key === "ArrowDown" ? 1 : -1) +
                            items.length) %
                        items.length;
                    focusOption(items);
                    break;
                case "Enter":
                    if (focusedIndex >= 0 && items[focusedIndex]) {
                        items[focusedIndex].click();
                    }
                    break;
                case "Tab":
                    hideDropdown();
                    break;
                case " ":
                    if (focusedIndex >= 0 && items[focusedIndex]) {
                        event.preventDefault();
                        items[focusedIndex].click();
                    }
                    break;
                case "Escape":
                    hideDropdown();
                    break;
                default:
                    break;
            }
        }

        /**
         * Focuses a specific option based on the index.
         *
         * @param {NodeListOf<Element>} items - The list of dropdown items.
         */
        function focusOption(items) {
            items.forEach((item, index) => {
                item.classList.toggle("active", index === focusedIndex);
                const actionElement = item.querySelector("button, a");
                if (index === focusedIndex && actionElement) {
                    actionElement.focus();
                    input.setAttribute(
                        "aria-activedescendant",
                        actionElement.id
                    );
                }
            });

            if (focusedIndex >= items.length) {
                focusedIndex = items.length - 1;
            } else if (focusedIndex < 0) {
                focusedIndex = 0;
            }
        }

        /**
         * Resets the combobox to its initial state.
         */
        function reset() {
            input.value = "";
            query = "";
            focusedIndex = -1;
            selectedValue = null;
            hideDropdown();
        }

        return {
            getSelectedValue: () => selectedValue,
            reset,
        };
    }

    if ($) {
        $.fn.comboBox = function (methodOrOptions) {
            if (typeof methodOrOptions === "string") {
                const methodName = methodOrOptions;
                const args = Array.prototype.slice.call(arguments, 1);
                let returnValue;

                this.each(function () {
                    const instance = $(this).data("comboBoxInstance");
                    if (!instance) {
                        console.error(
                            `comboBox not initialized on element with id: ${this.id}`
                        );
                        return;
                    }

                    if (typeof instance[methodName] === "function") {
                        returnValue = instance[methodName](...args);
                    } else {
                        console.error(
                            `Method ${methodName} does not exist on comboBox`
                        );
                    }
                });

                return returnValue !== undefined ? returnValue : this;
            }

            return this.each(function () {
                const inputId = this.id;
                const dropdownId = $(this).next("ul").attr("id");

                if (!dropdownId) {
                    console.error(
                        "No associated dropdown <ul> found for input:",
                        inputId
                    );
                    return;
                }

                const instance = comboBox({
                    ...methodOrOptions,
                    inputId: inputId,
                    dropdownId: dropdownId,
                });

                $(this).data("comboBoxInstance", instance);
            });
        };
    }

    global.comboBox = comboBox;
})(window, window.jQuery);
