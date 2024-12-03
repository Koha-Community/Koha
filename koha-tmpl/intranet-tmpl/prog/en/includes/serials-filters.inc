[% IF letters %]
    [% IF ( missingissues && supplierid ) %]
        [% PROCESS select_vendor context => "sidebar" %]
    [% END %]
[% END %]

[% IF ( missingissues ) %]
    <form action="claims.pl" id="filter_claims_form">
        <fieldset class="brief">
            <h4>Filter missing issues</h4>
            <legend class="sr-only">Filter missing issues</legend>
            <ol>
                <li>
                    <label for="from">From:</label>
                    <input type="text" name="begindate" id="from" value="[% begindate | html %]" size="10" maxlength="10" class="flatpickr" data-date_to="to" />
                </li>
                <li>
                    <label for="to">To:</label>
                    <input type="text" name="enddate" id="to" value="[% enddate | html %]" size="10" maxlength="10" class="flatpickr" />
                    <span class="hint">[% INCLUDE 'date-format.inc' %]</span>
                </li>
            </ol>
        </fieldset>
        <fieldset class="action">
            <input id="filterByDate" class="btn btn-primary" type="button" value="OK" />
            <input type="reset" class="btn btn-default" value="Clear" id="clearfilter" />
        </fieldset>
    </form>
[% END %]
