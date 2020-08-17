/* global __ */
$(document).ready(function(){
    $("#add_field_form").hide();
    $("#new_search_field").on("click",function(e){
        e.preventDefault();
        $("#add_field_form").show();
        $(".dialog").hide();
        $("#search_fields_list,#toolbar").hide();
    });
    $(".cancel").on("click",function(e){
        e.preventDefault();
        $("#add_field_form").hide();
        $(".dialog").show();
        $("#search_fields_list,#toolbar").show();
    });
    $(".field-delete").on("click",function(){
        $(this).parent().parent().addClass("highlighted-row");
        if (confirm( __("Are you sure you want to delete this field?") )) {
            return true;
        } else {
            $(this).parent().parent().removeClass("highlighted-row");
            return false;
        }
    });
});
