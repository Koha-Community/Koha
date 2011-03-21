          <select name="nomatch_action" id="nomatch_action">
            [% IF ( nomatch_action_create_new ) %]
                <option value="create_new" selected="selected">
            [% ELSE %]
                <option value="create_new">
            [% END %]
                Add incoming record</option>
            [% IF ( nomatch_action_ignore ) %]
                <option value="ignore" selected="selected">
            [% ELSE %]
                <option value="ignore">
            [% END %]
                Ignore incoming record (its items may still be processed)</option>
        </select>
