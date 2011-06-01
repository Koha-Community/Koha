          <select name="overlay_action" id="overlay_action">
            [% IF ( overlay_action_replace ) %]
                <option value="replace"  selected="selected">
            [% ELSE %]
                <option value="replace">
            [% END %]
                Replace existing record with incoming record</option>
            [% IF ( overlay_action_create_new ) %]
                <option value="create_new" selected="selected">
            [% ELSE %]
                <option value="create_new">
            [% END %]
                Add incoming record</option>
            [% IF ( overlay_action_ignore ) %]
                <option value="ignore" selected="selected">
            [% ELSE %]
                <option value="ignore">
            [% END %]
                Ignore incoming record (its items may still be processed)</option>
        </select>
