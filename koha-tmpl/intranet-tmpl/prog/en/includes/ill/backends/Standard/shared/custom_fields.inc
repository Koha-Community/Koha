<fieldset class="rows">
    <legend>Custom fields</legend>
    <ol id="standard-fields">
        [% keys = whole.value.other.custom_key.split('\0') %]
        [% values = whole.value.other.custom_value.split('\0') %]
        [% i = 0 %]
        [% FOREACH key IN keys %]
            <li class="form-horizontal">
                [% IF opac %]
                    <input type="text" placeholder="key" class="form-control input-fluid custom-field-input custom-name" name="custom_key" value="[% key | html %]" />
                    <input type="text" placeholder="value" class="form-control input-fluid custom-field-input" name="custom_value" id="custom-value" value="[% values.$i | html %]" />
                [% ELSE %]
                    <input type="text" placeholder="key" class="custom-name" name="custom_key" value="[% key | html %]" />
                    <input type="text" placeholder="value" name="custom_value" id="custom-value" value="[% values.$i | html %]" />
                [% END %]
                <button value="[% i | html %]" name="custom_delete" type="submit" class="btn btn-danger btn-sm delete-new-field"> <span class="fa fa-trash"></span> Delete </button>
            </li>
            [% i = i + 1 %]
        [% END %]
    </ol>
    <div id="custom-warning" style="display:none;margin:1em;" class="error required"></div>
    <button type="button" id="add-new-fields" class="btn btn-default">
        <span class="fa fa-plus"></span>
        Add new field
    </button>
</fieldset>

<style>
    .custom-field-input {
        width: 25%;
        display: inline-block;
        margin-left: 0.5em;
    }
</style>
