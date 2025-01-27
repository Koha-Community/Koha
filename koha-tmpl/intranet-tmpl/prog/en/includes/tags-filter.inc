<form method="get" action="/cgi-bin/koha/tags/review.pl">
    <fieldset class="brief">
        <h4>Filters</h4>
        <ol>
            <li> <label for="tag">Term:</label> <input type="text" name="tag" id="tag" value="[% filter_tag | html %]" /> </li>
            <li>
                <label for="approved">Status:</label>
                <select name="approved" id="approved">
                    [% IF ( filter_approved_all ) %]
                        <option selected="selected" value="all">All</option>
                    [% ELSE %]
                        <option value="all">all</option>
                    [% END %]
                    [% IF ( filter_approved_ok ) %]
                        <option selected="selected" value="1">Approved</option>
                    [% ELSE %]
                        <option value="1">approved</option>
                    [% END %]
                    [% IF ( filter_approved_pending ) %]
                        <option selected="selected" value="0">Pending</option>
                    [% ELSE %]
                        <option value="0">pending</option>
                    [% END %]
                    [% IF ( filter_approved_rej ) %]
                        <option selected="selected" value="-1">Rejected</option>
                    [% ELSE %]
                        <option value="-1">Rejected</option>
                    [% END %]
                </select>
            </li>
            <li> <label for="approver">Reviewer:</label> <input type="text" name="approver" id="approver" value="[% filter_approver | html %]" /> </li>
            <li>
                <label for="from">Date: from </label>
                <input type="text" size="10" id="from" name="from" value="[% filter_date_approved_from | html %]" class="flatpickr" data-date_to="to" />
                <div class="hint">[% INCLUDE 'date-format.inc' %]</div>

                <label for="to">...to </label>
                <input type="text" size="10" id="to" name="to" value="[% filter_date_approved_to | html %]" class="flatpickr" />
                <div class="hint">[% INCLUDE 'date-format.inc' %]</div>
            </li>
        </ol>
    </fieldset>
    <fieldset class="action">
        <button type="submit" class="btn btn-primary"><i class="fa fa-filter" aria-hidden="true"></i> Apply filter(s)</button>
    </fieldset>
</form>
