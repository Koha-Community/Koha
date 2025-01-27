<div id="multi_receiving" class="modal" tabindex="-1" role="dialog" aria-labelledby="multi_receiving_label" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h1 class="modal-title" id="multi_receiving_label">Multi receiving</h1>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="/cgi-bin/koha/serials/serials-collection.pl" method="post">
                [% INCLUDE 'csrf-token.inc' %]
                <div class="modal-body">
                    <fieldset class="rows">
                        <legend class="sr-only">Multi receiving</legend>
                        <ol>
                            <li>
                                <label for="nbissues" class="required">How many issues do you want to receive?</label>
                                <input type="text" size="25" id="nbissues" name="nbissues" required="required" />
                            </li>
                            <li>
                                <label for="date_received_today">Set the date received to today?</label>
                                <input type="checkbox" id="date_received_today" name="date_received_today" />
                            </li>
                        </ol>
                        <input type="hidden" name="op" value="cud-gennext" />

                        [%# subscriptionidlist is used from serials-collection, subscriptionid is used from serils-edit %]
                        <input type="hidden" name="subscriptionid" value="[% subscriptionidlist || subscriptionid | html %]" />
                    </fieldset>
                </div>

                <div class="modal-footer">
                    <button type="submit" class="btn btn-default approve">Submit</button>
                    <button type="button" class="btn btn-default" data-bs-dismiss="modal">Cancel</button>
                </div>
            </form>
        </div>
    </div>
</div>
