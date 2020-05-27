[% IF patron_messages.count OR opacnote %]
    <div class="alert alert-info">
        <h3>Messages for you</h3>
        <ul>
            [% FOREACH message IN patron_messages %]
                <li>
                    <strong>[% message.message | html %]</strong><br>
                    &nbsp;&nbsp;&nbsp;<em>Written on [% message.message_date | $KohaDates %] by [% Branches.GetName(message.branchcode) | html %]</em>
                </li>
            [% END %]

            [% IF ( opacnote ) %]<li>[% opacnote | html %]</li>[% END %]
        </ul>
    </div>
[% END %]
