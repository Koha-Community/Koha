$(document).ready(function() {
    $('#ticketDetailsModal').on('show.bs.modal', function(event) {
        let modal = $(this);
        let button = $(event.relatedTarget);
        let ticket_id = button.data('concern');
        let resolved  = button.data('resolved');
        modal.find('.modal-footer input').val(ticket_id);

        if ( resolved ) {
            $('#resolveTicket').hide();
        } else {
            $('#resolveTicket').show();
        }

        let detail = $('#detail_' + ticket_id).text();

        // Display ticket details
        let display = '<div class="list-group">';
        display += '<div class="list-group-item">';
        display += '<span class="wrapfix">' + detail + '</span>';
        display += '</div>';
        display += '<div id="concern-updates" class="list-group-item">';
        display += '<span>' + __("Loading updates . . .") + '</span>';
        display += '</div>';
        display += '</div>';

        let details = modal.find('#concern-details');
        details.html(display);

        // Load any existing updates
        $.ajax({
            url: "/api/v1/tickets/" + ticket_id + "/updates",
            method: "GET",
            headers: {
                "x-koha-embed": "user"
            },
        }).success(function(data) {
            let updates_display = $('#concern-updates');
            let updates = '';
            data.forEach(function(item, index) {
                if ( item.public ) {
                    updates += '<div class="list-group-item list-group-item-success">';
                    updates += '<span class="pull-right">' + __("Public") + '</span>';
                }
                else {
                    updates += '<div class="list-group-item list-group-item-warning">';
                    updates += '<span class="pull-right">' + __("Private") + '</span>';
                }
                updates += '<span class="wrapfix">' + item.message + '</span>';
                updates += '<span class="clearfix">' + $patron_to_html(item.user, {
                    display_cardnumber: false,
                    url: true
                }) + ' (' + $datetime(item.date) + ')</span>';
                updates += '</div>';
            });
            updates_display.html(updates);
        }).error(function() {

        });

        // Clear any previously entered update message
        $('#update_message').val('');
        $('#public').prop( "checked", false );
    });

    $('#ticketDetailsModal').on('click', '#updateTicket', function(e) {
        let ticket_id = $('#ticket_id').val();
        let params = {
            'public': $('#public').is(":checked"),
            message: $('#update_message').val(),
            user_id: logged_in_user_borrowernumber
        };

        $('#comment-spinner').show();

        $.ajax({
            url: "/api/v1/tickets/" + ticket_id + "/updates",
            method: "POST",
            data: JSON.stringify(params),
            ontentType: "application/json; charset=utf-8"
        }).success(function() {
            $('#comment-spinner').hide();
            $('#ticketDetailsModal').modal('hide');
            $('#table_concerns').DataTable().ajax.reload(function(data) {
                $("#concern_action_result_dialog").hide();
                $("#concern_delete_success").html(__("Concern #%s updated successfully.").format(ticket_id)).show();
            });
        }).error(function() {
            $("#concern_update_error").html(__("Error resolving concern #%s. Check the logs.").format(ticket_id)).show();
        });
    });

    $('#ticketDetailsModal').on('click', '#resolveTicket', function(e) {
        let ticket_id = $('#ticket_id').val();
        let params = {
            'public': $('#public').is(":checked"),
            message: $('#update_message').val(),
            user_id: logged_in_user_borrowernumber,
            state: 'resolved'
        };

        $('#resolve-spinner').show();

        $.ajax({
            url: "/api/v1/tickets/" + ticket_id + "/updates",
            method: "POST",
            data: JSON.stringify(params),
            ontentType: "application/json; charset=utf-8"
        }).success(function() {
            $('#resolve-spinner').hide();
            $("#ticketDetailsModal").modal('hide');
            $('#table_concerns').DataTable().ajax.reload(function(data) {
                $("#concern_action_result_dialog").hide();
                $("#concern_delete_success").html(__("Concern #%s updated successfully.").format(ticket_id)).show();
            });
        }).error(function() {
            $("#concern_update_error").html(__("Error resolving concern #%s. Check the logs.").format(ticket_id)).show();
        });
    });
});
