$('body').on('click', '.return-claim-tools-resolve', function() {
    let id = $(this).data('return-claim-id');
    let current_lost_status = $(this).data('current-lost-status');

    $('#claims-returned-resolved-modal-id').val(id);
    $("#new_lost_status").val(current_lost_status);
    let selected_option = $("#new_lost_status option:selected");
    $(selected_option).text(__("%s (current status)").format($(selected_option).text()));
    $('#claims-returned-resolved-modal').modal()
});

$(document).on('click', '#claims-returned-resolved-modal-btn-submit', function(e) {
    let resolution = $('#claims-returned-resolved-modal-resolved-code').val();
    let new_lost_status = $('#new_lost_status').val();
    let id = $('#claims-returned-resolved-modal-id').val();

    $('#claims-returned-resolved-modal-btn-submit-spinner').show();
    $('#claims-returned-resolved-modal-btn-submit-icon').hide();

    params = {
        resolution: resolution,
        resolved_by: logged_in_user_borrowernumber,
        new_lost_status: new_lost_status
    };

    $.ajax({
        url: '/api/v1/return_claims/' + id + '/resolve',
        type: 'PUT',
        data: JSON.stringify(params),
        success: function(data) {
            $('#claims-returned-resolved-modal-btn-submit-spinner').hide();
            $('#claims-returned-resolved-modal-btn-submit-icon').show();
            $('#claims-returned-resolved-modal').modal('hide');

            if ( $.fn.dataTable.isDataTable("#return-claims-table") ) {
                $("#return-claims-table").DataTable().ajax.reload();
            }
        },
        contentType: "json"
    });

});
