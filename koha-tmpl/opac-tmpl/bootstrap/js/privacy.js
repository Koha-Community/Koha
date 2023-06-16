/* global __ confirmDelete */
$(document).ready(function(){
    $('.privacy-confirm-delete').on('click',function(){
        return confirmDelete( __("Warning: Cannot be undone. Please confirm once again") );
    });
});
