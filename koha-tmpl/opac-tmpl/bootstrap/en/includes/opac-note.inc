[% IF patron_messages.count OR opacnote %]
    <div class="alert alert-info">
        <h3>Messages for you</h3>
        <ul>
            [% FOREACH message IN patron_messages %]
                <li>
                    <strong>[% message.message | html | html_line_break %]</strong><br>
                    &nbsp;&nbsp;&nbsp;<i>Written on [% message.message_date | $KohaDates %] by [% Branches.GetName(message.branchcode) | html %]</i>
                </li>
            [% END %]

            [% IF ( opacnote ) %]<li>[% opacnote | html | html_line_break %]</li>[% END %]
        </ul>
    </div>
[% END %]
