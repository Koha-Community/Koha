/*
 * Merging 2 source records into a destination record
 */

/**
 * Check or uncheck a field or subfield in a source record
 * @param pField the checkbox clicked
 */
function toggleField(pField) {

    // Getting the key of the clicked checkbox
    var ckid   = $(pField).attr("id");
    var tab    = ckid.split('_');
    var source = tab[1]; // From which record the click came from
    var key    = tab[2];
    var type   = $(pField).attr("class");

    // Getting field/subfield
    var field;
    var subfield;
    if (type == "subfieldpick") {
        field = $(pField).parent().parent().parent().find("span.field").text();
        subfield = $(pField).parent().find("span.subfield").text();
    } else {
        field = $(pField).parent().find("span.field").text();
    }

    // If the field has just been checked
    if (pField.checked) {

        // We check for repeatability
        var canbeadded = true;
        if (type == "subfieldpick") {
            var repeatable = 1;
            var alreadyexists = 0;
            if (tagslib[field] && tagslib[field][subfield]) {
                // Note : we can't use the dot notation here (tagslib.021) because the key is a number
                repeatable = tagslib[field][subfield].repeatable;
                // TODO : Checking for subfields
            }
        } else {
            if (tagslib[field]) {
                repeatable = tagslib[field].repeatable;
                alreadyexists = $("#resultul span.field:contains(" + field + ")");
                if (repeatable == 0 && alreadyexists.length != 0) {
                    canbeadded = false;
                }
            }
        }

        // If the field is not repeatable, we check if it already exists in the result table
        if (canbeadded == false) {
            alert(MSG_MERGEREC_ALREADY_EXISTS);
            pField.checked = 0;
        } else {

            // Cloning the field or subfield we picked
            var clone = $(pField).parent().clone();

            // Removing the checkboxes from it
            $(clone).find("input.subfieldpick, input.fieldpick").each(function() {
                $(this).remove();
            });

            // If we are a subfield
            if (type == "subfieldpick") {
                // then we need to find who is our parent field...
                fieldkey = $(pField).parent().parent().parent().attr("id");

                // Find where to add the subfield

                // First, check if the field is not already in the destination record
                if ($("#resultul li#" + fieldkey).length > 0) {

                    // If so, we add our field to it
                    $("#resultul li#" + fieldkey + " ul").append(clone);
                } else {

                    // If not, we add the subfield to the first matching field
                    var where = 0;
                    $("#resultul li span.field").each(function() {
                        if (where == 0 && $(this).text() == field) {
                            where = this;
                        }
                    });

                    // If there is no matching field in the destination record
                    if (where == 0) {

                        // TODO:
                        // We select the whole field and removing non-selected subfields, instead of...

                        // Alerting the user
                        alert(MSG_MERGEREC_SUBFIELD_PRE + " " + field + " " + MSG_MERGEREC_SUBFIELD_POST);
                        pField.checked = false;
                    } else {
                        $(where).nextAll("ul").append(clone);
                    }

                }

            } else {
                // If we are a field
                var where = 0;
                // Find where to add the field
                $("#resultul li span.field").each(function() {
                    if (where == 0 && $(this).text() > field) {
                        where = this;
                    }
                });

                $(where).parent().before(clone);
            }
        }
    } else {
        // Else, we remove it from the results tab
        $("ul#resultul li#k" + key).remove();
    }
}

/*
 * Add actions on field and subfields checkboxes
 */
$(document).ready(function(){
    // When a field is checked / unchecked
    $('input.fieldpick').click(function() {
        toggleField(this);
        // (un)check all subfields
        var ischecked = this.checked;
        $(this).parent().find("input.subfieldpick").each(function() {
            this.checked = ischecked;
        });
    });

    // When a field or subfield is checked / unchecked
    $("input.subfieldpick").click(function() {
        toggleField(this);
    });
});
