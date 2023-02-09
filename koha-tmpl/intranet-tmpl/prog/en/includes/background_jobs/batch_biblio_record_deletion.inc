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
                <i class="fa-solid fa-triangle-exclamation warn"></i>
            [% ELSIF m.type == 'error' %]
                <i class="fa fa-exclamation error"></i>
            [% END %]
            [% SWITCH m.code %]
            [% CASE 'biblio_not_exists' %]
                <span>The biblionumber [% m.biblionumber | html %] does not exist in the database.</span>
            [% CASE 'item_issued' %]
                <span>At least one item is checked out on bibliographic record [% m.biblionumber | html %].</span>
            [% CASE 'reserve_not_cancelled' %]
                <span>Bibliographic record [% m.biblionumber | html %] was not deleted. A hold could not be canceled (reserve_id [% m.reserve_id | html %]).</span>
            [% CASE 'item_not_deleted' %]
                <span>The bibliographic record [% m.biblionumber | html %] was not deleted. An error was encountered when deleting an item (itemnumber [% m.itemnumber | html %]).</span>
            [% CASE 'biblio_not_deleted' %]
                <span>Bibliographic record [% m.biblionumber | html %] was not deleted. An error occurred.</span>
            [% CASE 'biblio_deleted' %]
                <span>Bibliographic record [% m.biblionumber | html %] has been deleted successfully.</span>
            [% END %]
        </div>
    [% END %]
[% END %]

[% BLOCK js %]
[% END %]
