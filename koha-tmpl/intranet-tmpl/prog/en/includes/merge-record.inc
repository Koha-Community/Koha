[% BLOCK sourcetab %]
    <div id="tabrecord[% recordnumber %]">
    [% IF ( records ) %]

        <div class="record">
        <ul id="ulrecord[% recordnumber %]">
        [% FOREACH record IN records %]
            [% FOREACH fiel IN record.field %]
            <li id="k[% fiel.key %]">
                [% IF (defaultrecord) %]
                    <input type="checkbox" checked="checked" class="fieldpick" id="rec_[% recordnumber %]_[% fiel.key %]" />
                [% ELSE %]
                    <input type="checkbox" class="fieldpick" id="rec_[% recordnumber %]_[% fiel.key %]" />
                [% END %]
                <span class="field">[% fiel.tag %]</span>

                <input type="hidden" name="tag_[% fiel.tag %]_indicator1_[% fiel.key %]" value="[% fiel.indicator1 %]" />
                <input type="hidden" name="tag_[% fiel.tag %]_indicator2_[% fiel.key %]" value="[% fiel.indicator2 %]" />
                [% IF ( fiel.value ) %] / [% fiel.value %]
                <input type="hidden" name="tag_[% fiel.tag %]_code_00_[% fiel.key %]" value="00" />
                <input type="hidden" name="tag_[% fiel.tag %]_subfield_00_[% fiel.key %]" value="[% fiel.value %]" />
                [% END %]

                [% IF ( fiel.subfield ) %]
                <ul>
                    [% FOREACH subfiel IN fiel.subfield %]
                    <li id="k[% subfiel.subkey %]">
                        [% IF (defaultrecord) %]
                            <input type="checkbox" checked="checked" class="subfieldpick" id="rec_[% recordnumber %]_[% subfiel.subkey %]" />
                        [% ELSE %]
                            <input type="checkbox" class="subfieldpick" id="rec_[% recordnumber %]_[% subfiel.subkey %]" />
                        [% END %]
                        <span class="subfield">[% subfiel.subtag %]</span> / [% subfiel.value %]
                    <input type="hidden" name="tag_[% subfiel.tag %]_code_[% subfiel.subtag %]_[% subfiel.key %]_[% subfiel.subkey %]" value="[% subfiel.subtag %]" />
                    <input type="hidden" name="tag_[% subfiel.tag %]_subfield_[% subfiel.subtag %]_[% subfiel.key %]_[% subfiel.subkey %]" value="[% subfiel.value |html%]" />
                    </li>
                    [% END %]
                </ul>
                [% END %]
            [% END %]
            </li>
        [% END %]
        </ul>
        </div><!-- /div.record -->
    [% END %]
    </div><!-- /div#tabrecord[% recordnumber %] -->
[% END %]
[% BLOCK mergejs %]
    // Creating tabs
    $("#tabs").tabs();

    // Toggle a field / subfield
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
            repeatable = tagslib[field][subfield].repeatable; // Note : we can't use the dot notation here (tagslib.021) because the key is a number
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
        alert(_("The field is non-repeatable and already exists in the destination record. Therefore, you cannot add it."));
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
                alert(_("This subfield cannot be added: there is no") + " " + field + " " + _("field in the destination record."));
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
[% END %]
[% BLOCK mergesource %]
<div id="tabs" class="toptabs">
<h2>Source records</h2>
    <ul>
    <li><a href="#tabrecord1">[% recordid1 %]</a></li>
    <li><a href="#tabrecord2">[% recordid2 %]</a></li>
    </ul>
    [% PROCESS sourcetab records=record1 recordnumber=1 defaultrecord=1 %]
    [% PROCESS sourcetab records=record2 recordnumber=2 defaultrecord=0 %]
</div> <!-- // #tabs -->
[% END %]
[% BLOCK mergetarget %]
<div id="result">
    <h2>Destination record</h2>
    <div style="border:1px solid #E8E8E8;padding:1em;margin-top:2em;">
        <ul id="resultul">
        [% FOREACH record IN record1 %]
            [% FOREACH fiel IN record.field %]<li id="k[% fiel.key %]">
                <span class="field">[% fiel.tag %]</span>
                <input type="hidden" name="tag_[% fiel.tag %]_indicator1_[% fiel.key %]" value="[% fiel.indicator1 %]" />
                <input type="hidden" name="tag_[% fiel.tag %]_indicator2_[% fiel.key %]" value="[% fiel.indicator2 %]" />
                [% IF ( fiel.value ) %] /
                    [% fiel.value %]
                    <input type="hidden" name="tag_[% fiel.tag %]_code_00_[% fiel.key %]" value="00" />
                    <input type="hidden" name="tag_[% fiel.tag %]_subfield_00_[% fiel.key %]" value="[% fiel.value |html%]" />
                [% END %]

                [% IF ( fiel.subfield ) %]
                    <ul>
                        [% FOREACH subfiel IN fiel.subfield %]
                            <li id="k[% subfiel.subkey %]">
                                <span class="subfield">[% subfiel.subtag %]</span> / [% subfiel.value %]
                                <input type="hidden" name="tag_[% subfiel.tag %]_code_[% subfiel.subtag %]_[% subfiel.key %]_[% subfiel.subkey %]" value="[% subfiel.subtag %]" />
                                <input type="hidden" name="tag_[% subfiel.tag %]_subfield_[% subfiel.subtag %]_[% subfiel.key %]_[% subfiel.subkey %]" value="[% subfiel.value |html%]" />
                            </li>
                        [% END %]
                    </ul>
                [% END %]
            </li>[% END %]
        [% END %]
        </ul>
    </div>
</div> <!-- // #result -->
[% END %]
