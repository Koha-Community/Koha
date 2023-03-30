[% USE Koha %]
[% INCLUDE 'columns_settings.inc' %]

[% BLOCK report %]
    [% SET report = job.report %]
    [% IF report %]
        <div class="dialog message">
            [% IF report.modified_itemnumbers.size %]
                <span>[% report.modified_itemnumbers.size | html %] item(s) modified (with [% report.modified_fields | html %] field(s) modified).</span>
            [% ELSE %]
                <span>No items modified.</span>
            [% END %]

            [% IF job.status == 'cancelled' %]<span>The job has been cancelled before it finished.</span>[% END %]
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
            [% CASE %]<span>Unknown message '[% m.code | html %]'</span>
            [% END %]
        </div>
    [% END %]

    [% IF too_many_items_display %]
        <p>Too many items ([% report.modified_itemnumbers.size | html %]): You have edited more than [% Koha.Preference('MaxItemsToDisplayForBatchMod') | html %] items in a batch, items will not be shown.</p>
    [% ELSIF items.size %]
        [% PROCESS items_table_batchmod headers => item_header_loop, items => items, display_columns_selection => 1 %]
    [% END %]
[% END %]

[% BLOCK js %]
    [% Asset.js("js/pages/batchMod.js") | $raw %]
[% END %]
