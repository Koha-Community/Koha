[% USE Koha %]
[% PROCESS 'i18n.inc' %]
[% PROCESS "ill/backends/Standard/shared/form_input_helpers.inc" %]
[% IF whole.error %]
    [% IF whole.status == 'missing_identifier' %]
        <div class="alert alert-warning"> <strong>Please note:</strong> Mandatory field Identifier is missing. </div>
    [% ELSIF whole.status == 'missing_type' %]
        <div class="alert alert-warning"> <strong>Please note:</strong> Type is a mandatory field. </div>
    [% ELSIF whole.status == 'missing_unauth_data' %]
        <div class="alert alert-warning"> <strong>Please note:</strong> Patron data (first name, last name and e-mail) are mandatory fields. </div>
    [% ELSIF whole.status == 'missing_branch' %]
        <div class="alert alert-warning"> <strong>Please note:</strong> Library is a mandatory field. </div>
    [% ELSIF whole.status == 'invalid_borrower' %]
        <div class="alert alert-warning"> <strong>Please note:</strong> The patron details you entered are invalid. </div>
    [% ELSIF whole.status == 'invalid_branch' %]
        <div class="alert alert-warning"> <strong>Please note:</strong> The library you chose is invalid. </div>
    [% ELSIF whole.status == 'failed_captcha' %]
        <div class="alert alert-warning">You typed in the wrong characters in the box before submitting. Please try again.</div>
    [% ELSE %]
        <p>Unhandled error</p>
    [% END %]
[% END %]
[% SET opac = whole.value.other.opac %]

[% IF whole.stage == "form" %]
    <h2>Create an ILL request</h2>
    <form id="create_form" method="POST" action="">
        [% INCLUDE 'csrf-token.inc' %]
        <fieldset class="rows">
            <legend>Patron options</legend>
            <ol>
                [% IF unauthenticated_ill && !logged_in_user %]
                    [% PROCESS ill_text_input_field required = 1 id = 'unauthenticated_first_name' label = t('First name') value = whole.value.other.unauthenticated_first_name %]
                    [% PROCESS ill_text_input_field required = 1 id = 'unauthenticated_last_name' label = t('Last name') value = whole.value.other.unauthenticated_last_name %]
                    [% PROCESS ill_text_input_field required = 1 id = 'unauthenticated_email' label = t('E-mail address') value = whole.value.other.unauthenticated_email %]
                [% END %]
                [% WRAPPER ill_select_field required = 1 id = 'branchcode' label = t('Destination library') %]
                    <option value=""></option>
                    [% FOREACH branch IN branches %]
                        [% IF whole.value.other.branchcode && branch.branchcode == whole.value.other.branchcode %]
                            <option value="[% branch.branchcode | html %]" selected="selected"> [% branch.branchname | html %] </option>
                        [% ELSE %]
                            <option value="[% branch.branchcode | html %]"> [% branch.branchname | html %] </option>
                        [% END %]
                    [% END %]
                [% END #ill_select_field %]
            </ol>
        </fieldset>
        <fieldset class="rows">
            <legend>General details</legend>
            <ol id="general-standard-fields">
                [% WRAPPER ill_select_field required = 1 id = 'type' label = t('Type') %]
                    <option value=""></option>
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
                [% END #ill_select_field %]
            </ol>
        </fieldset>
        [% type = whole.value.other.type %]
        [% IF type %]
            [% INCLUDE "ill/backends/Standard/shared/forms/${type}.inc" %]
        [% END %]
        [% INCLUDE "ill/backends/Standard/shared/custom_fields.inc" %]
        [% IF whole.value.other.type && unauthenticated_ill && !logged_in_user %]
            <fieldset class="rows" id="illrequest_captcha">
                <legend>Verification</legend>
                <ol>
                    <li>
                        <label for="captcha" class="required">Verification:</label>

                        <input type="text" name="captcha" id="captcha" class="form-control input-fluid" style="text-transform: uppercase;" />
                        <div class="required_label required">Required</div>
                        <input type="hidden" name="captcha_digest" value="[% captcha_digest | html %]" />

                        <span class="hint">Please type the following characters into the preceding box: <strong>[% captcha | html %]</strong></span>
                    </li>
                </ol>
            </fieldset>
        [% END %]
        <fieldset class="action">
            <input id="ill-submit" class="btn btn-primary" type="submit" value="Create" />
            <a class="cancel" href="/cgi-bin/koha/opac-illrequests.pl">Cancel</a>
        </fieldset>
        <input type="hidden" name="op" value="cud-create" />
        <input type="hidden" name="stage" value="form" />
        <input type="hidden" name="backend" value="Standard" />
    </form>
[% ELSE %]
    <p>Unknown stage. This should not have happened. </p>
[% END %]
[% BLOCK backend_jsinclude %]
    <script>
        var core = [ [% whole.core | $raw %] ];
        // <![CDATA[]
        [% INCLUDE "ill/backends/Standard/shared/shared.js" %]
        // ]]>
    </script>
[% END %]
