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
        if (logged_in_user_id === "") {
            $('#modalAuth').append('<input type="hidden" name="return" value="' + window.location.pathname + window.location.search + '&modal=concern" />');
            $('#loginModal').modal('show');
            return false;
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

        $.ajax({
            url: '/api/v1/public/tickets',
            type: 'POST',
            data: JSON.stringify(params),
            success: function(data) {
                $('#addConcernModal').modal('hide');
                $('#concern_body').val('');
            },
            contentType: "json"
        });
    });
});
