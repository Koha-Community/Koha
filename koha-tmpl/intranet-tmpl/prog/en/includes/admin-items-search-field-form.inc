[% PROCESS 'html_helpers.inc' %]

<div class="fg-row">
    [% IF field %]
        <div class="fg-label">
            <span class="label">Name: </span>
        </div>
        <div class="fg-input">
            [% field.name | html %]
            <input type="hidden" name="name" value="[% field.name | html %]" />
        </div>
    [% ELSE %]
        <div class="fg-label">
            <label class="required" for="name">Name: </label>
        </div>
        <div class="fg-input">
            <input type="text" name="name" id="name" class="required" required="required" />
        </div>
        <div class="required">Required</div>
    [% END %]
</div>
<div class="fg-row">
    <div class="fg-label">
        <label class="required" for="label">Label: </label>
    </div>
    <div class="fg-input">
        <input type="text" name="label" id="label" value="[% field.label | html %]" class="required" required="required" />
    </div>
    <div class="required">Required</div>
</div>
<div class="fg-row input-sm">
    <div class="fg-label">
        <label class="required" for="tagfield">MARC field: </label>
    </div>
    <div class="fg-input">
        <input type="text" id="tagfield" name="tagfield" maxlength="3" size="3" class="required" pattern="[a-zA-Z0-9]+" required="required" value="[% field.tagfield | html %]" />
    </div>
    <div class="required">Required</div>
</div>
<div class="fg-row input-sm">
    <div class="fg-label">
        <label for="tagsubfield">MARC subfield: </label>
    </div>
    <div class="fg-input">
        <input type="text" id="tagsubfield" name="tagsubfield" pattern="[a-zA-Z0-9]+" maxlength="1" size="1" value="[% field.tagsubfield | html %]" />
    </div>
</div>
<div class="fg-row">
    <div class="fg-label">
        <label for="authorised_values_category">Authorized value category: </label>
    </div>
    <div class="fg-input">
        <select id="authorised_values_category" name="authorised_values_category">
            <option value="">- None -</option>
            [% PROCESS options_for_authorised_value_categories authorised_value_categories => AuthorisedValues.GetCategories( selected => field.authorised_values_category ) %]
        </select>
    </div>
</div>
