<select name="nomatch_action" id="nomatch_action" class="[% class_name | html %]">
    <option value="create_new" [% IF account.nomatch_action == 'create_new' %]selected="selected"[% END %]>
        Add incoming record</option>
    <option value="ignore" [% IF account.nomatch_action == 'ignore' %]selected="selected"[% END %]>
        Ignore incoming record</option>
</select>
