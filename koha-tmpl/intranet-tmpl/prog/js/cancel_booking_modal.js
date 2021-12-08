$('#cancelBookingModal').on('show.bs.modal', function(e) {
    var button = $(e.relatedTarget);
    var booking = button.data('booking');
    $('#cancel_booking_id').val(booking);
});

$("#cancelBookingForm").on('submit', function(e) {
    e.preventDefault();

    var booking_id = $('#cancel_booking_id').val();
    var url = '/api/v1/bookings/'+booking_id;

    var deleting = $.ajax({
        'method': "DELETE",
        'url': url
    });

    deleting.done(function(data) {
        if (bookings_table) {
            bookings_table.api().ajax.reload();
        }
        $('#cancelBookingModal').modal('hide');
    });

    deleting.fail(function(data) {
        $('#cancel_booking_result').replaceWith('<div id="booking_result" class="alert alert-danger">Failure</div>');
    });
});
