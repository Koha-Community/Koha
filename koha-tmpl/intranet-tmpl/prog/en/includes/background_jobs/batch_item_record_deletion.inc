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
                No items deleted.
            [% END %]
        </div>

        [% IF report.not_deleted_itemnumbers.size %]
            <div class="dialog error">
                [% report.not_deleted_itemnumbers.size | html %] item(s) could not be deleted: [% FOREACH not_deleted_itemnumber IN report.not_deleted_itemnumbers %][% not_deleted_itemnumber | html %] [% END %]
            </div>
        [% END %]

        [% IF job.status == 'cancelled' %]
            <div class="dialog error">
                The job has been cancelled before it finished.
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
                <i class="fa fa-warning warn"></i>
            [% ELSIF m.type == 'error' %]
                <i class="fa fa-exclamation error"></i>
            [% END %]
            [% SWITCH m.code %]
                [% CASE 'item_not_deleted' %]
                    Item with barcode <a href="/cgi-bin/koha/catalogue/moredetail.pl?biblionumber=[% m.biblionumber | uri %]&itemnumber=[% m.itemnumber | uri %]">[% m.barcode | html %]</a> cannot be deleted:
                    [% SWITCH m.reason %]
                        [% CASE "book_on_loan" %]Item is checked out
                        [% CASE "not_same_branch" %]Item does not belong to your library
                        [% CASE "book_reserved" %]Item has a waiting hold
                        [% CASE "linked_analytics" %]Item has linked analytics
                        [% CASE "last_item_for_hold" %]Last item for bibliographic record with biblio-level hold on it
                        [% CASE %]Unknown reason '[% m.reason | html %]'
                    [% END %]
                [% CASE %]Unknown message '[% m.code | html %]'
            [% END %]
        </div>
    [% END %]
[% END %]

[% BLOCK js %]
[% END %]
