$(document).ready(function(){

    $('.submit-form-link').click(function(e){
        e.preventDefault();
        let form_data = $(this).data();

        form_confirm = form_data.confirmation;
        let confirmation = 1;
        if( form_confirm ){
            delete form_data.confirmation;
            confirmation = confirm( eval(form_confirm) );
        }
        if( !confirmation ){ return false }

        let the_form = $('<form/>');
        if( form_data.method === 'post' ){
            form_data.csrf_token = $('meta[name="csrf-token"]').attr('content');
        }
        the_form.attr('method', form_data.method);
        the_form.attr('action', form_data.action);
        delete form_data.method;
        delete form_data.action;
        $.each( form_data, function( key, value){
            the_form.append( $('<input/>',{
                type: "hidden",
                name: key,
                value: value,
                })
            );
        });
        $('body').append( the_form );
        the_form.submit();
    });
});
