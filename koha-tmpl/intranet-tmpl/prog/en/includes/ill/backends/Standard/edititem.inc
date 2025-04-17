[% USE raw %]
[% PROCESS "ill/backends/Standard/shared/form_input_helpers.inc" %]
[% IF whole.error %]
    [% IF whole.status == 'missing_type' %]
        <p><em>Please note:</em> Mandatory field 'type' is missing.</p>
    [% ELSE %]
        <p>Unhandled error</p>
    [% END %]
[% END %]

[% IF whole.stage == "form" %]
    <h2>Edit a manual ILL request</h2>
    <form id="standard_edit_form" method="POST" action="">
        [% INCLUDE 'csrf-token.inc' %]
        <fieldset class="rows">
            <legend>General details</legend>
            <ol id="general-standard-fields">
                <li>
                    <label class="required" for="type">Type:</label>
                    <select name="type" id="type">
                        <option value="" />
                        [% IF whole.value.other.type.lower == "book" %]
                            <option value="book" selected="selected">Book</option>
                        [% ELSE %]
                            <option value="book">Book</option>
                        [% END %]
                        [% IF whole.value.other.type.lower == "chapter" %]
                            <option value="chapter" selected="selected">Chapter</option>
                        [% ELSE %]
                            <option value="chapter">Chapter</option>
                        [% END %]
                        [% IF whole.value.other.type.lower == "journal" %]
                            <option value="journal" selected="selected">Journal</option>
                        [% ELSE %]
                            <option value="journal">Journal</option>
                        [% END %]
                        [% IF whole.value.other.type.lower == "article" %]
                            <option value="article" selected="selected">Journal article</option>
                        [% ELSE %]
                            <option value="article">Journal article</option>
                        [% END %]
                        [% IF whole.value.other.type.lower == "thesis" %]
                            <option value="thesis" selected="selected">Thesis</option>
                        [% ELSE %]
                            <option value="thesis">Thesis</option>
                        [% END %]
                        [% IF whole.value.other.type.lower == "conference" %]
                            <option value="conference" selected="selected">Conference</option>
                        [% ELSE %]
                            <option value="conference">Conference</option>
                        [% END %]
                        [% IF whole.value.other.type.lower == "dvd" %]
                            <option value="dvd" selected="selected">DVD</option>
                        [% ELSE %]
                            <option value="dvd">DVD</option>
                        [% END %]
                        [% IF whole.value.other.type.lower == "other" %]
                            <option value="other" selected="selected">Other</option>
                        [% ELSE %]
                            <option value="other">Other</option>
                        [% END %]
                        [% IF whole.value.other.type.lower == "resource" %]
                            <option value="resource" selected="selected">Generic resource</option>
                        [% ELSE %]
                            <option value="resource">Generic resource</option>
                        [% END %]
                    </select>
                </li>
            </ol>
        </fieldset>
        [% type = whole.value.other.type %]
        [% IF type %]
            [% INCLUDE "ill/backends/Standard/shared/forms/${type}.inc" %]
        [% END %]
        [% INCLUDE "ill/backends/Standard/shared/custom_fields.inc" %]
        <fieldset class="action">
            <input id="ill-submit" class="btn btn-primary" type="submit" value="Update" />
            <a class="cancel" href="/cgi-bin/koha/ill/ill-requests.pl">Cancel</a>
        </fieldset>
        <input type="hidden" name="illrequest_id" value="[% whole.value.other.illrequest_id | html %]" />
        <input type="hidden" name="op" value="cud-edititem" />
        <input type="hidden" name="stage" value="form" />
        <input type="hidden" name="backend" value="Standard" />
    </form>
    [% BLOCK backend_jsinclude %]
        <script>
            var core = [ [% whole.core | $raw %] ];
            // <![CDATA[]
            [% INCLUDE "ill/backends/Standard/shared/shared.js" %]
            // ]]>
        </script>
    [% END %]
[% ELSE %]
    <p>Unknown stage. This should not have happened. </p>
[% END %]
