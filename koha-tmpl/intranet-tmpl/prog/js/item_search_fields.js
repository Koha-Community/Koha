/* global _ MSG_ITEM_SEARCH_DELETE_CONFIRM */

jQuery.validator.addMethod("marcfield", function(value, element) {
    return this.optional(element) || /^[0-9a-zA-Z]+$/.test(value);
}, __("Please enter letters or numbers") );

$(document).ready(function(){
    $("#add_field_form").hide();
    $("#new_search_field").on("click",function(e){
        e.preventDefault();
        $("#add_field_form").show();
        $(".dialog").hide();
        $("#search_fields_list,#toolbar").hide();
    });
    $(".hide_form").on("click",function(e){
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

    $("#add_field_form").validate({
        rules: {
            label: "required",
            tagfield: {
                required: true,
                marcfield: true
            },
            tagsubfield: {
                marcfield: true
            }
        }
    });

    $("#edit_search_fields").validate({
        rules: {
            label: "required",
            tagfield: {
                required: true,
                marcfield: true
            },
            tagsubfield: {
                marcfield: true
            }
        }
    });

});
