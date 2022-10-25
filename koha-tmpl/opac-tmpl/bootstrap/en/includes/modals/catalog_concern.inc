<!-- Add concern modal -->
<div class="modal" id="addConcernModal" tabindex="-1" role="dialog" aria-labelledby="addConcernModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h3 class="modal-title" id="addConcernModalLabel">Report a concern</h3>
                <button type="button" class="closebtn" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <fieldset id="concern_fieldset">
                    <div class="form-group">
                        <label for="concern_title">Title: </label>
                        <input type="text" name="concern_title" id="concern_title" required="required"/>
                    </div>
                    <div class="form-group">
                        <label for="concern_body">Please describe your concerns: </label>
                        <textarea class="form-control" name="concern_body" id="concern_body" required="required" rows="15"></textarea>
                    </div>
                </fieldset>
            </div>
            <div class="modal-footer">
                <input type="hidden" name="biblio_id" id="concern_biblio" value="[% biblio.biblionumber | html %]">
                <input type="hidden" name="reporter_id" id="concern_reporter" value="[% borrowernumber | html %]">
                <button type="submit" id="addConfirm" class="btn btn-primary">Submit</button>
                <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
            </div>
        </div>
    </div>
</div>
