<div id="generate_next" class="modal" tabindex="-1" role="dialog" aria-labelledby="generate_next" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <form action="/cgi-bin/koha/serials/serials-collection.pl" method="post">
                [% INCLUDE 'csrf-token.inc' %]
                <div class="modal-body">
                    <fieldset class="rows">
                        <legend>Do you really want to generate next serial?</legend>
                        <input type="hidden" name="op" value="cud-gennext" />
                        <input type="hidden" name="subscriptionid" value="[% subscriptionidlist || subscriptionid | html %]" />
                    </fieldset>
                </div>

                <div class="modal-footer">
                    <a href="#" class="cancel" data-dismiss="modal" aria-hidden="true">Cancel</a>
                    <input type="submit" class="btn btn-default approve" value="Yes" />
                </div>
            </form>
        </div>
    </div>
</div>
