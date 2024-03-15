let dataFetched = false;
let bookable_items, bookings, checkouts, booking_id, booking_item_id, booking_patron;

$('#placeBookingModal').on('show.bs.modal', function(e) {

    // Get context
    let button = $(e.relatedTarget);
    let biblionumber = button.data('biblionumber');
    $('#booking_biblio_id').val(biblionumber);

    let patron_id = button.data('patron') || 0;
    booking_item_id = button.data('itemnumber');
    let start_date = button.data('start_date');
    let end_date = button.data('end_date');

    // Get booking id if this is an edit
    booking_id = button.data('booking');
    if (booking_id) {
        $('#placeBookingLabel').html(__("Edit booking"));
        $('#booking_id').val(booking_id);
    } else {
        $('#placeBookingLabel').html(__("Place booking"));
        // Ensure we don't accidentally update a booking
        $('#booking_id').val('');
    }

    // Patron select2
    $("#booking_patron_id").kohaSelect({
        dropdownParent: $(".modal-content", "#placeBookingModal"),
        width: '50%',
        dropdownAutoWidth: true,
        allowClear: true,
        minimumInputLength: 3,
        ajax: {
            url: '/api/v1/patrons',
            delay: 250,
            dataType: 'json',
            headers: {
                "x-koha-embed": "library"
            },
            data: function(params) {
                let q = buildPatronSearchQuery(params.term);
                let query = {
                    'q': JSON.stringify(q),
                    '_page': params.page,
                    '_order_by': '+me.surname,+me.firstname',
                };
                return query;
            },
            processResults: function(data, params) {
                let results = [];
                data.results.forEach(function(patron) {
                    patron.id = patron.patron_id;
                    results.push(patron);
                });
                return {
                    "results": results, "pagination": { "more": data.pagination.more }
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
                        (patron.library ?
                                " <span class=\"ac-library\">" +
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
            return (
                patron.surname + ", " + patron.firstname
            );
        },
        placeholder: __("Search for a patron")
    });

    $('#booking_patron_id').on('select2:select', function (e) {
        booking_patron = e.params.data;
    });

    // Adopt periodPicker
    let periodPicker = $("#period").get(0)._flatpickr;

    if ( !dataFetched ) {

        // Fetch list of bookable items
        let itemsFetch = $.ajax({
            url: '/api/v1/biblios/' + biblionumber + '/items?bookable=1' + '&_per_page=-1',
            dataType: 'json',
            type: 'GET'
        });

        // Fetch list of existing bookings
        let bookingsFetch = $.ajax({
            url: '/api/v1/bookings?biblio_id=' + biblionumber + '&_per_page=-1',
            dataType: 'json',
            type: 'GET'
        });

        // Fetch list of current checkouts
        let checkoutsFetch = $.ajax({
            url: '/api/v1/biblios/' + biblionumber + '/checkouts?_per_page=-1',
            dataType: 'json',
            type: 'GET'
        });

        // Update item select2 and period flatpickr
        $.when(itemsFetch, bookingsFetch, checkoutsFetch).then(
            function(itemsFetch,bookingsFetch, checkoutsFetch){

                // Set variables
                bookable_items = itemsFetch[0];
                bookings = bookingsFetch[0];
                checkouts = checkoutsFetch[0];

                // Merge current checkouts into bookings
                for (checkout of checkouts) {
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

                // Item select2
                $("#booking_item_id").select2({
                    dropdownParent: $(".modal-content", "#placeBookingModal"),
                    width: '50%',
                    dropdownAutoWidth: true,
                    minimumResultsForSearch: 20,
                    placeholder: __("Select item")
                });

                // Update flatpickr mode
                periodPicker.set('mode', 'range');

                // Total bookable items
                let bookable = 0;

                for (item of bookable_items) {
                    bookable++;
                    // Populate item select (NOTE: Do we still need this check for pre-existing select option here?)
                    if (!($('#booking_item_id').find("option[value='" + item.item_id + "']").length)) {
                        // Create a DOM Option and de-select by default
                        let newOption = new Option(escape_str(item.external_id), item.item_id, false, false);
                        // Append it to the select
                        $('#booking_item_id').append(newOption);
                    }
                }

                // Set disable function for periodPicker
                let disableExists = periodPicker.config.disable.filter(f => f.name === 'dateDisable');
                if ( disableExists.length === 0 ) {
                    periodPicker.config.disable.push(function dateDisable(date){

                        // set local copy of selectedDates
                        let selectedDates = periodPicker.selectedDates;

                        // set booked counter
                        let booked = 0;

                        // reset the unavailable items array
                        let unavailable_items = [];

                        // reset the biblio level bookings array
                        let biblio_bookings = [];

                        // disable dates before selected date
                        if (!selectedDates[1] && (selectedDates[0] && selectedDates[0] > date)) {
                            return true;
                        }

                        // iterate existing bookings
                        for (booking of bookings) {

                            // Skip if we're editing this booking
                            if (booking_id && booking_id == booking.booking_id){
                                continue;
                            }

                            let start_date = flatpickr.parseDate(booking.start_date);
                            let end_date = flatpickr.parseDate(booking.end_date);

                            // patron has selected a start date (end date checks)
                            if (selectedDates[0]) {

                                // new booking start date is between existing booking start and end dates
                                if (selectedDates[0] >= start_date && selectedDates[0] <= end_date) {
                                    if (booking.item_id) {
                                        if (unavailable_items.indexOf(booking.item_id) === -1) {
                                            unavailable_items.push(booking.item_id);
                                        }
                                    } else {
                                        if (biblio_bookings.indexOf(booking.booking_id) === -1) {
                                            biblio_bookings.push(booking.booking_id);
                                        }
                                    }
                                }

                                // new booking end date would be between existing booking start and end dates
                                else if (date >= start_date && date <= end_date) {
                                    if (booking.item_id) {
                                        if (unavailable_items.indexOf(booking.item_id) === -1) {
                                            unavailable_items.push(booking.item_id);
                                        }
                                    } else {
                                        if (biblio_bookings.indexOf(booking.booking_id) === -1) {
                                            biblio_bookings.push(booking.booking_id);
                                        }
                                    }
                                }

                                // new booking would span existing booking
                                else if (selectedDates[0] <= start_date && date >= end_date) {
                                    if (booking.item_id) {
                                        if (unavailable_items.indexOf(booking.item_id) === -1) {
                                            unavailable_items.push(booking.item_id);
                                        }
                                    } else {
                                        if (biblio_bookings.indexOf(booking.booking_id) === -1) {
                                            biblio_bookings.push(booking.booking_id);
                                        }
                                    }
                                }

                                // new booking would not conflict
                                else {
                                    continue;
                                }

                                // check that there are available items
                                // available = all bookable items - booked items - booked biblios
                                let total_available = bookable_items.length - unavailable_items.length - biblio_bookings.length;
                                if (total_available === 0) {
                                    return true;
                                }
                            }

                            // patron has not yet selected a start date (start date checks)
                            else if (date <= end_date && date >= start_date) {

                                // same item, disable date
                                if (booking.item_id && booking.item_id == booking_item_id) {
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
                    });
                };

                // Setup listener for item select2
                $('#booking_item_id').on('select2:select', function(e) {
                    booking_item_id = e.params.data.id ? e.params.data.id : null;

                    // redraw pariodPicker taking selected item into account
                    periodPicker.redraw();
                });

                // Set onChange for flatpickr
                let changeExists = periodPicker.config.onChange.filter(f => f.name ==='periodChange');
                if(changeExists.length === 0) {
                    periodPicker.config.onChange.push(function periodChange(selectedDates, dateStr, instance) {
                        // Range set, update hidden fields and set available items
                        if ( selectedDates[0] && selectedDates[1] ) {
                            // set form fields from picker
                            let picker_start = dayjs(selectedDates[0]);
                            let picker_end = dayjs(selectedDates[1]).endOf('day');
                            $('#booking_start_date').val(picker_start.toISOString());
                            $('#booking_end_date').val(picker_end.toISOString());

                            // set available items in select2
                            let booked_items = bookings.filter(function(booking) {
                                let start_date = flatpickr.parseDate(booking.start_date);
                                let end_date = flatpickr.parseDate(booking.end_date);
                                // This booking ends before the start of the new booking
                                if ( end_date <= selectedDates[0] ) {
                                    return false;
                                }
                                // This booking starts after then end of the new booking
                                if ( start_date >= selectedDates[1] ) {
                                    return false;
                                }
                                // This booking overlaps
                                return true;
                            });
                            $("#booking_item_id > option").each(function() {
                                let option = $(this);
                                if ( booking_item_id && booking_item_id == option.val() ) {
                                    option.prop('disabled',false);
                                } else if ( booked_items.some(function(booked_item){
                                    return option.val() == booked_item.item_id;
                                }) ) {
                                    option.prop('disabled',true);
                                } else {
                                    option.prop('disabled',false);
                                }
                            });
                            $('#booking_item_id').trigger('change.select2');
                        }
                        // Range not set, reset field options
                        else {
                            $('#booking_item_id > option').each(function() {
                                $(this).prop('disabled', false);
                            });
                            $('#booking_item_id').trigger('change.select2');
                        }
                    });
                };

                // Enable flatpickr now we have date function populated
                periodPicker.redraw();
                $("#period_fields :input").prop('disabled', false);

                // Redraw select with new options and enable
                $('#booking_item_id').trigger('change');
                $("#booking_item_id").prop("disabled", false);

                // Set the flag to indicate that data has been fetched
                dataFetched = true;

                // Set form values
                setFormValues(patron_id,booking_item_id,start_date,end_date,periodPicker);
            },
            function(jqXHR, textStatus, errorThrown){
                console.log("Fetch failed");
            }
        );
    } else {
        setFormValues(patron_id,booking_item_id,start_date,end_date,periodPicker);
    };
});

function setFormValues(patron_id,booking_item_id,start_date,end_date,periodPicker){

    // If passed patron, pre-select
    if (patron_id) {
        let patronSelect = $('#booking_patron_id');
        let patron = $.ajax({
            url: '/api/v1/patrons/' + patron_id,
            dataType: 'json',
            type: 'GET'
        });

        $.when(patron).done(
            function(patron){

                // clone patron_id to id (select2 expects an id field)
                patron.id = patron.patron_id;
                patron.text = escape_str(patron.surname) + ", " + escape_str(patron.firstname);

                // Add and select new option
                let newOption = new Option(patron.text, patron.id, true, true);
                patronSelect.append(newOption).trigger('change');

                // manually trigger the `select2:select` event
                patronSelect.trigger({
                    type: 'select2:select',
                    params: {
                        data: patron
                    }
                });
            }
        );
    }

    // Set booking start & end if this is an edit
    if ( start_date ) {
        // Allow invalid pre-load so setDate can set date range
        // periodPicker.set('allowInvalidPreload', true);
        // FIXME: Why is this the case.. we're passing two valid Date objects
        let start = new Date(start_date);
        let end = new Date(end_date);

        let dates = [ new Date(start_date), new Date(end_date) ];
        periodPicker.setDate(dates, true);
    }
    // Reset periodPicker, biblio_id may have been nulled
    else {
        periodPicker.redraw();
    };

    // If passed an itemnumber, pre-select
    if (booking_item_id) {
        $('#booking_item_id').val(booking_item_id).trigger('change');
    }
}

$("#placeBookingForm").on('submit', function(e) {
    e.preventDefault();

    let url = '/api/v1/bookings';

    let start_date = $('#booking_start_date').val();
    let end_date = $('#booking_end_date').val();
    let item_id = $('#booking_item_id').val();

    if (!booking_id) {
        let posting = $.post(
            url,
            JSON.stringify({
                "start_date": start_date,
                "end_date": end_date,
                "biblio_id": $('#booking_biblio_id').val(),
                "item_id": item_id != 0 ? item_id : null,
                "patron_id": $('#booking_patron_id').find(':selected').val()
            })
        );

        posting.done(function(data) {
            // Update bookings store for subsequent bookings
            bookings.push(data);

            // Update bookings page as required
            if (typeof bookings_table !== 'undefined' && bookings_table !== null) {
                bookings_table.api().ajax.reload();
            }
            if (typeof timeline !== 'undefined' && timeline !== null) {
                timeline.itemsData.add({
                    id: data.booking_id,
                    booking: data.booking_id,
                    patron: data.patron_id,
                    start: dayjs(data.start_date).toDate(),
                    end: dayjs(data.end_date).toDate(),
                    content: $patron_to_html(booking_patron, {
                        display_cardnumber: true,
                        url: false
                    }),
                    editable: { remove: true, updateTime: true },
                    type: 'range',
                    group: data.item_id ? data.item_id : 0
                });
                timeline.focus(data.booking_id);
            }

            // Update bookings counts
            $('.bookings_count').html(parseInt($('.bookings_count').html(), 10)+1);

            // Close modal
            $('#placeBookingModal').modal('hide');
        });

        posting.fail(function(data) {
            $('#booking_result').replaceWith('<div id="booking_result" class="alert alert-danger">'+_("Failure")+'</div>');
        });
    } else {
        url += '/' + booking_id;
        let putting = $.ajax({
            'method': 'PUT',
            'url': url,
            'data': JSON.stringify({
                "booking_id": booking_id,
                "start_date": start_date,
                "end_date": end_date,
                "biblio_id": $('#booking_biblio_id').val(),
                "item_id": item_id != 0 ? item_id : null,
                "patron_id": $('#booking_patron_id').find(':selected').val()
            })
        });

        putting.done(function(data) {
            update_success = 1;

            // Update bookings store for subsequent bookings
            let target = bookings.find((obj) => obj.booking_id === data.booking_id);
            Object.assign(target,data);

            // Update bookings page as required
            if (typeof bookings_table !== 'undefined' && bookings_table !== null) {
                bookings_table.api().ajax.reload();
            }
            if (typeof timeline !== 'undefined' && timeline !== null) {
                timeline.itemsData.update({
                    id: data.booking_id,
                    booking: data.booking_id,
                    patron: data.patron_id,
                    start: dayjs(data.start_date).toDate(),
                    end: dayjs(data.end_date).toDate(),
                    content: $patron_to_html(booking_patron, {
                        display_cardnumber: true,
                        url: false
                    }),
                    editable: { remove: true, updateTime: true },
                    type: 'range',
                    group: data.item_id ? data.item_id : 0
                });
                timeline.focus(data.booking_id);
            }

            // Close modal
            $('#placeBookingModal').modal('hide');
        });

        putting.fail(function(data) {
            $('#booking_result').replaceWith('<div id="booking_result" class="alert alert-danger">'+__("Failure")+'</div>');
        });
    }
});

$('#placeBookingModal').on('hidden.bs.modal', function (e) {
    $('#booking_patron_id').val(null).trigger('change');
    $('#booking_patron_id').empty();
    $('#booking_item_id').val(0).trigger('change');
    $('#period').get(0)._flatpickr.clear();
    $('#booking_start_date').val('');
    $('#booking_end_date').val('');
    $('#booking_id').val('');
});
