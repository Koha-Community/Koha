jQuery(document).ready(function(){
    vetumaRequestSent = false;
    jQuery('.vetuma-request-init').on('click', function(){
        if(!vetumaRequestSent){
            vetumaRequestSent = true;

            jQuery(this).toggleClass('active');

            jQuery.ajax({
                url: vetumaRequestInitAjaxUrl, // The URL for the request set in the view.
                data: {
                    'requested_amount': requestedAmount
                },
                type: "POST",

                success: function( data ) {
                    if(!jQuery('#vetuma-request').length){
                        jQuery('body').append(data);
                        jQuery('#vetuma-request').submit();
                    }
                },
                error: function( xhr, status, errorThrown ) {
                console.log(status);

                },
                complete: function( xhr, status ) {
                }
            });
        }
    });

});
