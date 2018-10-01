function init() {
    $('#ajax_status').hide();
    $('#ajax_saving_msg').hide();
    $('#ajax_saving_icon').hide();
    $('#ajax_success_icon').hide();
    $('#ajax_failed_icon').hide();
    $('#ajax_failed_msg').hide();
}

$(document).ready(function() {
    var apiEndpoint = '/api/v1/rotas/';
    init();
    $('#sortable_stages').sortable({
        handle: '.drag_handle',
        placeholder: 'drag_placeholder',
        update: function(event, ui) {
            init();
            $('#sortable_stages').sortable('disable');
            var rotaId = document.getElementById('sortable_stages').dataset.rotaId;
            $('#ajax_saving_msg').text(
                document.getElementById('ajax_status').dataset.savingMsg
            );
            $('#ajax_saving_icon').show();
            $('#ajax_saving_msg').show();
            $('#ajax_status').fadeIn();
            var stageId = ui.item[0].id.replace(/^stage_/, '');
            var newIndex = ui.item.index();
            var newPosition = newIndex + 1;
            $.ajax({
                method: 'PUT',
                url: apiEndpoint + rotaId + '/stages/' + stageId + '/position',
                processData: false,
                contentType: 'application/json',
                data: newPosition
            })
            .done(function(data) {
                $('#ajax_success_msg').text(
                    document.getElementById('ajax_status').dataset.successMsg
                );
                $('#ajax_saving_icon').hide();
                $('#ajax_success_icon').show();
                $('#ajax_success_msg').show();
                setTimeout(
                    function() {
                        $('#ajax_status').fadeOut();
                    },
                    700
                );
            })
            .fail(function(jqXHR, status, error) {
                $('#ajax_failed_msg').text(
                    document.getElementById('ajax_status').dataset.failedMsg +
                    error
                );
                $('#ajax_saving_icon').hide();
                $('#ajax_failed_icon').show();
                $('#ajax_failed_msg').show();
                $('#sortable_stages').sortable('cancel');
            })
            .always(function() {
                $('#sortable_stages').sortable('enable');
            })
        }
    });
});
