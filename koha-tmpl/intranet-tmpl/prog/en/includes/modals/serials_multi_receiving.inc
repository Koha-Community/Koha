<div id="multi_receiving" class="modal" tabindex="-1" role="dialog" aria-labelledby="multi_receiving_label" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="/cgi-bin/koha/serials/serials-collection.pl" method="post">
                <div class="modal-body">
                    <fieldset class="rows">
                        <legend>Multi receiving</legend>
                        <ol>
                            <li>
                            <label for="nbissues" class="required">How many issues do you want to receive?</label>
                            <input type="text"  size="25" id="nbissues" name="nbissues" required="required" />
                            <li>
                            <li>
                                <label for="date_received_today">Set the date received to today?</label>
                                <input type="checkbox" id="date_received_today" name="date_received_today" />
                            </li>
                        </ol>
                        <input type="hidden" name="op" value="gennext" />

                        [%# subscriptionidlist is used from serials-collection, subscriptionid is used from serils-edit %]
                        <input type="hidden" name="subscriptionid" value="[% subscriptionidlist || subscriptionid %]" />
                    </fieldset>
                </div>

                <div class="modal-footer">
                    <a href="#" class="cancel" data-dismiss="modal" aria-hidden="true">Cancel</a>
                    <input type="submit" class="btn btn-default approve" value="Multi receiving" />
                </div>
            </form>
        </div>
    </div>
</div>
