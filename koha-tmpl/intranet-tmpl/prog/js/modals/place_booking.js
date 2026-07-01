let dataFetched = false;
let bookable_items,
    bookings,
    checkouts,
    booking_id,
    booking_item_id,
    booking_patron,
    booking_itemtype_id;

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

/**
 * Check if two arrays share any common elements
 * @param {Array} arr1 - First array of values
 * @param {Array} arr2 - Second array of values
 * @returns {boolean} - True if any element exists in both arrays
 */
function containsAny(arr1, arr2) {
    const set = new Set(arr2);
    return arr1.some(item => set.has(item));
}

/**
 * Parse a value to integer, with fallback to 0
 * @param {*} value - Value to parse
 * @returns {number} - Parsed integer or 0
 */
function toInt(value) {
    const parsed = parseInt(value, 10);
    return isNaN(parsed) ? 0 : parsed;
}

/**
 * Normalize a date to start of day using dayjs
 * @param {Date|string|dayjs} date - Date to normalize
 * @returns {dayjs} - dayjs object at start of day
 */
function startOfDay(date) {
    return dayjs(date).startOf("day");
}

/**
 * Check if two date ranges overlap
 * @param {Date|dayjs} start1 - Start of first range
 * @param {Date|dayjs} end1 - End of first range
 * @param {Date|dayjs} start2 - Start of second range
 * @param {Date|dayjs} end2 - End of second range
 * @returns {boolean} - True if ranges overlap
 */
function datesOverlap(start1, end1, start2, end2) {
    const s1 = startOfDay(start1);
    const e1 = startOfDay(end1);
    const s2 = startOfDay(start2);
    const e2 = startOfDay(end2);
    // Ranges overlap if neither is completely before or after the other
    return !(e1.isBefore(s2, "day") || s1.isAfter(e2, "day"));
}

/**
 * Check if a date falls within a date range (inclusive)
 * @param {Date|dayjs} date - Date to check
 * @param {Date|dayjs} start - Start of range
 * @param {Date|dayjs} end - End of range
 * @returns {boolean} - True if date is within range
 */
function isDateInRange(date, start, end) {
    const d = startOfDay(date);
    const s = startOfDay(start);
    const e = startOfDay(end);
    return d.isSameOrAfter(s, "day") && d.isSameOrBefore(e, "day");
}

/**
 * Check if a specific item is available for the entire booking period
 * @param {number|string} itemId - Item ID to check
 * @param {Date} startDate - Start of booking period
 * @param {Date} endDate - End of booking period
 * @returns {boolean} - True if item is available for the entire period
 */
function isItemAvailableForPeriod(itemId, startDate, endDate) {
    const checkItemId = toInt(itemId);
    for (const booking of bookings) {
        // Skip if we're editing this booking
        if (booking_id && booking_id == booking.booking_id) {
            continue;
        }
        // Skip different items
        if (toInt(booking.item_id) !== checkItemId) {
            continue;
        }
        // Check for overlap
        if (
            datesOverlap(
                startDate,
                endDate,
                booking.start_date,
                booking.end_date
            )
        ) {
            return false;
        }
    }
    return true;
}

$("#placeBookingModal").on("show.bs.modal", function (e) {
    // Get context
    let button = $(e.relatedTarget);
    let biblionumber = button.data("biblionumber");
    $("#booking_biblio_id").val(biblionumber);

    let patron_id = button.data("patron") || 0;
    let pickup_library_id = button.data("pickup_library");
    booking_item_id = button.data("itemnumber");
    let start_date = button.data("start_date");
    let end_date = button.data("end_date");
    let item_type_id = button.data("item_type_id");

    // Get booking id if this is an edit
    booking_id = button.data("booking");
    if (booking_id) {
        $("#placeBookingLabel").html(__("Edit booking"));
        $("#booking_id").val(booking_id);
    } else {
        $("#placeBookingLabel").html(__("Place booking"));
        // Ensure we don't accidentally update a booking
        $("#booking_id").val("");
    }

    // Patron select2
    $("#booking_patron_id").kohaSelect({
        dropdownParent: $(".modal-content", "#placeBookingModal"),
        width: "50%",
        dropdownAutoWidth: true,
        allowClear: true,
        minimumInputLength: 3,
        ajax: {
            url: "/api/v1/patrons",
            delay: 250,
            dataType: "json",
            headers: {
                "x-koha-embed": "library",
            },
            data: function (params) {
                let q = buildPatronSearchQuery(params.term);
                let query = {
                    q: JSON.stringify(q),
                    _page: params.page,
                    _order_by: "+me.surname,+me.firstname",
                };
                return query;
            },
            processResults: function (data, params) {
                let results = [];
                data.results.forEach(function (patron) {
                    patron.id = patron.patron_id;
                    results.push(patron);
                });
                return {
                    results: results,
                    pagination: { more: data.pagination.more },
                };
            },
        },
        templateResult: function (patron) {
            if (patron.library_id == loggedInLibrary) {
                loggedInClass = "ac-currentlibrary";
            } else {
                loggedInClass = "";
            }

            let $patron = $("<span></span>")
                .append(
                    "" +
                        (patron.surname
                            ? escape_str(patron.surname) + ", "
                            : "") +
                        (patron.firstname
                            ? escape_str(patron.firstname) + " "
                            : "") +
                        (patron.cardnumber
                            ? " (" + escape_str(patron.cardnumber) + ")"
                            : "") +
                        "<small>" +
                        (patron.date_of_birth
                            ? ' <span class="age_years">' +
                              $get_age(patron.date_of_birth) +
                              " " +
                              __("years") +
                              "</span>"
                            : "") +
                        (patron.library
                            ? ' <span class="ac-library">' +
                              escape_str(patron.library.name) +
                              "</span>"
                            : "") +
                        "</small>"
                )
                .addClass(loggedInClass);
            return $patron;
        },
        templateSelection: function (patron) {
            if (!patron.surname) {
                return patron.text;
            }
            return patron.surname + ", " + patron.firstname;
        },
        placeholder: __("Search for a patron"),
    });

    // Circulation rules update
    let leadDays = 0;
    let trailDays = 0;
    let boldDates = [];
    let issueLength;
    let renewalLength;
    let renewalsAllowed;

    // Note: For now, we apply the pickup library rules for issuelength, renewalsallowed and renewalperiod.
    // This effectively makes these circulation rules hard coded to CircControl: ItemHomeLibrary + HomeOrHolding: holdingbranch
    // Whilst it would be beneficial to make this follow those rules more closely, this would require some significant thinking
    // around how to best display this in the calendar component for the 'Any item' case.
    function getCirculationRules() {
        let rules_url = "/api/v1/circulation_rules";
        if (booking_patron && pickup_library_id && booking_itemtype_id) {
            $.ajax({
                url: rules_url,
                type: "GET",
                dataType: "json",
                data: {
                    patron_category_id: booking_patron.category_id,
                    item_type_id: booking_itemtype_id,
                    library_id: pickup_library_id,
                    rules: "bookings_lead_period,bookings_trail_period,issuelength,renewalsallowed,renewalperiod",
                },
                success: function (response) {
                    let rules = response[0];
                    let changed =
                        issueLength !== rules.issuelength ||
                        renewalsAllowed !== rules.renewalsallowed ||
                        renewalLength !== rules.renewalperiod;
                    issueLength = rules.issuelength;
                    renewalsAllowed = rules.renewalsallowed;
                    renewalLength = rules.renewalperiod;
                    leadDays = rules.bookings_lead_period;
                    trailDays = rules.bookings_trail_period;

                    // redraw pariodPicker taking selected item into account
                    if (changed) {
                        periodPicker.clear();
                    }
                    periodPicker.set("disable", periodPicker.config.disable);
                    periodPicker.redraw();

                    // Enable flatpickr now we have data we need
                    if (dataFetched) {
                        $("#period_fields :input").prop("disabled", false);
                    }
                },
                error: function (xhr, status, error) {
                    console.log("Circulation rules fetch failed: ", error);
                },
            });
        } else {
            periodPicker.clear();
            $("#period_fields :input").prop("disabled", true);
        }
    }

    // Pickup location select2
    let pickup_url = "/api/v1/biblios/" + biblionumber + "/pickup_locations";
    $("#pickup_library_id").select2({
        dropdownParent: $(".modal-content", "#placeBookingModal"),
        width: "50%",
        dropdownAutoWidth: true,
        minimumResultsForSearch: 10,
        allowClear: false,
        placeholder: __("Pickup location"),
    });
    function setLocationsPicker(response) {
        let $pickupSelect = $("#pickup_library_id");
        let $itemTypeSelect = $("#booking_itemtype");
        let bookableItemnumbers = bookable_items.map(function (object) {
            return object.item_id;
        });
        $pickupSelect.empty();

        $.each(response, function (index, pickup_location) {
            if (
                containsAny(pickup_location.pickup_items, bookableItemnumbers)
            ) {
                let option = $(
                    '<option value="' +
                        pickup_location.library_id +
                        '">' +
                        pickup_location.name +
                        "</option>"
                );

                option.attr(
                    "data-needs_override",
                    pickup_location.needs_override
                );
                option.attr(
                    "data-pickup_items",
                    pickup_location.pickup_items.join(",")
                );

                $pickupSelect.append(option);
            }
        });

        $pickupSelect.prop("disabled", false);

        // If pickup_library already exists, pre-select
        if (pickup_library_id) {
            $pickupSelect.val(pickup_library_id).trigger("change");
        } else {
            $pickupSelect.val(null).trigger("change");
        }

        // If item_type_id already exists, pre-select
        if (item_type_id) {
            $itemTypeSelect.val(item_type_id).trigger("change");
        } else {
            $itemTypeSelect.val(null).trigger("change");
        }
    }

    // Itemtype select2
    $("#booking_itemtype").select2({
        dropdownParent: $(".modal-content", "#placeBookingModal"),
        width: "50%",
        allowClear: true,
        dropdownAutoWidth: true,
        minimumResultsForSearch: 20,
        placeholder: __("Item type"),
    });

    // Item select2
    $("#booking_item_id").select2({
        dropdownParent: $(".modal-content", "#placeBookingModal"),
        width: "50%",
        dropdownAutoWidth: true,
        minimumResultsForSearch: 10,
        allowClear: false,
    });

    // Patron selection triggers
    $("#booking_patron_id").on("select2:select", function (e) {
        booking_patron = e.params.data;

        // Fetch pickup locations and enable picker
        $.ajax({
            url: pickup_url,
            type: "GET",
            dataType: "json",
            data: {
                _order_by: "name",
                _per_page: "-1",
                patron_id: booking_patron.patron_id,
            },
            success: function (response) {
                if (dataFetched === true) {
                    setLocationsPicker(response);
                } else {
                    var interval = setInterval(function () {
                        if (dataFetched === true) {
                            // Data is fetched, execute the callback and stop the interval
                            setLocationsPicker(response);
                            clearInterval(interval);
                        }
                    }, 100);
                }
            },
            error: function (xhr, status, error) {
                console.log("Pickup location fetch failed: ", error);
            },
        });

        // Enable item selection if item data is also fetched
        let $bookingItemSelect = $("#booking_item_id");
        $bookingItemSelect.data("patron", true);
        if ($bookingItemSelect.data("loaded")) {
            $bookingItemSelect.prop("disabled", false);
        }

        // Enable itemtype selection if item data if also fetched
        let $bookingItemtypeSelect = $("#booking_itemtype");
        $bookingItemtypeSelect.data("patron", true);
        if ($bookingItemtypeSelect.data("loaded")) {
            $bookingItemtypeSelect.prop("disabled", false);
        }

        // Populate circulation rules
        getCirculationRules();
    });

    // Adopt periodPicker
    let periodPicker = $("#period").get(0)._flatpickr;

    if (!dataFetched) {
        // Fetch list of bookable items
        let itemsFetch = $.ajax({
            url:
                "/api/v1/biblios/" +
                biblionumber +
                "/items?bookable=1" +
                "&_per_page=-1",
            dataType: "json",
            type: "GET",
            headers: {
                "x-koha-embed": "item_type",
            },
        });

        // Fetch list of existing bookings
        let bookingsFetch = $.ajax({
            url:
                "/api/v1/bookings?biblio_id=" +
                biblionumber +
                "&_per_page=-1" +
                '&q={"status":{"-in":["new","pending","active"]}}',
            dataType: "json",
            type: "GET",
        });

        // Fetch list of current checkouts
        let checkoutsFetch = $.ajax({
            url: "/api/v1/biblios/" + biblionumber + "/checkouts?_per_page=-1",
            dataType: "json",
            type: "GET",
        });

        // Update item select2 and period flatpickr
        $.when(itemsFetch, bookingsFetch, checkoutsFetch).then(
            function (itemsFetch, bookingsFetch, checkoutsFetch) {
                // Set variables
                bookable_items = itemsFetch[0];
                bookings = bookingsFetch[0];
                checkouts = checkoutsFetch[0];

                // Merge current checkouts into bookings
                for (checkout of checkouts) {
                    let already_booked = bookings.some(
                        b => b.item_id === checkout.item_id
                    );
                    if (!already_booked) {
                        let booking = {
                            biblio_id: biblionumber,
                            booking_id: null,
                            end_date: checkout.due_date,
                            item_id: checkout.item_id,
                            patron_id: checkout.patron_id,
                            start_date: dayjs().format(),
                        };
                        bookings.unshift(booking);
                    }
                }

                // Update flatpickr mode
                periodPicker.set("mode", "range");

                // Total bookable items
                let bookable = 0;
                for (item of bookable_items) {
                    bookable++;

                    // Populate item select
                    if (
                        !$("#booking_item_id").find(
                            "option[value='" + item.item_id + "']"
                        ).length
                    ) {
                        // Create a DOM Option and de-select by default
                        let newOption = new Option(
                            escape_str(item.external_id),
                            item.item_id,
                            false,
                            false
                        );
                        newOption.setAttribute("data-available", true);
                        newOption.setAttribute(
                            "data-itemtype",
                            item.effective_item_type_id
                        );

                        // Append it to the select
                        $("#booking_item_id").append(newOption);
                    }

                    // Populate item types select
                    if (
                        !$("#booking_itemtype").find(
                            "option[value='" +
                                item.item_type.item_type_id +
                                "']"
                        ).length
                    ) {
                        // Create a DOM Option and de-select by default
                        let newTypeOption = new Option(
                            escape_str(item.item_type.description),
                            item.item_type.item_type_id,
                            false,
                            false
                        );
                        $("#booking_itemtype").append(newTypeOption);
                    }
                }
                $("#booking_itemtype").val(null).trigger("change");

                // Set disable function for periodPicker
                let disableExists = periodPicker.config.disable.filter(
                    f => f.name === "dateDisable"
                );
                if (disableExists.length === 0) {
                    periodPicker.config.disable.push(
                        function dateDisable(date) {
                            // set local copy of selectedDates
                            let selectedDates = periodPicker.selectedDates;

                            // disable dates before selected date
                            if (
                                !selectedDates[1] &&
                                selectedDates[0] &&
                                selectedDates[0] > date
                            ) {
                                return true;
                            }

                            // We should always have an itemtype selected and either specific item or "any item"
                            if (!booking_itemtype_id) {
                                return true; // No itemtype selected, disable everything
                            }

                            // If "any item of itemtype" is selected, use smart window maximization
                            if (!booking_item_id) {
                                return isDateDisabledForItemtype(
                                    date,
                                    selectedDates
                                );
                            }
                            // If specific item is selected, use item-specific logic
                            else {
                                return isDateDisabledForSpecificItem(
                                    date,
                                    selectedDates
                                );
                            }
                        }
                    );
                }

                /**
                 * SMART ITEMTYPE AVAILABILITY CALCULATION
                 * For "any item of type X" bookings with dynamic item pool reduction
                 *
                 * ALGORITHM OVERVIEW:
                 * This function implements smart window maximization for itemtype bookings by using
                 * dynamic item pool reduction. The core principle is "never re-add items to pool" -
                 * once an item is removed because it becomes unavailable, it's never re-added even
                 * if it becomes available again later. This ensures optimal resource allocation.
                 *
                 * FLOW:
                 * 1. For start date selection: Disable if ALL items of itemtype are booked
                 * 2. For end date selection: Use smart window maximization algorithm
                 *
                 * SMART WINDOW MAXIMIZATION:
                 * - Start with items available on the selected start date
                 * - Walk through each day from start to target end date
                 * - Remove items from pool when they become unavailable
                 * - NEVER re-add items even if they become available again later
                 * - Disable date when no items remain in pool
                 *
                 * EXAMPLE:
                 * Items: A, B, C
                 * A available: days 1-5, booked 6-10, available again 11+
                 * B available: days 1-8, booked 9-15, available again 16+
                 * C available: days 1-12, booked 13-20, available again 21+
                 *
                 * Start day 3:
                 * - Initial pool: A, B, C
                 * - Days 3-5: Pool A, B, C (all available)
                 * - Day 6: Remove A (becomes booked), Pool now B, C
                 * - Day 9: Remove B (becomes booked), Pool now C
                 * - Day 13: Remove C (becomes booked), Pool now EMPTY → disable dates
                 * - Result: Can book days 3-12, day 13+ disabled
                 * - Note: A becomes available on day 11 but is NOT re-added to pool
                 *
                 * @param {Date} date - The date being checked for availability
                 * @param {Array} selectedDates - Array of selected dates from flatpickr [startDate, endDate?]
                 * @returns {boolean} - True if date should be disabled, false if available
                 */
                function isDateDisabledForItemtype(date, selectedDates) {
                    // Get items of the selected itemtype
                    let itemsOfType = bookable_items.filter(
                        item =>
                            item.effective_item_type_id === booking_itemtype_id
                    );

                    // For start date selection: disable if ALL items of itemtype are booked on this date
                    if (!selectedDates[0]) {
                        return (
                            getAvailableItemsOnDate(date, itemsOfType)
                                .length === 0
                        );
                    }

                    // For end date selection: use smart window maximization
                    if (selectedDates[0] && !selectedDates[1]) {
                        let result = !isDateInMaximumWindow(
                            selectedDates[0],
                            date,
                            itemsOfType
                        );
                        return result;
                    }

                    return false;
                }

                /**
                 * MAXIMUM BOOKING WINDOW CALCULATION ALGORITHM
                 * Core Implementation of "Never Re-add Items to Pool" Principle
                 *
                 * PURPOSE:
                 * Calculate the maximum possible booking window for "any item of itemtype X" bookings
                 * by dynamically reducing the available item pool as items become unavailable.
                 *
                 * CORE ALGORITHM: "Never Re-add Items to Pool"
                 * 1. Start with items available on the selected start date ONLY
                 * 2. Walk through each day from start to target end date
                 * 3. Remove items from pool when they become unavailable (booking starts)
                 * 4. NEVER re-add items even if they become available again later (booking ends)
                 * 5. Return false (disable date) when no items remain in pool
                 *
                 * WHY THIS WORKS:
                 * - Maximizes booking windows by ensuring optimal resource allocation
                 * - Prevents booking conflicts by being conservative about item availability
                 * - Ensures that if a booking can start on date X, there will always be an
                 *   item available for the entire duration (no conflicts)
                 *
                 * DETAILED EXAMPLE:
                 * Items: TABLET001, TABLET002, TABLET003
                 * TABLET001: Available 1-9, Booked 10-15, Available 16+
                 * TABLET002: Available 1-12, Booked 13-20, Available 21+
                 * TABLET003: Available 1-17, Booked 18-25, Available 26+
                 *
                 * Testing: Can we book from day 5 to day 20?
                 *
                 * Step 1: Day 5 (start) - Initial pool: {TABLET001, TABLET002, TABLET003}
                 * Step 2: Day 6-9 - All items available, pool unchanged
                 * Step 3: Day 10 - TABLET001 becomes unavailable → Remove from pool
                 *         Pool now: {TABLET002, TABLET003}
                 * Step 4: Day 11-12 - Remaining items available, pool unchanged
                 * Step 5: Day 13 - TABLET002 becomes unavailable → Remove from pool
                 *         Pool now: {TABLET003}
                 * Step 6: Day 14-17 - TABLET003 available, pool unchanged
                 * Step 7: Day 18 - TABLET003 becomes unavailable → Remove from pool
                 *         Pool now: {} (empty)
                 * Step 8: Pool is empty → Return false (cannot book to day 20)
                 *
                 * Result: Can book from day 5 to day 17, but NOT to day 18+
                 *
                 * CRITICAL NOTE: Even though TABLET001 becomes available again on day 16,
                 * it is NOT re-added to the pool. This is the key principle that ensures
                 * booking reliability and optimal resource allocation.
                 *
                 * PERFORMANCE: O(n × d) where n = items of type, d = days in range
                 *
                 * @param {Date} startDate - Selected start date from flatpickr
                 * @param {Date} endDate - Target end date being checked for availability
                 * @param {Array} itemsOfType - Items of the selected itemtype
                 * @returns {boolean} - True if date is within maximum window, false if beyond
                 */
                function isDateInMaximumWindow(
                    startDate,
                    endDate,
                    itemsOfType
                ) {
                    // Start with only items available on the start date - never add items back
                    let availableOnStart = getAvailableItemsOnDate(
                        startDate,
                        itemsOfType
                    );
                    let availableItems = new Set(
                        availableOnStart.map(item => toInt(item.item_id))
                    );

                    let currentDate = dayjs(startDate);

                    // Walk through each day from start to end date
                    while (currentDate.isSameOrBefore(endDate, "day")) {
                        let availableToday = getAvailableItemsOnDate(
                            currentDate,
                            itemsOfType
                        );
                        let availableIds = new Set(
                            availableToday.map(item => toInt(item.item_id))
                        );

                        // Remove items from our pool that are no longer available (never add back)
                        // Only remove items that are unavailable today, don't re-add previously removed items
                        let itemsToRemove = [];
                        for (let itemId of availableItems) {
                            if (!availableIds.has(itemId)) {
                                itemsToRemove.push(itemId);
                            }
                        }
                        itemsToRemove.forEach(itemId =>
                            availableItems.delete(itemId)
                        );

                        // If no items left in the pool, this date is beyond the maximum window
                        if (availableItems.size === 0) {
                            return false;
                        }

                        // Move to next day
                        currentDate = currentDate.add(1, "day");
                    }

                    return true; // Date is within the maximum window
                }

                // Get items of itemtype that are available on a specific date
                function getAvailableItemsOnDate(date, itemsOfType) {
                    const unavailableItems = new Set();

                    for (const booking of bookings) {
                        // Skip if we're editing this booking
                        if (booking_id && booking_id == booking.booking_id) {
                            continue;
                        }
                        // Check if this date falls within this booking period
                        if (
                            isDateInRange(
                                date,
                                booking.start_date,
                                booking.end_date
                            )
                        ) {
                            unavailableItems.add(toInt(booking.item_id));
                        }
                    }

                    return itemsOfType.filter(
                        item => !unavailableItems.has(toInt(item.item_id))
                    );
                }

                // Item-specific availability logic for specific item bookings
                function isDateDisabledForSpecificItem(date, selectedDates) {
                    const selectedItemId = toInt(booking_item_id);
                    for (const booking of bookings) {
                        // Skip if we're editing this booking
                        if (booking_id && booking_id == booking.booking_id) {
                            continue;
                        }
                        // Check if date is within booking period and same item
                        if (
                            isDateInRange(
                                date,
                                booking.start_date,
                                booking.end_date
                            ) &&
                            toInt(booking.item_id) === selectedItemId
                        ) {
                            return true;
                        }
                    }
                    return false;
                }

                // Setup listener for itemtype select2
                $("#booking_itemtype").on("change", function (e) {
                    let selectedValue = $(this).val(); // Get selected value (null if cleared)
                    booking_itemtype_id = selectedValue ? selectedValue : null;

                    // Handle item selectionue
                    if (!booking_itemtype_id) {
                        // Enable all items for selection
                        $("#booking_item_id > option").prop("disabled", false);
                    } else {
                        // Disable items not of this itemtype
                        $("#booking_item_id > option").each(function () {
                            let option = $(this);
                            if (option.val() != 0) {
                                let item_itemtype = option.data("itemtype");
                                if (item_itemtype == booking_itemtype_id) {
                                    if (
                                        option.data("available") &&
                                        option.data("pickup")
                                    ) {
                                        option.prop("disabled", false);
                                    }
                                } else {
                                    option.prop("disabled", true);
                                }
                            }
                        });
                    }
                    $("#booking_item_id").trigger("change.select2");

                    // Update circulation rules
                    getCirculationRules();
                });

                // Setup listener for item select2
                $("#booking_item_id").on("select2:select", function (e) {
                    booking_item_id =
                        e.params.data.id !== undefined &&
                        e.params.data.id !== null
                            ? toInt(e.params.data.id)
                            : 0;

                    // Disable invalid pickup locations
                    $("#pickup_library_id > option").each(function () {
                        const option = $(this);
                        if (booking_item_id == 0) {
                            option.prop("disabled", false);
                        } else {
                            const valid_items = String(
                                option.data("pickup_items")
                            )
                                .split(",")
                                .map(Number);
                            option.prop(
                                "disabled",
                                !valid_items.includes(toInt(booking_item_id))
                            );
                        }
                    });
                    $("#pickup_library_id").trigger("change.select2");

                    // Disable patron selection change
                    $("#booking_patron_id").prop("disabled", true);

                    // handle itemtype picker
                    if (booking_item_id != 0) {
                        let itemtype = e.params.data.element.dataset.itemtype;
                        booking_itemtype_id = itemtype;

                        $("#booking_itemtype").val(itemtype);
                        $("#booking_itemtype").trigger("change.select2");
                        $("#booking_itemtype").prop("disabled", true);
                    } else {
                        $("#booking_itemtype").prop("disabled", false);
                    }

                    // Update circulation rules
                    getCirculationRules();
                });

                // Setup listener for pickup location select2
                $("#pickup_library_id").on("select2:select", function (e) {
                    let valid_items =
                        e.params.data.element.dataset.pickup_items.split(",");
                    valid_items.push("0");

                    // Disable items not available at the pickup location
                    $("#booking_item_id > option").each(function () {
                        let option = $(this);
                        let item_id = option.val();
                        if (valid_items.includes(item_id)) {
                            option.attr("data-pickup", true);
                            if (option.data("available")) {
                                option.prop("disabled", false);
                            }
                        } else {
                            option.prop("disabled", true);
                            option.attr("data-pickup", false);
                        }
                    });
                    $("#booking_item_id").trigger("change.select2");

                    // Disable patron selection change
                    $("#booking_patron_id").prop("disabled", true);

                    pickup_library_id = $("#pickup_library_id").val();

                    // Populate circulation rules
                    getCirculationRules();
                });

                // Set onChange for flatpickr
                let changeExists = periodPicker.config.onChange.filter(
                    f => f.name === "periodChange"
                );
                if (changeExists.length === 0) {
                    periodPicker.config.onChange.push(
                        function periodChange(
                            selectedDates,
                            dateStr,
                            instance
                        ) {
                            // Start date selected
                            if (selectedDates[0] && !selectedDates[1]) {
                                const startDate = new Date(selectedDates[0]);

                                // Custom format function to make specific dates bold
                                boldDates = [new Date(startDate)];
                                // Add issueLength days after the startDate
                                const nextDate = new Date(startDate);
                                nextDate.setDate(
                                    nextDate.getDate() + parseInt(issueLength)
                                );
                                boldDates.push(new Date(nextDate));

                                // Add subsequent dates based on renewalsAllowed and renewalLength
                                for (let i = 0; i < renewalsAllowed; i++) {
                                    nextDate.setDate(
                                        nextDate.getDate() +
                                            parseInt(renewalLength)
                                    );
                                    boldDates.push(new Date(nextDate));
                                }

                                // Calculate the maximum date based on the selected start date
                                let totalRenewalLength =
                                    parseInt(renewalsAllowed) *
                                    parseInt(renewalLength);
                                let totalIssueLength =
                                    parseInt(issueLength) +
                                    parseInt(totalRenewalLength);

                                const maxDate = new Date(startDate.getTime());
                                maxDate.setDate(
                                    maxDate.getDate() + totalIssueLength
                                );

                                // Update the maxDate option of the flatpickr instance
                                instance.set("maxDate", maxDate);

                                // Re-apply startRange class after redraw
                                // Flatpickr may lose this class when maxDate triggers a redraw
                                setTimeout(() => {
                                    // Only apply if still in "start date only" state
                                    if (instance.selectedDates.length !== 1) {
                                        return;
                                    }
                                    instance.calendarContainer
                                        .querySelectorAll(
                                            ".flatpickr-day.selected"
                                        )
                                        .forEach(el => {
                                            if (
                                                !el.classList.contains(
                                                    "startRange"
                                                )
                                            ) {
                                                el.classList.add("startRange");
                                            }
                                        });
                                }, 0);
                            }
                            // Range set, update hidden fields and set available items
                            else if (selectedDates[0] && selectedDates[1]) {
                                // set form fields from picker
                                // Send day boundaries anchored to the library's configured
                                // timezone ($timezone()), not UTC or the browser's local timezone.
                                // This preserves the user's selected DATE through the server's
                                // round-trip conversion back to library time (see Bug 42868).
                                let startDate = dayjs(selectedDates[0]).format(
                                    "YYYY-MM-DD"
                                );
                                let endDate = dayjs(selectedDates[1]).format(
                                    "YYYY-MM-DD"
                                );
                                $("#booking_start_date").val(
                                    dayjs
                                        .tz(startDate, $timezone())
                                        .startOf("day")
                                        .toISOString()
                                );
                                $("#booking_end_date").val(
                                    dayjs
                                        .tz(endDate, $timezone())
                                        .endOf("day")
                                        .toISOString()
                                );
                                // set available items in select2
                                let booked_items = bookings.filter(
                                    function (booking) {
                                        // Parse and normalize dates to start-of-day for consistent comparison
                                        let start_date = dayjs(
                                            booking.start_date
                                        )
                                            .startOf("day")
                                            .toDate();
                                        let end_date = dayjs(booking.end_date)
                                            .startOf("day")
                                            .toDate();
                                        let selectedStart = dayjs(
                                            selectedDates[0]
                                        )
                                            .startOf("day")
                                            .toDate();
                                        let selectedEnd = dayjs(
                                            selectedDates[1]
                                        )
                                            .startOf("day")
                                            .toDate();

                                        // This booking ends before the start of the new booking
                                        if (end_date < selectedStart) {
                                            return false;
                                        }
                                        // This booking starts after the end of the new booking
                                        if (start_date > selectedEnd) {
                                            return false;
                                        }
                                        // This booking overlaps
                                        return true;
                                    }
                                );
                                $("#booking_item_id > option").each(
                                    function () {
                                        let option = $(this);
                                        if (
                                            booking_item_id &&
                                            booking_item_id == option.val()
                                        ) {
                                            option.prop("disabled", false);
                                        } else if (
                                            booked_items.some(
                                                function (booked_item) {
                                                    return (
                                                        option.val() ==
                                                        booked_item.item_id
                                                    );
                                                }
                                            )
                                        ) {
                                            option.attr(
                                                "data-available",
                                                false
                                            );
                                            option.prop("disabled", true);
                                        } else {
                                            option.attr("data-available", true);
                                            if (option.data("pickup")) {
                                                option.prop("disabled", false);
                                            }
                                        }
                                    }
                                );
                                $("#booking_item_id").trigger("change.select2");
                            }
                            // Range not set, reset field options and flatPickr state
                            else {
                                boldDates = [];
                                instance.set("maxDate", null);
                                $("#booking_item_id > option").each(
                                    function () {
                                        let option = $(this);
                                        if (option.data("pickup")) {
                                            option.prop("disabled", false);
                                        }
                                    }
                                );
                                $("#booking_item_id").trigger("change.select2");
                            }
                        }
                    );
                }

                // Create a bookings store keyed on date
                let bookingsByDate = {};
                // Iterate through the bookings array
                bookings.forEach(booking => {
                    const start_date = dayjs(booking.start_date);
                    const end_date = dayjs(booking.end_date);
                    const item_id = booking.item_id;

                    // Iterate through each date within the range of start_date and end_date
                    // Use dayjs to maintain browser timezone consistency
                    let currentDate = startOfDay(start_date);
                    const endDate = startOfDay(end_date);
                    while (currentDate.isSameOrBefore(endDate, "day")) {
                        // Format in browser timezone - no UTC conversion
                        const currentDateStr = currentDate.format("YYYY-MM-DD");

                        // If the date key doesn't exist in the hash, create an empty array for it
                        if (!bookingsByDate[currentDateStr]) {
                            bookingsByDate[currentDateStr] = [];
                        }

                        // Push the booking ID to the array corresponding to the date key
                        bookingsByDate[currentDateStr].push(item_id);

                        // Move to the next day
                        currentDate = currentDate.add(1, "day");
                    }
                });

                // Set onDayCreate for flatpickr
                let dayCreateExists = periodPicker.config.onDayCreate.filter(
                    f => f.name === "dayCreate"
                );
                if (dayCreateExists.length === 0) {
                    periodPicker.config.onDayCreate.push(
                        function dayCreate(dObj, dStr, instance, dayElem) {
                            const currentDate = dayElem.dateObj;
                            // Format in browser timezone to match bookingsByDate keys
                            const dateString =
                                dayjs(currentDate).format("YYYY-MM-DD");

                            const isBold = boldDates.some(
                                boldDate =>
                                    boldDate.getTime() === currentDate.getTime()
                            );
                            if (isBold) {
                                dayElem.classList.add("title");
                            }

                            if (bookingsByDate[dateString]) {
                                const dots = document.createElement("span");
                                dots.className = "event-dots";
                                dayElem.appendChild(dots);
                                bookingsByDate[dateString].forEach(item => {
                                    const dot = document.createElement("span");
                                    dot.className = "event item_" + item;
                                    dots.appendChild(dot);
                                });
                            }
                        }
                    );
                }

                // Create feedback message container below the calendar
                let feedbackDiv = periodPicker.calendarContainer.querySelector(
                    ".booking-conflict-feedback"
                );
                if (!feedbackDiv) {
                    feedbackDiv = document.createElement("div");
                    feedbackDiv.className =
                        "booking-conflict-feedback alert d-none";
                    periodPicker.calendarContainer.appendChild(feedbackDiv);
                }

                // Add hints for days before the start range and after the end range
                periodPicker.calendarContainer.addEventListener(
                    "mouseover",
                    function (event) {
                        const target = event.target;
                        if (target.classList.contains("flatpickr-day")) {
                            const hoverDate = dayjs(target.dateObj).startOf(
                                "day"
                            );
                            const startDate = periodPicker.selectedDates[0]
                                ? dayjs(periodPicker.selectedDates[0]).startOf(
                                      "day"
                                  )
                                : null;

                            // Calculate new booking's lead/trail periods
                            const leadStart = startDate
                                ? startDate.subtract(leadDays, "day")
                                : hoverDate.subtract(leadDays, "day");
                            const leadEnd = startDate
                                ? startDate.subtract(1, "day")
                                : hoverDate.subtract(1, "day");
                            const trailStart = startDate
                                ? hoverDate.add(1, "day")
                                : hoverDate.add(1, "day");
                            const trailEnd = startDate
                                ? hoverDate.add(trailDays, "day")
                                : hoverDate.add(trailDays, "day");

                            // BIDIRECTIONAL ENHANCEMENT: Collect closest bookings for visual feedback
                            // and check for mathematical conflicts in a single pass
                            let closestBeforeBooking = null;
                            let closestBeforeDistance = Infinity;

                            let closestAfterBooking = null;
                            let closestAfterDistance = Infinity;

                            let leadDisable = false;
                            let trailDisable = false;

                            // Track conflict reasons for messaging
                            let leadConflictReason = {
                                withTrail: false,
                                withLead: false,
                                withBooking: false,
                            };
                            let trailConflictReason = {
                                withTrail: false,
                                withLead: false,
                                withBooking: false,
                            };

                            // For "any item" mode, we need to check if at least one item
                            // of the selected itemtype is free from lead/trail conflicts.
                            // For specific item mode, we use the original single-item logic.
                            const isAnyItemMode =
                                !booking_item_id && booking_itemtype_id;

                            // Get items of the selected itemtype for "any item" mode
                            let itemsOfSelectedType = [];
                            if (isAnyItemMode) {
                                itemsOfSelectedType = bookable_items.filter(
                                    item =>
                                        item.effective_item_type_id ===
                                        booking_itemtype_id
                                );
                            }

                            // Track per-item conflicts for "any item" mode
                            // Maps item_id -> { leadConflict: bool, trailConflict: bool, leadReason: {...}, trailReason: {...} }
                            const itemConflicts = new Map();
                            if (isAnyItemMode) {
                                itemsOfSelectedType.forEach(item => {
                                    itemConflicts.set(toInt(item.item_id), {
                                        leadConflict: false,
                                        trailConflict: false,
                                        leadReason: {
                                            withTrail: false,
                                            withLead: false,
                                            withBooking: false,
                                        },
                                        trailReason: {
                                            withTrail: false,
                                            withLead: false,
                                            withBooking: false,
                                        },
                                    });
                                });
                            }

                            bookings.forEach(booking => {
                                // Skip if we're editing this booking
                                if (
                                    booking_id &&
                                    booking_id == booking.booking_id
                                ) {
                                    return;
                                }

                                const bookingItemId = toInt(booking.item_id);

                                // For specific item mode: skip bookings for different items
                                if (!isAnyItemMode) {
                                    if (
                                        booking.item_id &&
                                        booking_item_id &&
                                        bookingItemId !== toInt(booking_item_id)
                                    ) {
                                        return;
                                    }
                                } else {
                                    // For "any item" mode: skip bookings for items not of the selected itemtype
                                    if (!itemConflicts.has(bookingItemId)) {
                                        return;
                                    }
                                }

                                const bookingStart = startOfDay(
                                    booking.start_date
                                );
                                const bookingEnd = startOfDay(booking.end_date);

                                // BIDIRECTIONAL: Mathematical checks for conflicts (works across month boundaries)
                                // Calculate this booking's full protected period
                                const existingLeadStart = bookingStart.subtract(
                                    leadDays,
                                    "day"
                                );
                                const existingLeadEnd = bookingStart.subtract(
                                    1,
                                    "day"
                                );
                                const existingTrailStart = bookingEnd.add(
                                    1,
                                    "day"
                                );
                                const existingTrailEnd = bookingEnd.add(
                                    trailDays,
                                    "day"
                                );

                                // Check if new booking's LEAD period overlaps with existing booking
                                if (!periodPicker.selectedDates[0]) {
                                    let hasLeadConflict = false;
                                    let reason = {
                                        withTrail: false,
                                        withLead: false,
                                        withBooking: false,
                                    };

                                    // Check overlap with existing booking's trail period
                                    if (
                                        leadStart.isSameOrBefore(
                                            existingTrailEnd
                                        ) &&
                                        leadEnd.isSameOrAfter(
                                            existingTrailStart
                                        )
                                    ) {
                                        hasLeadConflict = true;
                                        reason.withTrail = true;
                                    }
                                    // Check overlap with existing booking's lead period
                                    else if (
                                        leadStart.isSameOrBefore(
                                            existingLeadEnd
                                        ) &&
                                        leadEnd.isSameOrAfter(existingLeadStart)
                                    ) {
                                        hasLeadConflict = true;
                                        reason.withLead = true;
                                    }
                                    // Check overlap with existing booking itself
                                    else if (
                                        leadStart.isSameOrBefore(bookingEnd) &&
                                        leadEnd.isSameOrAfter(bookingStart)
                                    ) {
                                        hasLeadConflict = true;
                                        reason.withBooking = true;
                                    }

                                    if (hasLeadConflict) {
                                        if (isAnyItemMode) {
                                            // Track conflict for this specific item
                                            const itemState =
                                                itemConflicts.get(
                                                    bookingItemId
                                                );
                                            if (itemState) {
                                                itemState.leadConflict = true;
                                                Object.assign(
                                                    itemState.leadReason,
                                                    reason
                                                );
                                            }
                                        } else {
                                            // Specific item mode: set global flags
                                            leadDisable = true;
                                            Object.assign(
                                                leadConflictReason,
                                                reason
                                            );
                                        }
                                    }
                                }

                                // Check if new booking's TRAIL period overlaps with existing booking
                                if (periodPicker.selectedDates[0]) {
                                    let hasTrailConflict = false;
                                    let reason = {
                                        withTrail: false,
                                        withLead: false,
                                        withBooking: false,
                                    };

                                    // Check overlap with existing booking's lead period
                                    if (
                                        trailStart.isSameOrBefore(
                                            existingLeadEnd
                                        ) &&
                                        trailEnd.isSameOrAfter(
                                            existingLeadStart
                                        )
                                    ) {
                                        hasTrailConflict = true;
                                        reason.withLead = true;
                                    }
                                    // Check overlap with existing booking's trail period
                                    else if (
                                        trailStart.isSameOrBefore(
                                            existingTrailEnd
                                        ) &&
                                        trailEnd.isSameOrAfter(
                                            existingTrailStart
                                        )
                                    ) {
                                        hasTrailConflict = true;
                                        reason.withTrail = true;
                                    }
                                    // Check overlap with existing booking itself
                                    else if (
                                        trailStart.isSameOrBefore(bookingEnd) &&
                                        trailEnd.isSameOrAfter(bookingStart)
                                    ) {
                                        hasTrailConflict = true;
                                        reason.withBooking = true;
                                    }

                                    if (hasTrailConflict) {
                                        if (isAnyItemMode) {
                                            // Track conflict for this specific item
                                            const itemState =
                                                itemConflicts.get(
                                                    bookingItemId
                                                );
                                            if (itemState) {
                                                itemState.trailConflict = true;
                                                Object.assign(
                                                    itemState.trailReason,
                                                    reason
                                                );
                                            }
                                        } else {
                                            // Specific item mode: set global flags
                                            trailDisable = true;
                                            Object.assign(
                                                trailConflictReason,
                                                reason
                                            );
                                        }
                                    }
                                }

                                // Find closest bookings for visual feedback (when dates are in view)
                                // For "any item" mode, only track closest bookings for items of the selected type
                                if (bookingEnd.isBefore(hoverDate)) {
                                    const distance = hoverDate.diff(
                                        bookingEnd,
                                        "day"
                                    );
                                    if (distance < closestBeforeDistance) {
                                        closestBeforeDistance = distance;
                                        closestBeforeBooking = {
                                            start: bookingStart,
                                            end: bookingEnd,
                                        };
                                    }
                                }

                                if (bookingStart.isAfter(hoverDate)) {
                                    const distance = bookingStart.diff(
                                        hoverDate,
                                        "day"
                                    );
                                    if (distance < closestAfterDistance) {
                                        closestAfterDistance = distance;
                                        closestAfterBooking = {
                                            start: bookingStart,
                                            end: bookingEnd,
                                        };
                                    }
                                }
                            });

                            // For "any item" mode: only disable if ALL items have conflicts
                            if (isAnyItemMode && itemConflicts.size > 0) {
                                // Check if all items have lead conflicts
                                let allHaveLeadConflict = true;
                                let allHaveTrailConflict = true;

                                for (const [
                                    itemId,
                                    state,
                                ] of itemConflicts.entries()) {
                                    if (!state.leadConflict) {
                                        allHaveLeadConflict = false;
                                    }
                                    if (!state.trailConflict) {
                                        allHaveTrailConflict = false;
                                    }
                                }

                                if (allHaveLeadConflict) {
                                    leadDisable = true;
                                    // Use the reason from the first item with a conflict for messaging
                                    for (const [
                                        itemId,
                                        state,
                                    ] of itemConflicts.entries()) {
                                        if (state.leadConflict) {
                                            Object.assign(
                                                leadConflictReason,
                                                state.leadReason
                                            );
                                            break;
                                        }
                                    }
                                }

                                if (allHaveTrailConflict) {
                                    trailDisable = true;
                                    // Use the reason from the first item with a conflict for messaging
                                    for (const [
                                        itemId,
                                        state,
                                    ] of itemConflicts.entries()) {
                                        if (state.trailConflict) {
                                            Object.assign(
                                                trailConflictReason,
                                                state.trailReason
                                            );
                                            break;
                                        }
                                    }
                                }
                            }

                            // For "any item" mode, find closest "all items booked" dates mathematically
                            // These are dates where ALL items of the itemtype have bookings
                            // Using mathematical search allows detection across month boundaries
                            let closestFullyBookedBefore = null;
                            let closestFullyBookedAfter = null;

                            if (
                                isAnyItemMode &&
                                itemsOfSelectedType.length > 0
                            ) {
                                const searchLimit = 180; // Days to search in each direction

                                // Search backwards for closest fully-booked date
                                for (let i = 1; i <= searchLimit; i++) {
                                    const checkDate = hoverDate.subtract(
                                        i,
                                        "day"
                                    );
                                    const availableItems =
                                        getAvailableItemsOnDate(
                                            checkDate.toDate(),
                                            itemsOfSelectedType
                                        );
                                    if (availableItems.length === 0) {
                                        closestFullyBookedBefore = checkDate;
                                        break;
                                    }
                                }

                                // Search forwards for closest fully-booked date
                                for (let i = 1; i <= searchLimit; i++) {
                                    const checkDate = hoverDate.add(i, "day");
                                    const availableItems =
                                        getAvailableItemsOnDate(
                                            checkDate.toDate(),
                                            itemsOfSelectedType
                                        );
                                    if (availableItems.length === 0) {
                                        closestFullyBookedAfter = checkDate;
                                        break;
                                    }
                                }
                            }

                            // Work through all days in view and add classes appropriately based on hovered date
                            periodPicker.calendarContainer
                                .querySelectorAll(".flatpickr-day")
                                .forEach(function (dayElem) {
                                    const elemDate = dayjs(
                                        dayElem.dateObj
                                    ).startOf("day");

                                    // Clear existing booking lead/trail classes (including start/end)
                                    dayElem.classList.remove(
                                        "existingBookingLead"
                                    );
                                    dayElem.classList.remove(
                                        "existingBookingLeadStart"
                                    );
                                    dayElem.classList.remove(
                                        "existingBookingLeadEnd"
                                    );
                                    dayElem.classList.remove(
                                        "existingBookingTrail"
                                    );
                                    dayElem.classList.remove(
                                        "existingBookingTrailStart"
                                    );
                                    dayElem.classList.remove(
                                        "existingBookingTrailEnd"
                                    );

                                    // Apply proposed booking's lead/trail period classes
                                    // Only apply lead classes if lead period > 0
                                    if (leadDays > 0) {
                                        dayElem.classList.toggle(
                                            "leadRangeStart",
                                            elemDate.isSame(leadStart)
                                        );
                                        dayElem.classList.toggle(
                                            "leadRange",
                                            elemDate.isSameOrAfter(leadStart) &&
                                                elemDate.isSameOrBefore(leadEnd)
                                        );
                                        dayElem.classList.toggle(
                                            "leadRangeEnd",
                                            elemDate.isSame(leadEnd)
                                        );
                                    }

                                    // Only apply trail classes if trail period > 0
                                    if (trailDays > 0) {
                                        dayElem.classList.toggle(
                                            "trailRangeStart",
                                            elemDate.isSame(trailStart)
                                        );
                                        dayElem.classList.toggle(
                                            "trailRange",
                                            elemDate.isSameOrAfter(
                                                trailStart
                                            ) &&
                                                elemDate.isSameOrBefore(
                                                    trailEnd
                                                )
                                        );
                                        dayElem.classList.toggle(
                                            "trailRangeEnd",
                                            elemDate.isSame(trailEnd)
                                        );
                                    }

                                    // Show closest preceding booking's trail period
                                    // For "any item" mode, use closest fully-booked date; for specific item, use closest booking
                                    const useClosestFullyBookedForTrail =
                                        isAnyItemMode &&
                                        closestFullyBookedBefore;
                                    const useClosestBookingForTrail =
                                        !isAnyItemMode && closestBeforeBooking;

                                    if (
                                        trailDays > 0 &&
                                        (useClosestFullyBookedForTrail ||
                                            useClosestBookingForTrail)
                                    ) {
                                        const existingTrailStart =
                                            useClosestFullyBookedForTrail
                                                ? closestFullyBookedBefore.add(
                                                      1,
                                                      "day"
                                                  )
                                                : closestBeforeBooking.end.add(
                                                      1,
                                                      "day"
                                                  );
                                        const existingTrailEnd =
                                            useClosestFullyBookedForTrail
                                                ? closestFullyBookedBefore.add(
                                                      trailDays,
                                                      "day"
                                                  )
                                                : closestBeforeBooking.end.add(
                                                      trailDays,
                                                      "day"
                                                  );

                                        if (
                                            elemDate.isSameOrAfter(
                                                existingTrailStart
                                            ) &&
                                            elemDate.isSameOrBefore(
                                                existingTrailEnd
                                            )
                                        ) {
                                            dayElem.classList.add(
                                                "existingBookingTrail"
                                            );
                                            // Add start/end classes for rounded borders
                                            if (
                                                elemDate.isSame(
                                                    existingTrailStart
                                                )
                                            ) {
                                                dayElem.classList.add(
                                                    "existingBookingTrailStart"
                                                );
                                            }
                                            if (
                                                elemDate.isSame(
                                                    existingTrailEnd
                                                )
                                            ) {
                                                dayElem.classList.add(
                                                    "existingBookingTrailEnd"
                                                );
                                            }
                                        }
                                    }

                                    // Show closest following booking's lead period
                                    // For "any item" mode, use closest fully-booked date; for specific item, use closest booking
                                    const useClosestFullyBookedForLead =
                                        isAnyItemMode &&
                                        closestFullyBookedAfter;
                                    const useClosestBookingForLead =
                                        !isAnyItemMode && closestAfterBooking;

                                    if (
                                        leadDays > 0 &&
                                        (useClosestFullyBookedForLead ||
                                            useClosestBookingForLead)
                                    ) {
                                        const existingLeadStart =
                                            useClosestFullyBookedForLead
                                                ? closestFullyBookedAfter.subtract(
                                                      leadDays,
                                                      "day"
                                                  )
                                                : closestAfterBooking.start.subtract(
                                                      leadDays,
                                                      "day"
                                                  );
                                        const existingLeadEnd =
                                            useClosestFullyBookedForLead
                                                ? closestFullyBookedAfter.subtract(
                                                      1,
                                                      "day"
                                                  )
                                                : closestAfterBooking.start.subtract(
                                                      1,
                                                      "day"
                                                  );

                                        if (
                                            elemDate.isSameOrAfter(
                                                existingLeadStart
                                            ) &&
                                            elemDate.isSameOrBefore(
                                                existingLeadEnd
                                            )
                                        ) {
                                            dayElem.classList.add(
                                                "existingBookingLead"
                                            );
                                            // Add start/end classes for rounded borders
                                            if (
                                                elemDate.isSame(
                                                    existingLeadStart
                                                )
                                            ) {
                                                dayElem.classList.add(
                                                    "existingBookingLeadStart"
                                                );
                                            }
                                            if (
                                                elemDate.isSame(existingLeadEnd)
                                            ) {
                                                dayElem.classList.add(
                                                    "existingBookingLeadEnd"
                                                );
                                            }
                                        }
                                    }

                                    // Check for conflicts with flatpickr-disabled dates
                                    if (
                                        dayElem.classList.contains(
                                            "flatpickr-disabled"
                                        )
                                    ) {
                                        if (
                                            !periodPicker.selectedDates[0] &&
                                            elemDate.isSameOrAfter(leadStart) &&
                                            elemDate.isSameOrBefore(leadEnd)
                                        ) {
                                            leadDisable = true;
                                        }
                                        if (
                                            periodPicker.selectedDates[0] &&
                                            elemDate.isSameOrAfter(
                                                trailStart
                                            ) &&
                                            elemDate.isSameOrBefore(trailEnd)
                                        ) {
                                            // Only consider this a conflict if the disabled date is within the max date range
                                            // (i.e., disabled due to booking conflict, not because it's beyond max date)
                                            const maxDate = periodPicker.config
                                                .maxDate
                                                ? dayjs(
                                                      periodPicker.config
                                                          .maxDate
                                                  )
                                                : null;
                                            if (
                                                !maxDate ||
                                                elemDate.isSameOrBefore(maxDate)
                                            ) {
                                                trailDisable = true;
                                            }
                                        }
                                    }

                                    // Check for conflicts with existing booking's trail period
                                    // In "any item" mode, these classes now represent "all items booked" periods
                                    if (
                                        !periodPicker.selectedDates[0] &&
                                        dayElem.classList.contains(
                                            "existingBookingTrail"
                                        )
                                    ) {
                                        // New booking's lead period overlaps with existing booking's trail
                                        if (
                                            elemDate.isSameOrAfter(leadStart) &&
                                            elemDate.isSameOrBefore(leadEnd)
                                        ) {
                                            leadDisable = true;
                                        }
                                    }

                                    // Check for conflicts with existing booking's lead period
                                    // In "any item" mode, these classes now represent "all items booked" periods
                                    if (
                                        periodPicker.selectedDates[0] &&
                                        dayElem.classList.contains(
                                            "existingBookingLead"
                                        )
                                    ) {
                                        // New booking's trail period overlaps with existing booking's lead
                                        if (
                                            elemDate.isSameOrAfter(
                                                trailStart
                                            ) &&
                                            elemDate.isSameOrBefore(trailEnd)
                                        ) {
                                            trailDisable = true;
                                        }
                                    }

                                    dayElem.classList.remove("leadDisable");
                                    dayElem.classList.remove("trailDisable");
                                    dayElem.removeEventListener(
                                        "click",
                                        disableClick,
                                        true
                                    );
                                });

                            // Additional check for hovering directly on existing booking's lead/trail periods
                            // In "any item" mode, these classes now represent "all items booked" periods
                            // If hovering on an existing booking's lead period when selecting start date, block selection
                            if (
                                !periodPicker.selectedDates[0] &&
                                target.classList.contains("existingBookingLead")
                            ) {
                                leadDisable = true;
                            }

                            // If hovering on an existing booking's trail period when selecting end date, block selection
                            // In "any item" mode, these classes now represent "all items booked" periods
                            if (
                                periodPicker.selectedDates[0] &&
                                target.classList.contains(
                                    "existingBookingTrail"
                                )
                            ) {
                                trailDisable = true;
                            }

                            if (leadDisable) {
                                target.classList.add("leadDisable");
                            }
                            if (trailDisable) {
                                target.classList.add("trailDisable");
                            }
                            if (trailDisable || leadDisable) {
                                target.addEventListener(
                                    "click",
                                    disableClick,
                                    true
                                );
                            }

                            // Update feedback message
                            const feedbackDiv =
                                periodPicker.calendarContainer.querySelector(
                                    ".booking-conflict-feedback"
                                );
                            if (feedbackDiv) {
                                let message = "";
                                let messageType = "info"; // info, warning, error

                                // Determine what the hovered date is (needed for both error and info messages)
                                const today = dayjs().startOf("day");
                                const isDisabled =
                                    target.classList.contains(
                                        "flatpickr-disabled"
                                    );
                                const isInExistingLead =
                                    target.classList.contains(
                                        "existingBookingLead"
                                    );
                                const isInExistingTrail =
                                    target.classList.contains(
                                        "existingBookingTrail"
                                    );

                                // Generate appropriate feedback messages based on conflicts
                                if (leadDisable || trailDisable) {
                                    messageType = "error";

                                    // When selecting START date (no date selected yet)
                                    if (!periodPicker.selectedDates[0]) {
                                        // Check direct state first (what IS this date?)
                                        if (hoverDate.isBefore(today)) {
                                            message = __(
                                                "Cannot select: date is in the past"
                                            );
                                        } else if (isDisabled) {
                                            message = __(
                                                "Cannot select: this date is part of an existing booking"
                                            );
                                        } else if (isInExistingLead) {
                                            message = __(
                                                "Cannot select: this date is part of an existing booking's lead period"
                                            );
                                        } else if (isInExistingTrail) {
                                            message = __(
                                                "Cannot select: this date is part of an existing booking's trail period"
                                            );
                                        }
                                        // Then check calculated lead period conflicts
                                        else if (
                                            leadDays > 0 &&
                                            leadStart.isSameOrBefore(today)
                                        ) {
                                            message =
                                                __("Cannot select") +
                                                ": " +
                                                __(
                                                    "insufficient lead time (%s days required before start)"
                                                ).format(leadDays);
                                        } else if (leadDays > 0) {
                                            // Use mathematical conflict detection (works across month boundaries)
                                            if (leadConflictReason.withTrail) {
                                                message =
                                                    __("Cannot select") +
                                                    ": " +
                                                    __(
                                                        "lead period (%s days before start) conflicts with an existing booking's trail period"
                                                    ).format(leadDays);
                                            } else if (
                                                leadConflictReason.withLead
                                            ) {
                                                message =
                                                    __("Cannot select") +
                                                    ": " +
                                                    __(
                                                        "lead period (%s days before start) conflicts with an existing booking's lead period"
                                                    ).format(leadDays);
                                            } else if (
                                                leadConflictReason.withBooking
                                            ) {
                                                message =
                                                    __("Cannot select") +
                                                    ": " +
                                                    __(
                                                        "lead period (%s days before start) conflicts with an existing booking"
                                                    ).format(leadDays);
                                            }
                                        } else {
                                            message = __(
                                                "Cannot select: conflicts with an existing booking"
                                            );
                                        }
                                    }
                                    // When selecting END date (start date already selected)
                                    else if (periodPicker.selectedDates[0]) {
                                        // Check direct state first (what IS this date?)
                                        if (isDisabled) {
                                            message = __(
                                                "Cannot select: this date is part of an existing booking"
                                            );
                                        } else if (isInExistingLead) {
                                            message = __(
                                                "Cannot select: this date is part of an existing booking's lead period"
                                            );
                                        } else if (isInExistingTrail) {
                                            message = __(
                                                "Cannot select: this date is part of an existing booking's trail period"
                                            );
                                        }
                                        // Then check calculated trail period conflicts
                                        else if (trailDays > 0) {
                                            // Use mathematical conflict detection (works across month boundaries)
                                            if (trailConflictReason.withLead) {
                                                message =
                                                    __("Cannot select") +
                                                    ": " +
                                                    __(
                                                        "trail period (%s days after return) conflicts with an existing booking's lead period"
                                                    ).format(trailDays);
                                            } else if (
                                                trailConflictReason.withTrail
                                            ) {
                                                message =
                                                    __("Cannot select") +
                                                    ": " +
                                                    __(
                                                        "trail period (%s days after return) conflicts with an existing booking's trail period"
                                                    ).format(trailDays);
                                            } else if (
                                                trailConflictReason.withBooking
                                            ) {
                                                message =
                                                    __("Cannot select") +
                                                    ": " +
                                                    __(
                                                        "trail period (%s days after return) conflicts with an existing booking"
                                                    ).format(trailDays);
                                            }
                                        } else {
                                            message = __(
                                                "Cannot select: conflicts with an existing booking"
                                            );
                                        }
                                    }
                                } else {
                                    // Show helpful info messages when no conflicts
                                    if (!periodPicker.selectedDates[0]) {
                                        // When selecting start date, show both lead and trail info
                                        if (leadDays > 0 && trailDays > 0) {
                                            message =
                                                __("Selecting start date") +
                                                ". " +
                                                __(
                                                    "Lead period: %s days before start"
                                                ).format(leadDays) +
                                                ". " +
                                                __(
                                                    "Trail period: %s days after return"
                                                ).format(trailDays);
                                        } else if (leadDays > 0) {
                                            message =
                                                __("Selecting start date") +
                                                ". " +
                                                __(
                                                    "Lead period: %s days before start"
                                                ).format(leadDays);
                                        } else if (trailDays > 0) {
                                            message =
                                                __("Selecting start date") +
                                                ". " +
                                                __(
                                                    "Trail period: %s days after return"
                                                ).format(trailDays);
                                        } else {
                                            message = __(
                                                "Selecting start date"
                                            );
                                        }
                                        messageType = "info";
                                    } else {
                                        if (trailDays > 0) {
                                            message =
                                                __("Selecting end date") +
                                                ". " +
                                                __(
                                                    "Trail period: %s days after return"
                                                ).format(trailDays);
                                        } else {
                                            message = __("Selecting end date");
                                        }
                                        messageType = "info";
                                    }

                                    // Show additional context if hovering over existing booking periods
                                    if (isInExistingLead) {
                                        message +=
                                            " • " +
                                            __(
                                                "hovering existing booking's lead period"
                                            );
                                    } else if (isInExistingTrail) {
                                        message +=
                                            " • " +
                                            __(
                                                "hovering existing booking's trail period"
                                            );
                                    }
                                }

                                feedbackDiv.textContent = message;
                                feedbackDiv.classList.remove(
                                    "alert-danger",
                                    "alert-warning",
                                    "alert-info"
                                );

                                if (message) {
                                    feedbackDiv.classList.remove("d-none");
                                    // Apply appropriate Bootstrap alert class based on message type
                                    if (messageType === "error") {
                                        feedbackDiv.classList.add(
                                            "alert-danger"
                                        );
                                    } else if (messageType === "warning") {
                                        feedbackDiv.classList.add(
                                            "alert-warning"
                                        );
                                    } else {
                                        feedbackDiv.classList.add("alert-info");
                                    }
                                } else {
                                    feedbackDiv.classList.add("d-none");
                                }
                            }
                        }
                    }
                );

                function disableClick(e) {
                    e.stopImmediatePropagation();
                }

                // Enable flatpickr now we have date function populated
                periodPicker.redraw();

                // Redraw itemtype select with new options and enable
                let $bookingItemtypeSelect = $("#booking_itemtype");
                $bookingItemtypeSelect.trigger("change");
                $bookingItemtypeSelect.data("loaded", true);
                if ($bookingItemtypeSelect.data("patron")) {
                    $bookingItemtypeSelect.prop("disabled", false);
                }

                // Redraw item select with new options and enable
                let $bookingItemSelect = $("#booking_item_id");
                $bookingItemSelect.trigger("change");
                $bookingItemSelect.data("loaded", true);
                if ($bookingItemSelect.data("patron")) {
                    $bookingItemSelect.prop("disabled", false);
                }

                // Set the flag to indicate that data has been fetched
                dataFetched = true;

                // Set form values
                setFormValues(
                    patron_id,
                    booking_item_id,
                    item_type_id,
                    start_date,
                    end_date,
                    periodPicker
                );
            },
            function (jqXHR, textStatus, errorThrown) {
                console.log("Fetch failed");
            }
        );
    } else {
        setFormValues(
            patron_id,
            booking_item_id,
            item_type_id,
            start_date,
            end_date,
            periodPicker
        );
    }
});

/**
 * Set date range on the period picker
 * @param {Object} periodPicker - Flatpickr instance
 * @param {string} start_date - Start date string
 * @param {string} end_date - End date string
 */
function setPickerDates(periodPicker, start_date, end_date) {
    if (start_date && end_date) {
        periodPicker.setDate([new Date(start_date), new Date(end_date)], true);
    }
}

function setFormValues(
    patron_id,
    booking_item_id,
    item_type_id,
    start_date,
    end_date,
    periodPicker
) {
    // Set itemtype first if provided (needed for edit mode before setting dates)
    if (item_type_id) {
        booking_itemtype_id = item_type_id;
    }

    // If passed patron, pre-select
    if (patron_id) {
        const patronSelect = $("#booking_patron_id");
        $.ajax({
            url: "/api/v1/patrons/" + patron_id,
            dataType: "json",
            type: "GET",
        }).done(function (patron) {
            patron.id = patron.patron_id;
            patron.text =
                escape_str(patron.surname) +
                ", " +
                escape_str(patron.firstname);

            const newOption = new Option(patron.text, patron.id, true, true);
            patronSelect.append(newOption).trigger("change");
            patronSelect.trigger({
                type: "select2:select",
                params: { data: patron },
            });
        });
    }

    // If passed an itemnumber, pre-select
    if (booking_item_id) {
        // Wait a bit for the item options to be fully created with data attributes
        setTimeout(function () {
            $("#booking_item_id").val(booking_item_id).trigger("change");
            const selectedOption = $("#booking_item_id option:selected")[0];
            if (selectedOption) {
                $("#booking_item_id").trigger({
                    type: "select2:select",
                    params: {
                        data: { id: booking_item_id, element: selectedOption },
                    },
                });
            }
            // Set dates AFTER item selection to ensure booking_itemtype_id is set
            setPickerDates(periodPicker, start_date, end_date);
        }, 100);
    } else if (start_date) {
        setPickerDates(periodPicker, start_date, end_date);
    } else {
        periodPicker.redraw();
    }
}

/**
 * Get available items of a specific itemtype for a booking period
 * @param {string} startDate - Start date string
 * @param {string} endDate - End date string
 * @returns {Array} - Array of available items
 */
function getAvailableItemsForPeriod(startDate, endDate) {
    const itemsOfType = bookable_items.filter(
        item => item.effective_item_type_id === booking_itemtype_id
    );
    return itemsOfType.filter(item =>
        isItemAvailableForPeriod(
            item.item_id,
            new Date(startDate),
            new Date(endDate)
        )
    );
}

/**
 * Build the booking payload with item selection logic
 * @param {Object} basePayload - Base payload with common fields
 * @param {string} itemId - Selected item ID (0 for "any item")
 * @param {string} startDate - Start date string
 * @param {string} endDate - End date string
 * @returns {Object|null} - Complete payload or null if no items available
 */
function buildBookingPayload(basePayload, itemId, startDate, endDate) {
    const payload = { ...basePayload };

    if (itemId == 0) {
        const availableItems = getAvailableItemsForPeriod(startDate, endDate);
        if (availableItems.length === 0) {
            return null;
        } else if (availableItems.length === 1) {
            payload.item_id = availableItems[0].item_id;
        } else {
            payload.itemtype_id = booking_itemtype_id;
        }
    } else {
        payload.item_id = itemId;
    }

    return payload;
}

/**
 * Create timeline item data from booking response
 * @param {Object} data - Booking response data
 * @returns {Object} - Timeline item data
 */
function createTimelineItem(data) {
    const startServerTz = dayjs(data.start_date).tz($timezone());
    const endServerTz = dayjs(data.end_date).tz($timezone());
    return {
        id: data.booking_id,
        booking: data.booking_id,
        patron: data.patron_id,
        start: $toDisplayDate(startServerTz),
        end: $toDisplayDate(endServerTz),
        content: $patron_to_html(booking_patron, {
            display_cardnumber: true,
            url: false,
        }),
        editable: { remove: true, updateTime: true },
        type: "range",
        group: data.item_id ? data.item_id : 0,
    };
}

/**
 * Show error message in booking result area
 * @param {string} message - Error message to display
 */
function showBookingError(message) {
    $("#booking_result").replaceWith(
        '<div id="booking_result" class="alert alert-danger">' +
            message +
            "</div>"
    );
}

/**
 * Show success feedback and close modal
 * @param {string} message - Success message to display
 */
function showBookingSuccess(message) {
    $("#transient_result").replaceWith(
        '<div id="transient_result" class="alert alert-info">' +
            message +
            "</div>"
    );
    $("#placeBookingModal").modal("hide");
}

/**
 * Refresh bookings table if present
 */
function refreshBookingsTable() {
    if (typeof bookings_table !== "undefined" && bookings_table !== null) {
        bookings_table.api().ajax.reload();
    }
}

$("#placeBookingForm").on("submit", function (e) {
    e.preventDefault();

    const url = "/api/v1/bookings";
    const start_date = $("#booking_start_date").val();
    const end_date = $("#booking_end_date").val();
    const item_id = $("#booking_item_id").val();

    const basePayload = {
        start_date: start_date,
        end_date: end_date,
        pickup_library_id: $("#pickup_library_id").val(),
        biblio_id: $("#booking_biblio_id").val(),
        patron_id: $("#booking_patron_id").find(":selected").val(),
    };

    const payload = buildBookingPayload(
        basePayload,
        item_id,
        start_date,
        end_date
    );
    if (!payload) {
        showBookingError(__("No suitable item found for booking"));
        return;
    }

    if (!booking_id) {
        // Create new booking
        $.post(url, JSON.stringify(payload))
            .done(function (data) {
                bookings.push(data);
                refreshBookingsTable();

                if (typeof timeline !== "undefined" && timeline !== null) {
                    timeline.itemsData.add(createTimelineItem(data));
                    timeline.focus(data.booking_id);
                }

                $(".bookings_count").html(
                    toInt($(".bookings_count").html()) + 1
                );
                showBookingSuccess(__("Booking successfully placed"));
            })
            .fail(function () {
                showBookingError(__("Failure"));
            });
    } else {
        // Update existing booking
        payload.booking_id = booking_id;

        $.ajax({
            method: "PUT",
            url: url + "/" + booking_id,
            contentType: "application/json",
            data: JSON.stringify(payload),
        })
            .done(function (data) {
                const target = bookings.find(
                    obj => obj.booking_id === data.booking_id
                );
                if (target) {
                    Object.assign(target, data);
                }
                refreshBookingsTable();

                if (typeof timeline !== "undefined" && timeline !== null) {
                    timeline.itemsData.update(createTimelineItem(data));
                    timeline.focus(data.booking_id);
                }

                showBookingSuccess(__("Booking successfully updated"));
            })
            .fail(function () {
                showBookingError(__("Failure"));
            });
    }
});

$("#placeBookingModal").on("hidden.bs.modal", function (e) {
    // Reset patron select
    $("#booking_patron_id")
        .val(null)
        .trigger("change")
        .empty()
        .prop("disabled", false);
    booking_patron = undefined;

    // Reset item select
    $("#booking_item_id").val(0).trigger("change").prop("disabled", true);

    // Reset itemtype select
    $("#booking_itemtype").val(null).trigger("change").prop("disabled", true);
    booking_itemtype_id = undefined;

    // Reset pickup library select
    $("#pickup_library_id")
        .val(null)
        .trigger("change")
        .empty()
        .prop("disabled", true);

    // Reset booking period picker
    $("#period").get(0)._flatpickr.clear();
    $("#period").prop("disabled", true);
    $("#booking_start_date").val("");
    $("#booking_end_date").val("");
    $("#booking_id").val("");
});
