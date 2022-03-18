$(document).ready(function(){
    // Display the modal containing patron renewals details
    $('.patron_renewals_view').on('click', function(e) {
        e.preventDefault();
        $('#patronRenewals #incomplete').html('').hide();
        $('#patronRenewals #results').html('').hide();
        $('#patronRenewals').modal({show:true});
        var renewals = $(this).data('renewals');
        var checkoutID = $(this).data('issueid');
        $('#patronRenewals #retrieving').show();
        $.get({ 'url': '/api/v1/checkouts/'+checkoutID+'/renewals', 'headers': { 'x-koha-embed': 'renewer' } }, function(data) {
            if (data.length < renewals) {
                $('#patronRenewals #incomplete').append(renewed_prop.format(data.length, renewals)).show();
            }
            var items = data.map(function(item) {
                return createLi(item);
            });
            $('#patronRenewals #retrieving').hide();
            $('#patronRenewals #results').append(items).show();
        });
    });
    function createLi(renewal) {
        return '<li><span style="font-weight:bold">' + $datetime(renewal.timestamp) + '</span> ' + renewed + ' <span style="font-weight:bold">' + renewal.renewer.firstname + ' ' + renewal.renewer.surname + '</li>';
    }
});
