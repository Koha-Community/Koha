$(document).ready(function(){
    // Display the modal containing checkout renewals details
    $('.checkout_renewals_view').on('click', function(e) {
        e.preventDefault();
        $('#checkoutRenewals #incomplete').html('').hide();
        $('#checkoutRenewals #results').html('').hide();
        $('#checkoutRenewals').modal({show:true});
        var renewals = $(this).data('renewals');
        var checkoutID = $(this).data('issueid');
        $('#checkoutRenewals #retrieving').show();
        $.get({ 'url': '/api/v1/checkouts/'+checkoutID+'/renewals', 'headers': { 'x-koha-embed': 'renewer' } }, function(data) {
            if (data.length < renewals) {
                $('#checkoutRenewals #incomplete').append(renewed_prop.format(data.length, renewals)).show();
            }
            var items = data.map(function(item) {
                return createLi(item);
            });
            $('#checkoutRenewals #retrieving').hide();
            $('#checkoutRenewals #results').append(items).show();
        });
    });
    function createLi(renewal) {
        return '<li><span style="font-weight:bold">' + $datetime(renewal.timestamp) + '</span> ' + renewed + ' <span style="font-weight:bold">' + $patron_to_html(renewal.renewer) + '</span></li>';
    }
});
