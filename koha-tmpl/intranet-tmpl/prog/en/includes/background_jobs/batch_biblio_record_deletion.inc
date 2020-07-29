[% BLOCK report %]
    [% SET report = job.report %]
    [% IF report %]
        [% IF report.total_records == report.total_success %]
            <div class="dialog message">
                All records have been deleted successfully!
            </div>
        [% ELSIF report.total_success == 0 %]
            <div class="dialog message">
                No record has been deleted. An error occurred.
            </div>
        [% ELSE %]
            <div class="dialog message">
                [% report.total_success | html %] / [% report.total_records | html %] records have been deleted successfully but some errors occurred.
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
            [% CASE 'biblio_not_exists' %]
                The biblionumber [% m.biblionumber | html %] does not exist in the database.
            [% CASE 'item_issued' %]
                At least one item is checked out on bibliographic record [% m.biblionumber | html %].
            [% CASE 'reserve_not_cancelled' %]
                Bibliographic record [% m.biblionumber | html %] was not deleted. A hold could not be canceled (reserve_id [% m.reserve_id | html %]).
            [% CASE 'item_not_deleted' %]
                The bibliographic record [% m.biblionumber | html %] was not deleted. An error was encountered when deleting an item (itemnumber [% m.itemnumber | html %]).
            [% CASE 'biblio_not_deleted' %]
                Bibliographic record [% m.biblionumber | html %] was not deleted. An error occurred.
            [% CASE 'biblio_deleted' %]
                Bibliographic record [% m.biblionumber | html %] has been deleted successfully.
            [% END %]
        </div>
    [% END %]
[% END %]

[% BLOCK js %]
[% END %]
