$('#placeBookingModal').on('show.bs.modal', function(e) {
    var button = $(e.relatedTarget);
    var biblionumber = button.data('biblionumber');
    var itemnumber = button.data('itemnumber') || 0;
    $('#booking_biblio_id').val(biblionumber);

    // Patron select2
    $("#booking_patron_id").kohaSelect({
        dropdownParent: $(".modal-content", "#placeBookingModal"),
        width: '30%',
        dropdownAutoWidth: true,
        allowClear: true,
        minimumInputLength: 3,
        ajax: {
            url: '/api/v1/patrons',
            delay: 250,
            dataType: 'json',
            data: function(params) {
                var search_term = (params.term === undefined) ? '' : params.term;
                var query = {
                    'q': JSON.stringify({
                        "-or": [{
                                "firstname": {
                                    "-like": search_term + '%'
                                }
                            },
                            {
                                "surname": {
                                    "-like": search_term + '%'
                                }
                            },
                            {
                                "cardnumber": {
                                    "-like": search_term + '%'
                                }
                            }
                        ]
                    }),
                    '_order_by': 'firstname',
                    '_page': params.page,
                };
                return query;
            },
            processResults: function(data, params) {
                var results = [];
                data.results.forEach(function(patron) {
                    results.push({
                        "id": patron.patron_id,
                        "text": escape_str(patron.firstname) + " " + escape_str(patron.surname) + " (" + escape_str(patron.cardnumber) + ")"
                    });
                });
                return {
                    "results": results, "pagination": { "more": data.pagination.more }
                };
            },
        },
        placeholder: "Search for a patron"
    });

    // If passed patron, pre-select
    var patron_id = button.data('patron') || 0;
    if (patron_id) {
        var patron = $.ajax({
            url: '/api/v1/patrons/' + patron_id,
            dataType: 'json',
            type: 'GET'
        });

        $.when(patron).then(
            function(patron){
                var newOption = new Option(escape_str(patron.firstname) + " " + escape_str(patron.surname) + " (" + escape_str(patron.cardnumber) + ")", patron.patron_id, true, true);
                $('#booking_patron_id').append(newOption).trigger('change');
            }
        );
    }

    // Item select2
    $("#booking_item_id").select2({
        dropdownParent: $(".modal-content", "#placeBookingModal"),
        width: '30%',
        dropdownAutoWidth: true,
        minimumResultsForSearch: 20,
        placeholder: "Select item"
    });

    // Adopt flatpickr and update mode
    var periodPicker = $("#period").get(0)._flatpickr;
    periodPicker.set('mode', 'range');

    // Fetch list of bookable items
    var items = $.ajax({
        url: '/api/v1/biblios/' + biblionumber + '/items?bookable=1' + '&_per_page=-1',
        dataType: 'json',
        type: 'GET'
    });

    // Fetch list of existing bookings
    var bookings = $.ajax({
        url: '/api/v1/bookings?biblio_id=' + biblionumber,
        dataType: 'json',
        type: 'GET'
    });

    // Update item select2 and period flatpickr
    $.when(items, bookings).then(
        function(items,bookings){

            // Total bookable items
            var bookable = 0;

            for (item of items[0]) {
                bookable++;
                // Populate item select
                if (!($('#booking_item_id').find("option[value='" + item.item_id + "']").length)) {
                    if (itemnumber && itemnumber == item.item_id) {
                        // Create a DOM Option and pre-select by default
                        var newOption = new Option(escape_str(item.external_id), item.item_id, true, true);
                        // Append it to the select
                        $('#booking_item_id').append(newOption);
                    } else {
                        // Create a DOM Option and de-select by default
                        var newOption = new Option(escape_str(item.external_id), item.item_id, false, false);
                        // Append it to the select
                        $('#booking_item_id').append(newOption);
                    }
                }
            }

            // Redraw select with new options and enable
            $('#booking_item_id').trigger('change');
            $("#booking_item_id").prop("disabled", false);

            // Set disabled dates in datepicker
            periodPicker.config.disable.push( function(date) {

                // set local copy of selectedDates
                let selectedDates = periodPicker.selectedDates;

                // set booked counter
                let booked = 0;

                // reset the unavailable items array
                let unavailable_items = [];

                // reset the biblio level bookings array
                let biblio_bookings = [];

                // disable dates before selected date
                if (selectedDates[0] && selectedDates[0] > date) {
                    return true;
                }

                // iterate existing bookings
                for (booking of bookings[0]) {
                    var start_date = flatpickr.parseDate(booking.start_date);
                    var end_date = flatpickr.parseDate(booking.end_date);

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
                        let total_available = items[0].length - unavailable_items.length - biblio_bookings.length;
                        if (total_available === 0) {
                            return true;
                        }
                    }

                    // patron has not yet selected a start date (start date checks)
                    else if (date <= end_date && date >= start_date) {

                        // same item, disable date
                        if (booking.item_id && booking.item_id == itemnumber) {
                            return true;
                        }

                        // count all clashes, both item and biblio level
                        booked++;
                        if (booked == bookable) {
                            return true;
                        }
                    }
                }
            });

            // Enable flatpickr now we have date function populated
            periodPicker.redraw();
            $("#period_fields :input").prop('disabled', false);

            // Setup listener for item select2
            $('#booking_item_id').on('select2:select', function(e) {
                itemnumber = e.params.data.id ? e.params.data.id : null;

                // redraw pariodPicker taking selected item into account
                periodPicker.redraw();
            });

            // Set onClose for flatpickr
            periodPicker.config.onClose.push(function(selectedDates, dateStr, instance) {

                if ( selectedDates[0] && selectedDates[1] ) {
                    // set form fields from picker
                    let picker_start = new Date(selectedDates[0]);
                    let picker_end = new Date(selectedDates[1]);
                    picker_end.setHours(picker_end.getHours()+23);
                    picker_end.setMinutes(picker_end.getMinutes()+59);
                    $('#booking_start_date').val(picker_start.toISOString());
                    $('#booking_end_date').val(picker_end.toISOString());

                    // set available items in select2
                    var booked_items = bookings[0].filter(function(booking) {
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
                        if ( itemnumber && itemnumber == option.val() ) {
                            console.log("itemnumber defined and equal to value");
                        } else if ( booked_items.some(function(booked_item){
                            return option.val() == booked_item.item_id;
                        }) ) {
                            option.prop('disabled',true);
                        } else {
                            option.prop('disabled',false);
                        }
                    });
                }
            });
        },
        function(jqXHR, textStatus, errorThrown){
            console.log("Fetch failed");
        }
    );
});

$("#placeBookingForm").on('submit', function(e) {
    e.preventDefault();

    var url = '/api/v1/bookings';

    var start_date = $('#booking_start_date').val();
    var end_date = $('#booking_end_date').val();
    var item_id = $('#booking_item_id').val();

    var posting = $.post(
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
        // Update bookings page as required
        if (typeof bookings_table !== 'undefined' && bookings_table !== null) {
            bookings_table.api().ajax.reload();
        }

        // Close modal
        $('#placeBookingModal').modal('hide');

        // Reset form
        $('#booking_patron_id').val(null).trigger('change');
        $('#booking_item_id').val(null).trigger('change');
        $("#period").get(0)._flatpickr.clear();
        $('#booking_start_date').val('');
        $('#booking_end_date').val('');
    });

    posting.fail(function(data) {
        $('#booking_result').replaceWith('<div id="booking_result" class="alert alert-danger">Failure</div>');
    });
});
