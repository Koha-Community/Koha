$(document).ready(function() {

    // Pre-populate empty message with template
    $('#addConcernModal').on('show.bs.modal', function (e) {
        $('#addConfirm').prop('disabled', false);
        let concern_body = $('#concern_body');
        if ( concern_body.val() === "" ) {
            let template = $('#concern_template').text();
            concern_body.val(template);
        }
    });

    $('#addConcernModal').on('click', '#addConfirm', function(e) {
        let concern_title = $('#concern_title').val();
        let concern_body = $('#concern_body').val();
        let biblio_id = $('#concern_biblio').val();
        let reporter_id = $('#concern_reporter').val();

        let params = {
            title: concern_title,
            body: concern_body,
            biblio_id: biblio_id,
            reporter_id: logged_in_user_borrowernumber,
        };

        $('#concern-submit-spinner').show();
        $('#addConfirm').prop('disabled', true);

        $.ajax({
            url: '/api/v1/tickets',
            type: 'POST',
            data: JSON.stringify(params),
            success: function(data) {
                $('#concern-submit-spinner').hide();
                $('#addConcernModal').modal('hide');
                $('#concern_body').val('');
                $('#concern_title').val('');
                $('#toolbar').before('<div class="alert alert-success">Your concern was sucessfully submitted.</div>');
                if ($.fn.dataTable.isDataTable("#table_concerns")) {
                    $("#table_concerns").DataTable().ajax.reload();
                }
            },
            error: function(data) {
                $('#concern-submit-spinner').hide();
                $('#addConcernModal').modal('hide');
                $('#toolbar').before('<div class="alert alert-error">There was an error when submitting your concern, please contact a librarian.</div>');
            },
            contentType: "json"
        });
    });
});
