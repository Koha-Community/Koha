[% IF patron_messages.filter_by_unread.count OR opacnote %]
    <div class="alert alert-info">
        <h3>Messages for you</h3>
        <ul>
            [% FOREACH message IN patron_messages.filter_by_unread %]
                <li>
                    <strong>[% message.message | html | html_line_break %]</strong><br>
                    &nbsp;&nbsp;&nbsp;<em>Written on [% message.message_date | $KohaDates %] by [% Branches.GetName(message.branchcode) | html %]</em>
                </li>
                <form id="dismiss-message-form" action="/cgi-bin/koha/opac-dismiss-message.pl" method="post">
                    <input type="hidden" name="message_id" value="[% message.message_id | html %]">
                    <input type="hidden" name="patron_id" value="[% message.borrowernumber | html %]">
                    <button type="submit" class="dismiss-message-button btn btn-primary"><i class="fa fa-trash" aria-hidden="true"></i> Dismiss</button>
                </form>
            [% END %]

            [% IF ( opacnote ) %]<li>[% opacnote | html | html_line_break %]</li>[% END %]
        </ul>
    </div>
[% END %]
