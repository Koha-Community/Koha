[% USE Koha %]
[% PROCESS 'i18n.inc' %]
[% cwd = whole.cwd %]
[% PROCESS "${cwd}/shared-includes/form_input_helpers.inc" %]
[% IF whole.error %]
[% IF whole.status == 'missing_identifier' %]
    <div class="alert alert-warning">
        <strong>Please note:</strong> Mandatory field Identifier is missing.
    </div>
[% ELSIF whole.status == 'missing_type' %]
    <div class="alert alert-warning">
        <strong>Please note:</strong> Type is a mandatory field.
    </div>
[% ELSIF whole.status == 'missing_branch' %]
    <div class="alert alert-warning">
        <strong>Please note:</strong> Library is a mandatory field.
    </div>
[% ELSIF whole.status == 'invalid_borrower' %]
    <div class="alert alert-warning">
        <strong>Please note:</strong> The patron details you entered are invalid.
    </div>
[% ELSIF whole.status == 'invalid_branch' %]
    <div class="alert alert-warning">
        <strong>Please note:</strong> The library you chose is invalid.
    </div>
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
        [% WRAPPER ill_select_field required = 1 id = 'branchcode' label = t('Destination library') %]
          <option value=""></option>
          [% FOREACH branch IN branches %]
            [% IF whole.value.other.branchcode && branch.branchcode == whole.value.other.branchcode %]
            <option value="[% branch.branchcode | html %]" selected="selected">
              [% branch.branchname | html %]
            </option>
            [% ELSE %]
            <option value="[% branch.branchcode | html %]">
              [% branch.branchname | html %]
            </option>
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
      [% INCLUDE "${cwd}/shared-includes/forms/${type}.inc" %]
  [% END %]
  [% INCLUDE "${cwd}/shared-includes/custom_fields.inc" %]
  <fieldset class="action">
    <input id="ill-submit" class="btn btn-primary" type="submit" value="Create"/>
    <a class="cancel" href="/cgi-bin/koha/opac-illrequests.pl">Cancel</a>
  </fieldset>
  <input type="hidden" name="op" value="cud-create" />
  <input type="hidden" name="stage" value="form" />
  <input type="hidden" name="backend" value="Standard" />
</form>

[% ELSE %]
<p>Unknown stage.  This should not have happened.

[% END %]
[% BLOCK backend_jsinclude %]
<script>
    // <![CDATA[]
    [% INCLUDE "${cwd}/shared-includes/shared.js" %]
    // ]]>
</script>
[% END %]