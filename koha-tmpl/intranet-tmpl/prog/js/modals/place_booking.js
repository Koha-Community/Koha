let dataFetched = false;
let bookable_items,
    bookings,
    checkouts,
    booking_id,
    booking_item_id,
    booking_patron,
    booking_itemtype_id;

function containsAny(integers1, integers2) {
    // Create a hash set to store integers from the second array
    let integerSet = {};
    for (let i = 0; i < integers2.length; i++) {
        integerSet[integers2[i]] = true;
    }

    // Check if any integer from the first array exists in the hash set
    for (let i = 0; i < integers1.length; i++) {
        if (integerSet[integers1[i]]) {
            return true; // Found a match, return true
        }
    }

    return false; // No match found
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
                            start_date: new Date().toISOString(),
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

                            // set booked counter
                            let booked = 0;

                            // reset the unavailable items array
                            let unavailable_items = [];

                            // reset the biblio level bookings array
                            let biblio_bookings = [];

                            // disable dates before selected date
                            if (
                                !selectedDates[1] &&
                                selectedDates[0] &&
                                selectedDates[0] > date
                            ) {
                                return true;
                            }

                            // iterate existing bookings
                            for (let booking of bookings) {
                                // Skip if we're editing this booking
                                if (
                                    booking_id &&
                                    booking_id == booking.booking_id
                                ) {
                                    continue;
                                }

                                let start_date = flatpickr.parseDate(
                                    booking.start_date
                                );
                                let end_date = flatpickr.parseDate(
                                    booking.end_date
                                );

                                // patron has selected a start date (end date checks)
                                if (selectedDates[0]) {
                                    // new booking start date is between existing booking start and end dates
                                    if (
                                        selectedDates[0] >= start_date &&
                                        selectedDates[0] <= end_date
                                    ) {
                                        if (booking.item_id) {
                                            if (
                                                unavailable_items.indexOf(
                                                    booking.item_id
                                                ) === -1
                                            ) {
                                                unavailable_items.push(
                                                    booking.item_id
                                                );
                                            }
                                        } else {
                                            if (
                                                biblio_bookings.indexOf(
                                                    booking.booking_id
                                                ) === -1
                                            ) {
                                                biblio_bookings.push(
                                                    booking.booking_id
                                                );
                                            }
                                        }
                                    }

                                    // new booking end date would be between existing booking start and end dates
                                    else if (
                                        date >= start_date &&
                                        date <= end_date
                                    ) {
                                        if (booking.item_id) {
                                            if (
                                                unavailable_items.indexOf(
                                                    booking.item_id
                                                ) === -1
                                            ) {
                                                unavailable_items.push(
                                                    booking.item_id
                                                );
                                            }
                                        } else {
                                            if (
                                                biblio_bookings.indexOf(
                                                    booking.booking_id
                                                ) === -1
                                            ) {
                                                biblio_bookings.push(
                                                    booking.booking_id
                                                );
                                            }
                                        }
                                    }

                                    // new booking would span existing booking
                                    else if (
                                        selectedDates[0] <= start_date &&
                                        date >= end_date
                                    ) {
                                        if (booking.item_id) {
                                            if (
                                                unavailable_items.indexOf(
                                                    booking.item_id
                                                ) === -1
                                            ) {
                                                unavailable_items.push(
                                                    booking.item_id
                                                );
                                            }
                                        } else {
                                            if (
                                                biblio_bookings.indexOf(
                                                    booking.booking_id
                                                ) === -1
                                            ) {
                                                biblio_bookings.push(
                                                    booking.booking_id
                                                );
                                            }
                                        }
                                    }

                                    // new booking would not conflict
                                    else {
                                        continue;
                                    }

                                    // check availability based on selection type
                                    if (
                                        booking_item_id &&
                                        booking_item_id != 0
                                    ) {
                                        // Specific item selected - check if that item is unavailable
                                        if (
                                            unavailable_items.indexOf(
                                                parseInt(booking_item_id)
                                            ) !== -1
                                        ) {
                                            return true;
                                        }
                                    } else {
                                        // "Any item" selected - check if all items are unavailable
                                        let total_available =
                                            bookable_items.length -
                                            unavailable_items.length -
                                            biblio_bookings.length;
                                        if (total_available === 0) {
                                            return true;
                                        }
                                    }
                                }

                                // patron has not yet selected a start date (start date checks)
                                else if (
                                    date <= end_date &&
                                    date >= start_date
                                ) {
                                    // same item, disable date
                                    if (
                                        booking.item_id &&
                                        booking.item_id == booking_item_id
                                    ) {
                                        return true;
                                    }

                                    // count all clashes, both item and biblio level
                                    booked++;
                                    if (booked == bookable) {
                                        return true;
                                    }

                                    // FIXME: The above is not intelligent enough to spot
                                    // cases where an item must be used for a biblio level booking
                                    // due to all other items being booking within the biblio level
                                    // booking period... we end up with a clash
                                    // To reproduce:
                                    // * One bib with two bookable items.
                                    // * Add item level booking
                                    // * Add biblio level booking that extends one day beyond the item level booking
                                    // * Try to book the item without an item level booking from the day before the biblio level
                                    //   booking is to be returned. Note this is a clash, the only item available for the biblio
                                    //   level booking is the item you just booked out overlapping the end date.
                                }
                            }
                        }
                    );
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
                    booking_item_id = e.params.data.id
                        ? e.params.data.id
                        : null;

                    // Disable invalid pickup locations
                    $("#pickup_library_id > option").each(function () {
                        let option = $(this);
                        if (booking_item_id == 0) {
                            option.prop("disabled", false);
                        } else {
                            let valid_items = String(
                                option.data("pickup_items")
                            )
                                .split(",")
                                .map(Number);
                            if (
                                valid_items.includes(parseInt(booking_item_id))
                            ) {
                                option.prop("disabled", false);
                            } else {
                                option.prop("disabled", true);
                            }
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
                                        .querySelectorAll(".flatpickr-day.selected")
                                        .forEach(el => {
                                            if (!el.classList.contains("startRange")) {
                                                el.classList.add("startRange");
                                            }
                                        });
                                }, 0);
                            }
                            // Range set, update hidden fields and set available items
                            else if (selectedDates[0] && selectedDates[1]) {
                                // set form fields from picker
                                let picker_start = dayjs(selectedDates[0]);
                                let picker_end = dayjs(selectedDates[1]).endOf(
                                    "day"
                                );
                                $("#booking_start_date").val(
                                    picker_start.toISOString()
                                );
                                $("#booking_end_date").val(
                                    picker_end.toISOString()
                                );

                                // set available items in select2
                                let booked_items = bookings.filter(
                                    function (booking) {
                                        let start_date = flatpickr.parseDate(
                                            booking.start_date
                                        );
                                        let end_date = flatpickr.parseDate(
                                            booking.end_date
                                        );
                                        // This booking ends before the start of the new booking
                                        if (end_date <= selectedDates[0]) {
                                            return false;
                                        }
                                        // This booking starts after then end of the new booking
                                        if (start_date >= selectedDates[1]) {
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
                    const start_date = flatpickr.parseDate(booking.start_date);
                    const end_date = flatpickr.parseDate(booking.end_date);
                    const item_id = booking.item_id;

                    // Iterate through each date within the range of start_date and end_date
                    let currentDate = new Date(start_date);
                    while (currentDate <= end_date) {
                        const currentDateStr = currentDate
                            .toISOString()
                            .split("T")[0];

                        // If the date key doesn't exist in the hash, create an empty array for it
                        if (!bookingsByDate[currentDateStr]) {
                            bookingsByDate[currentDateStr] = [];
                        }

                        // Push the booking ID to the array corresponding to the date key
                        bookingsByDate[currentDateStr].push(item_id);

                        // Move to the next day
                        currentDate.setDate(currentDate.getDate() + 1);
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
                            const dateString = currentDate
                                .toISOString()
                                .split("T")[0];

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

                            const leadStart = startDate
                                ? startDate.subtract(leadDays, "day")
                                : hoverDate.subtract(leadDays, "day");
                            const leadEnd = startDate ? startDate : hoverDate;
                            const trailStart = hoverDate;
                            const trailEnd = hoverDate.add(trailDays, "day");

                            let leadDisable = false;
                            let trailDisable = false;
                            periodPicker.calendarContainer
                                .querySelectorAll(".flatpickr-day")
                                .forEach(function (dayElem) {
                                    const elemDate = dayjs(
                                        dayElem.dateObj
                                    ).startOf("day");

                                    dayElem.classList.toggle(
                                        "leadRangeStart",
                                        elemDate.isSame(leadStart)
                                    );
                                    dayElem.classList.toggle(
                                        "leadRange",
                                        elemDate.isSameOrAfter(leadStart) &&
                                            elemDate.isBefore(leadEnd)
                                    );
                                    dayElem.classList.toggle(
                                        "leadRangeEnd",
                                        elemDate.isSame(leadEnd)
                                    );
                                    dayElem.classList.toggle(
                                        "trailRangeStart",
                                        elemDate.isSame(trailStart)
                                    );
                                    dayElem.classList.toggle(
                                        "trailRange",
                                        elemDate.isAfter(trailStart) &&
                                            elemDate.isSameOrBefore(trailEnd)
                                    );
                                    dayElem.classList.toggle(
                                        "trailRangeEnd",
                                        elemDate.isSame(trailEnd)
                                    );
                                    // If we're overlapping a disabled date, disable our hoverDate
                                    if (
                                        dayElem.classList.contains(
                                            "flatpickr-disabled"
                                        )
                                    ) {
                                        if (
                                            !periodPicker.selectedDates[0] &&
                                            elemDate.isSameOrAfter(leadStart) &&
                                            elemDate.isBefore(leadEnd)
                                        ) {
                                            leadDisable = true;
                                        }
                                        if (
                                            elemDate.isAfter(trailStart) &&
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
                                    dayElem.classList.remove("leadDisable");
                                    dayElem.classList.remove("trailDisable");
                                    dayElem.removeEventListener(
                                        "click",
                                        disableClick,
                                        true
                                    );
                                });

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
            start_date,
            end_date,
            periodPicker
        );
    }
});

function setFormValues(
    patron_id,
    booking_item_id,
    start_date,
    end_date,
    periodPicker
) {
    // If passed patron, pre-select
    if (patron_id) {
        let patronSelect = $("#booking_patron_id");
        let patron = $.ajax({
            url: "/api/v1/patrons/" + patron_id,
            dataType: "json",
            type: "GET",
        });

        $.when(patron).done(function (patron) {
            // clone patron_id to id (select2 expects an id field)
            patron.id = patron.patron_id;
            patron.text =
                escape_str(patron.surname) +
                ", " +
                escape_str(patron.firstname);

            // Add and select new option
            let newOption = new Option(patron.text, patron.id, true, true);
            patronSelect.append(newOption).trigger("change");

            // manually trigger the `select2:select` event
            patronSelect.trigger({
                type: "select2:select",
                params: {
                    data: patron,
                },
            });
        });
    }

    // If passed an itemnumber, pre-select
    if (booking_item_id) {
        // Wait a bit for the item options to be fully created with data attributes
        setTimeout(function () {
            $("#booking_item_id").val(booking_item_id).trigger("change");
            // Also trigger the select2:select event with proper data
            let selectedOption = $("#booking_item_id option:selected")[0];
            if (selectedOption) {
                $("#booking_item_id").trigger({
                    type: "select2:select",
                    params: {
                        data: {
                            id: booking_item_id,
                            element: selectedOption,
                        },
                    },
                });
            }
        }, 100);
    }

    // Set booking start & end if this is an edit
    if (start_date) {
        // Allow invalid pre-load so setDate can set date range
        // periodPicker.set('allowInvalidPreload', true);
        // FIXME: Why is this the case.. we're passing two valid Date objects
        let start = new Date(start_date);
        let end = new Date(end_date);

        let dates = [new Date(start_date), new Date(end_date)];
        periodPicker.setDate(dates, true);
    }
    // Reset periodPicker, biblio_id may have been nulled
    else {
        periodPicker.redraw();
    }
}

$("#placeBookingForm").on("submit", function (e) {
    e.preventDefault();

    let url = "/api/v1/bookings";

    let start_date = $("#booking_start_date").val();
    let end_date = $("#booking_end_date").val();
    let pickup_library_id = $("#pickup_library_id").val();
    let biblio_id = $("#booking_biblio_id").val();
    let item_id = $("#booking_item_id").val();

    if (!booking_id) {
        let posting = $.post(
            url,
            JSON.stringify({
                start_date: start_date,
                end_date: end_date,
                pickup_library_id: pickup_library_id,
                biblio_id: biblio_id,
                item_id: item_id != 0 ? item_id : null,
                patron_id: $("#booking_patron_id").find(":selected").val(),
            })
        );

        posting.done(function (data) {
            // Update bookings store for subsequent bookings
            bookings.push(data);

            // Update bookings page as required
            if (
                typeof bookings_table !== "undefined" &&
                bookings_table !== null
            ) {
                bookings_table.api().ajax.reload();
            }
            if (typeof timeline !== "undefined" && timeline !== null) {
                timeline.itemsData.add({
                    id: data.booking_id,
                    booking: data.booking_id,
                    patron: data.patron_id,
                    start: dayjs(data.start_date).toDate(),
                    end: dayjs(data.end_date).toDate(),
                    content: $patron_to_html(booking_patron, {
                        display_cardnumber: true,
                        url: false,
                    }),
                    editable: { remove: true, updateTime: true },
                    type: "range",
                    group: data.item_id ? data.item_id : 0,
                });
                timeline.focus(data.booking_id);
            }

            // Update bookings counts
            $(".bookings_count").html(
                parseInt($(".bookings_count").html(), 10) + 1
            );

            // Set feedback
            $("#transient_result").replaceWith(
                '<div id="transient_result" class="alert alert-info">' +
                    __("Booking successfully placed") +
                    "</div>"
            );

            // Close modal
            $("#placeBookingModal").modal("hide");
        });

        posting.fail(function (data) {
            $("#booking_result").replaceWith(
                '<div id="booking_result" class="alert alert-danger">' +
                    __("Failure") +
                    "</div>"
            );
        });
    } else {
        url += "/" + booking_id;
        let putting = $.ajax({
            method: "PUT",
            url: url,
            contentType: "application/json",
            data: JSON.stringify({
                booking_id: booking_id,
                start_date: start_date,
                end_date: end_date,
                pickup_library_id: pickup_library_id,
                biblio_id: biblio_id,
                item_id: item_id != 0 ? item_id : null,
                patron_id: $("#booking_patron_id").find(":selected").val(),
            }),
        });

        putting.done(function (data) {
            update_success = 1;

            // Update bookings store for subsequent bookings
            let target = bookings.find(
                obj => obj.booking_id === data.booking_id
            );
            Object.assign(target, data);

            // Update bookings page as required
            if (
                typeof bookings_table !== "undefined" &&
                bookings_table !== null
            ) {
                bookings_table.api().ajax.reload();
            }
            if (typeof timeline !== "undefined" && timeline !== null) {
                timeline.itemsData.update({
                    id: data.booking_id,
                    booking: data.booking_id,
                    patron: data.patron_id,
                    start: dayjs(data.start_date).toDate(),
                    end: dayjs(data.end_date).toDate(),
                    content: $patron_to_html(booking_patron, {
                        display_cardnumber: true,
                        url: false,
                    }),
                    editable: { remove: true, updateTime: true },
                    type: "range",
                    group: data.item_id ? data.item_id : 0,
                });
                timeline.focus(data.booking_id);
            }

            // Set feedback
            $("#transient_result").replaceWith(
                '<div id="transient_result" class="alert alert-info">' +
                    __("Booking successfully updated") +
                    "</div>"
            );

            // Close modal
            $("#placeBookingModal").modal("hide");
        });

        putting.fail(function (data) {
            $("#booking_result").replaceWith(
                '<div id="booking_result" class="alert alert-danger">' +
                    __("Failure") +
                    "</div>"
            );
        });
    }
});

$("#placeBookingModal").on("hidden.bs.modal", function (e) {
    // Reset patron select
    $("#booking_patron_id").val(null).trigger("change");
    $("#booking_patron_id").empty();
    $("#booking_patron_id").prop("disabled", false);
    booking_patron = undefined;

    // Reset item select
    $("#booking_item_id").val(0).trigger("change");
    $("#booking_item_id").prop("disabled", true);

    // Reset itemtype select
    $("#booking_itemtype").val(null).trigger("change");
    $("#booking_itemtype").prop("disabled", true);
    booking_itemtype_id = undefined;

    // Reset pickup library select
    $("#pickup_library_id").val(null).trigger("change");
    $("#pickup_library_id").empty();
    $("#pickup_library_id").prop("disabled", true);

    // Reset booking period picker
    $("#period").get(0)._flatpickr.clear();
    $("#period").prop("disabled", true);
    $("#booking_start_date").val("");
    $("#booking_end_date").val("");
    $("#booking_id").val("");
});
