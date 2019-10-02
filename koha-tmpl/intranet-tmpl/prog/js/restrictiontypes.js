jQuery.validator.addMethod( "restrictionCode", function(value){
    var ex = Object.keys(existing);
    return (value.length > 0 && ex.indexOf(value.toUpperCase()) > -1) ?
        false :
        true;
}, MSG_DUPLICATE_CODE);

jQuery.validator.addMethod( "restrictionDisplayText", function(value){
    var ex = Object.values(existing).map(function(el) {
        return el.toLowerCase();
    });
    return (value.length > 0 && ex.indexOf(value.toLowerCase()) > -1) ?
        false :
        true;
}, MSG_DUPLICATE_DISPLAY_TEXT);

$(document).ready(function() {
    KohaTable("restriction_types", {
        "aoColumnDefs": [{
            "aTargets": [-1],
            "bSortable": false,
            "bSearchable": false
        }, {
            "aTargets": [0, 1],
            "sType": "natural"
        }, ],
        "aaSorting": [
            [1, "asc"]
        ],
        "sPaginationType": "full",
        "exportColumns": [0,1],
    });

    $("#restriction_form").validate({
        rules: {
            code: {
                required: true,
                restrictionCode: true
            },
            display_text: {
                required: true,
                restrictionDisplayText: true
            }
        },
        messages: {
            code: {
                restrictionCode: MSG_DUPLICATE_CODE
            },
            display_text: {
                restrictionDisplayText: MSG_DUPLICATE_DISPLAY_TEXT
            }
        }
    });
});
