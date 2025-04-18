[% IF ( class_name ) %]
    <select name="nomatch_action" id="nomatch_action" class="[% class_name | html %]">
[% ELSE %]
    <select name="nomatch_action" id="nomatch_action">
[% END %]
    [% IF ( action == 'create_new' ) %]
        <option value="create_new" selected="selected">
    [% ELSE %]
        <option value="create_new">
    [% END %]
        Add incoming record</option>
    [% IF ( action == 'ignore' ) %]
        <option value="ignore" selected="selected">
    [% ELSE %]
        <option value="ignore">
    [% END %]
        Ignore incoming record</option>
    </select>
