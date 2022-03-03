[% USE raw %]
[% USE Koha %]
[% PROCESS 'html_helpers.inc' %]
[% USE Branches %]

<form method="get" id="illfilter_form">
    <fieldset class="brief">
        <h3>Filters</h3>
        <ol>
            <li>
                <label for="illfilter_keyword">Keyword:</label>
                <input type="text" name="illfilter_keyword" id="illfilter_keyword" />
            </li>
            <li>
                <label for="illfilter_backend">Backend:</label>
                <select name="illfilter_backend" id="illfilter_backend">
                    <option value="">All backends</option>
                </select>
            </li>
            <li>
                <label for="illfilter_status">Status:</label>
                <select name="illfilter_status" id="illfilter_status" multiple="multiple"> </select>
            </li>
            <li>
                <label for="illfilter_dateplaced_start">Date placed between:</label>
                <input type="text" name="illfilter_dateplaced_start" id="illfilter_dateplaced_start" class="flatpickr" data-date_to="illfilter_dateplaced_end" />
            </li>
            <li>
                <label for="illfilter_dateplaced_end">and:</label>
                <input type="text" name="illfilter_dateplaced_end" id="illfilter_dateplaced_end" class="flatpickr" />
            </li>
            <li>
                <label for="illfilter_datemodified_start">Updated between:</label>
                <input type="text" name="illfilter_datemodified_start" id="illfilter_datemodified_start" class="flatpickr" data-date_to="illfilter_datemodified_end" />
            </li>
            <li>
                <label for="illfilter_datemodified_end">and:</label>
                <input type="text" name="illfilter_datemodified_end" id="illfilter_datemodified_end" class="flatpickr" />
            </li>
            <li>
                <label for="illfilter_branchname">Library:</label>
                <select name="illfilter_branchname" id="illfilter_branchname">
                    <option value="">All libraries</option>
                    [% PROCESS options_for_libraries libraries => Branches.all( selected => userbranch, only_from_group => 1 ) %]
                </select>
            </li>
            <li>
                <label for="illfilter_patron">Patron:</label>
                <input type="text" name="illfilter_patron" id="illfilter_patron" />
            </li>
        </ol>
    </fieldset>
    <fieldset class="action">
        <input type="submit" class="btn btn-primary" value="Search" />
        <input type="button" value="Clear" class="clear_search" />
    </fieldset>
</form>
<!-- /#illfilter_form -->
