[% USE Koha %]

[% BLOCK report %]
    [% SET report = job.report %]
    [% IF report %]
        <div class="dialog message">
            [% IF report.modified_itemnumbers.size %]
                [% report.modified_itemnumbers.size | html %] item(s) modified (with [% report.modified_fields | html %] field(s) modified).
            [% ELSE %]
                No items modified.
            [% END %]

            [% IF job.status == 'cancelled' %]The job has been cancelled before it finished.[% END %]
            <a href="/cgi-bin/koha/tools/batchMod.pl" title="New batch item modification">New batch item modification</a>
        </div>
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
            [% CASE %]Unknown message '[% m.code | html %]'
            [% END %]
        </div>
    [% END %]

    [% IF too_many_items_display %]
        <p>Too many items ([% too_many_items_display | html %]): You have edited more than [% Koha.Preference('MaxItemsToDisplayForBatchMod') | html %] items in a batch, items will not be shown.</p>
    [% ELSIF items.size %]
        [% PROCESS items_table_batchmod headers => item_header_loop, items => items, display_columns_selection => 1 %]
    [% END %]
[% END %]

[% BLOCK js %]
    [% Asset.js("js/pages/batchMod.js") | $raw %]
[% END %]
