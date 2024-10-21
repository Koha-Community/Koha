[% IF ( class_name ) %]
    <select name="overlay_action" id="overlay_action" class="[% class_name | html %]">
[% ELSE %]
    <select name="overlay_action" id="overlay_action">
[% END %]
    [% IF ( account.overlay_action == 'replace' ) %]
        <option value="replace"  selected="selected">
    [% ELSE %]
        <option value="replace">
    [% END %]
        Replace existing record with incoming record</option>
    [% IF ( account.overlay_action == 'create_new' ) %]
        <option value="create_new" selected="selected">
    [% ELSE %]
        <option value="create_new">
    [% END %]
        Add incoming record</option>
    [% IF ( account.overlay_action == 'ignore' ) %]
        <option value="ignore" selected="selected">
    [% ELSE %]
        <option value="ignore">
    [% END %]
        Ignore incoming record (its items may still be processed)</option>
</select>
