<div id="skip_issues" class="modal" tabindex="-1" role="dialog" aria-labelledby="skip_issues_label" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
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
                    <a href="#" class="cancel" data-dismiss="modal" aria-hidden="true">Cancel</a>
                    <input type="submit" class="btn btn-default approve" value="OK" />
                </div>
            </form>
        </div>
    </div>
</div>
