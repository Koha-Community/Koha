/* global KohaTable columns_settings Sortable */

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
    var sortable = document.getElementById("sortable_stages");
    if( sortable ){
        var sortable_stages = new Sortable( sortable, {
            handle: ".drag_handle",
            ghostClass: "drag_placeholder",
            onUpdate: function(e) {
                init();
                sortable_stages.option("disabled", true );
                var rotaId = document.getElementById('sortable_stages').dataset.rotaId;
                $('#ajax_saving_msg').text(
                    document.getElementById('ajax_status').dataset.savingMsg
                );
                $('#ajax_saving_icon').show();
                $('#ajax_saving_msg').show();
                $('#ajax_status').fadeIn();
                var stageId = e.item.id.replace(/^stage_/, '');
                var newIndex = e.newIndex;
                var newPosition = newIndex + 1;
                $.ajax({
                    method: 'PUT',
                    url: apiEndpoint + rotaId + '/stages/' + stageId + '/position',
                    processData: false,
                    contentType: 'application/json',
                    data: newPosition
                })
                    .done(function() {
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
                        // $('#sortable_stages').sortable('cancel');
                    })
                    .always(function() {
                        sortable_stages.option("disabled", false );
                    });
            }
        });
    }

    KohaTable("stock_rotation_manage_items", {
        "aoColumnDefs": [
            { "bSortable": false, "bSearchable": false, 'aTargets': [ 'NoSort' ] },
            { "sType": "anti-the", "aTargets": [ "anti-the" ] }
        ],
        "sPaginationType": "full",
        "autoWidth": false,
    }, stock_rotation_items_table_settings);

    KohaTable("stock_rotation", {
        "aoColumnDefs": [
            { "bSortable": false, "bSearchable": false, 'aTargets': [ 'NoSort' ] },
            { "sType": "anti-the", "aTargets": [ "anti-the" ] }
        ],
        "sPaginationType": "full",
        "autoWidth": false,
    }, stock_rotation_table_settings);

});
