<fieldset class="rows">
    <legend>Custom fields</legend>
    <ol id="standard-fields">
        [% keys = whole.value.other.custom_key.split('\0') %]
        [% values = whole.value.other.custom_value.split('\0') %]
        [% i = 0 %]
        [% FOREACH key IN keys %]
            <li class="form-horizontal">
                <input type="text" class="custom-name" name="custom_key" value="[% key %]"><input type="text" name="custom_value" id="custom-value" value="[% values.$i %]">
                <button value="[% i %]" name="custom_delete" type="submit" class="btn btn-danger btn-sm delete-new-field">
                    <span class="fa fa-delete"></span>Delete
                </button></li>
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
