[% IF patron_messages.filter_by_unread.count OR opacnote %]
    <div class="alert alert-info">
        <h3>Messages for you</h3>
        <ul>
            [% FOREACH message IN patron_messages.filter_by_unread %]
                <li>
                    <strong>[% message.message | html | html_line_break %]</strong><br />
                    &nbsp;&nbsp;&nbsp;<em>Written on [% message.message_date | $KohaDates %] by [% Branches.GetName(message.branchcode) | html %]</em>
                </li>
                [% IF sco != "true" %]
                    <form id="dismiss-message-form" class="d-print-none" action="/cgi-bin/koha/opac-dismiss-message.pl" method="post">
                        [% INCLUDE 'csrf-token.inc' %]
                        <input type="hidden" name="message_id" value="[% message.message_id | html %]" />
                        <input type="hidden" name="op" value="cud-update" />
                        <button type="submit" class="dismiss-message-button btn btn-primary"><i class="fa fa-trash" aria-hidden="true"></i> Dismiss</button>
                    </form>
                [% END %]
            [% END %]

            [% IF ( opacnote ) %]<li>[% opacnote | html | html_line_break %]</li>[% END %]
        </ul>
    </div>
[% END %]
