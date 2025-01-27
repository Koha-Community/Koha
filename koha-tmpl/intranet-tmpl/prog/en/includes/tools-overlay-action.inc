<select name="overlay_action" id="overlay_action" class="[% class_name | html %]">
    <option value="replace" [% IF account.overlay_action == 'replace' %]selected="selected"[% END %]> Replace existing record with incoming record</option>
    <option value="create_new" [% IF account.overlay_action == 'create_new' %]selected="selected"[% END %]> Add incoming record</option>
    <option value="ignore" [% IF account.overlay_action == 'ignore' %]selected="selected"[% END %]> Ignore incoming record (its items may still be processed)</option>
</select>
