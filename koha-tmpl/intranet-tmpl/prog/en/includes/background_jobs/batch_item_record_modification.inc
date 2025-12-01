[% USE Koha %]
[% PROCESS 'i18n.inc' %]

[% BLOCK report %]
    [% SET report = job.report %]
    [% IF report %]
        <div class="alert alert-info">
            [% IF report.modified_itemnumbers.size %]
                [% SET modified_items_count = report.modified_itemnumbers.size %]
                [% SET modified_fields_count = report.modified_fields %]
                <span
                    >[% tnx( '{count} item modified', '{count} items modified', modified_items_count, { count = modified_items_count }) + ' (' + tnx( 'with {count} field modified', 'with {count} fields modified', modified_fields_count, { count = modified_fields_count }) + ').' | html %]</span
                >
            [% ELSE %]
                <span>No items modified.</span>
            [% END %]

            [% IF job.status == 'cancelled' %]<span>The job has been cancelled before it finished.</span>[% END %]
            <a href="/cgi-bin/koha/tools/batchMod.pl" title="New batch item modification">New batch item modification</a>
        </div>
        <div>
            [% IF report.errors.size %]
                <div class="alert alert-warning">
                    [% SET error_items_count = report.errors.size %]
                    <span>[% tnx('{count} item could not be modified.', '{count} items could not be modified.', error_items_count, { count = error_items_count }) | html %]</span>
                </div>
            [% END %]
        </div>
    [% END %]
[% END %]

[% BLOCK detail %]
    [% FOR m IN job.messages %]
        <div class="alert alert-info">
            [% IF m.type == 'success' %]
                <i class="fa fa-check success"></i>
            [% ELSIF m.type == 'warning' %]
                <i class="fa-solid fa-triangle-exclamation warn"></i>
            [% ELSIF m.type == 'error' %]
                <i class="fa fa-exclamation error"></i>
            [% END %]
            [% SWITCH m.code %]
            [% CASE %]
                <span>Unknown message '[% m.code | html %]'</span>
            [% END %]
        </div>
    [% END %]

    [% IF too_many_items_display %]
        <p>[% tx('Too many items ({count}): You have edited more than {max} items in a batch, items will not be shown.', { count => report.modified_itemnumbers.size, max => Koha.Preference('MaxItemsToDisplayForBatchMod') }) | html %]</p>
    [% ELSIF items.size %]
        [% PROCESS items_table_batchmod headers => item_header_loop, items => items, display_columns_selection => 1 %]
    [% END %]
[% END %]

[% BLOCK js %]
    [% Asset.js("js/pages/batchMod.js") | $raw %]
[% END %]
