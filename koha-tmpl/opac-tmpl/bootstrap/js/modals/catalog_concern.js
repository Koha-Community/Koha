$(document).ready(function() {

    // Detect that we were redirected here after login and re-open modal
    let urlParams = new URLSearchParams(window.location.search);
    if (urlParams.has('modal')) {
        let modal = urlParams.get('modal');
        history.replaceState && history.replaceState(
            null, '', location.pathname + location.search.replace(/[\?&]modal=[^&]+/, '').replace(/^&/, '?')
        );
        if (modal == 'concern') {
            $("#addConcernModal").modal('show');
        }
    }

    $('#addConcernModal').on('show.bs.modal', function(e) {
        // Redirect to login modal if not logged in
        if (logged_in_user_id === "") {
            $('#modalAuth').append('<input type="hidden" name="return" value="' + window.location.pathname + window.location.search + '&modal=concern" />');
            $('#loginModal').modal('show');
            return false;
        }

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

        params = {
            title: concern_title,
            body: concern_body,
            biblio_id: biblio_id,
            reporter_id: reporter_id,
        };

        $('#concern-submit-spinner').show();
        $('#addConfirm').prop('disabled', true);
        $.ajax({
            url: '/api/v1/public/tickets',
            type: 'POST',
            data: JSON.stringify(params),
            success: function(data) {
                $('#concern-submit-spinner').hide();
                $('#addConcernModal').modal('hide');
                $('#concern_body').val('');
                $('#concern_title').val('');
                $('h1:first').before('<div class="alert alert-success">Your concern was sucessfully submitted.</div>');
            },
            error: function(data) {
                $('#concern-submit-spinner').hide();
                $('#addConcernModal').modal('hide');
                $('h1:first').before('<div class="alert alert-error">There was an error when submitting your concern, please contact a librarian.</div>');
            },
            contentType: "json"
        });
    });
});
