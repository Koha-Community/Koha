[% USE KohaSpan %]
[% BLOCK report %]
    [% SET report = job.report %]
    [% IF report %]
        <div class="dialog message">
            [% IF report.deleted_itemnumbers.size %]
                <p>[% report.deleted_itemnumbers.size | html %] item(s) deleted.</p>
                [% IF report.deleted_biblionumbers.size %]
                    <p>[% report.deleted_biblionumbers.size | html %] record(s) deleted.</p>
                [% END %]
            [% ELSE %]
                <p>No items deleted.</p>
            [% END %]
        </div>

        [% IF report.not_deleted_itemnumbers.size %]
            <div class="dialog error">
                [% report.not_deleted_itemnumbers.size | html %] item(s) could not be deleted: [% FOREACH not_deleted_itemnumber IN report.not_deleted_itemnumbers %][% not_deleted_itemnumber | html %] [% END %]
            </div>
        [% END %]

        [% IF job.status == 'cancelled' %]
            <div class="dialog error">
                <span>The job has been cancelled before it finished.</span>
                <a href="/cgi-bin/koha/tools/batchMod.pl" title="New batch item modification">New batch item modification</a>
            </div>
        [% END %]
    [% END %]
[% END %]

[% BLOCK detail %]
    [% FOR m IN job.messages %]
        <div class="dialog message">
            [% IF m.type == 'success' %]
                <i class="fa fa-check success"></i>
            [% ELSIF m.type == 'warning' %]
                <i class="fa-solid fa-triangle-exclamation warn"></i>
            [% ELSIF m.type == 'error' %]
                <i class="fa fa-exclamation error"></i>
            [% END %]
            [% SWITCH m.code %]
                [% CASE 'item_not_deleted' %]
                    [% item_link = BLOCK %]<a href="/cgi-bin/koha/catalogue/moredetail.pl?biblionumber=[% m.biblionumber | uri %]&itemnumber=[% m.itemnumber | uri %]">[% m.barcode | html %]</a>[% END %]
                    <span>Item with barcode [% item_link | $raw | $KohaSpan%] cannot be deleted:</span>
                    [% SWITCH m.reason %]
                        [% CASE "book_on_loan" %]<span>Item is checked out</span>
                        [% CASE "not_same_branch" %]<span>Item does not belong to your library</span>
                        [% CASE "book_reserved" %]<span>Item has a waiting hold</span>
                        [% CASE "linked_analytics" %]<span>Item has linked analytics</span>
                        [% CASE "last_item_for_hold" %]<span>Last item for bibliographic record with biblio-level hold on it</span>
                        [% CASE %]<span>Unknown reason '[% m.reason | html %]'</span>
                    [% END %]
                [% CASE %]<span>Unknown message '[% m.code | html %]'</span>
            [% END %]
        </div>
    [% END %]
[% END %]

[% BLOCK js %]
[% END %]
