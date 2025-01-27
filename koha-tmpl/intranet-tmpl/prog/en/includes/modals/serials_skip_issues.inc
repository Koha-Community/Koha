<div id="skip_issues" class="modal" tabindex="-1" role="dialog" aria-labelledby="skip_issues_label" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="/cgi-bin/koha/serials/serials-collection.pl" method="post">
                [% INCLUDE 'csrf-token.inc' %]
                <div class="modal-body">
                    <fieldset class="rows">
                        <legend>Skip issues and generate next</legend>
                        <ol>
                            <li>
                                <label for="nbissues" class="required">How many issues do you want to skip?</label>
                                <input type="text" pattern="^\d$" size="10" id="skip_issues" name="skip_issues" required="required" />
                            </li>
                        </ol>
                        <input type="hidden" name="op" value="cud-gennext" />

                        [%# subscriptionidlist is used from serials-collection, subscriptionid is used from serials-edit %]
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
