$(document).ready(function() {
    $('#partners').change(function() {
        var selected = [];
        $('#partners option:selected').each(function() {
            selected.push($(this).data('partner-id'));
        });
        if (selected.length > 0) {
            $('#generic_confirm_search').css('visibility', 'initial');
        } else {
            $('#generic_confirm_search').css('visibility', 'hidden');
        }
        $('#service_id_restrict').
            attr('data-service_id_restrict_ids', selected.join('|'));
    });
    $('#generic_confirm_search').click(function(e) {
        $('#partnerSearch').modal({show:true});
    });
    $('#partnerSearch').on('show.bs.modal', function() {
        doSearch();
    });
    $('#partnerSearch').on('hide.bs.modal', function() {
        $.fn.dataTable.tables({ api: true }).destroy();
    });
});
