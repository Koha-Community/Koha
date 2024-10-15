$('#cancelBookingModal').on('show.bs.modal', function(e) {
    var button = $(e.relatedTarget);
    var booking = button.data('booking');
    $('#cancel_booking_id').val(booking);
});

$("#cancelBookingForm").on('submit', function(e) {
    e.preventDefault();

    var booking_id = $('#cancel_booking_id').val();
    var url = '/api/v1/bookings/'+booking_id;

    var cancelling = $.ajax({
        'method': "PATCH",
        'url': url,
        'data': JSON.stringify({"status": "cancelled"}),
        'contentType': "application/json"
    });


    cancelling.done(function(data) {
        cancel_success = 1;
        if (bookings_table) {
            bookings_table.api().ajax.reload();
        }
        if (typeof timeline !== 'undefined') {
            timeline.itemsData.remove(Number(booking_id));
        }
        $('.bookings_count').html(parseInt($('.bookings_count').html(), 10)-1);
        $('#cancelBookingModal').modal('hide');
    });

    cancelling.fail(function(data) {
        $('#cancel_booking_result').replaceWith('<div id="booking_result" class="alert alert-danger">'+__("Failure")+'</div>');
    });
});
