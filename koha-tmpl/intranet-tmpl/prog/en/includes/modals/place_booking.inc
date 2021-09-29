<!-- Place booking modal -->
<div class="modal" id="placeBookingModal" tabindex="-1" role="dialog" aria-labelledby="placeBookingLabel">
    <form id="placeBookingForm">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="closebtn" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    <h4 class="modal-title" id="placeBookingLabel">Place booking</h4>
                </div>
                <div class="modal-body">
                    <div id="booking_result"></div>
                    <fieldset class="rows">
                        <input type="hidden" name="biblio_id" id="booking_biblio_id">
                        <input type="hidden" name="start_date" id="booking_start_date">
                        <input type="hidden" name="end_date" id="booking_end_date">
                        <ol>
                            <li>
                                <div class="hint">Enter patron card number or partial name:</div>
                                <label class="required" for="booking_patron_id">Patron: </label>
                                <select name="booking_patron_id" id="booking_patron_id" required="required">
                                    <option></option>
                                    [% IF patron %]
                                    <option value="[% borrowernumber | uri %]" selected="selected">[% patron.firstname | html %] [% patron.surname | html %] ([% patron.cardnumber | html %] )</option>
                                    [% END %]
                                </select>
                            </li>
                            <label for="booking_item_id">Item: </label>
                                <select name="booking_item_id" id="booking_item_id" disabled="true">
                                    <option value="0">Any item</option>
                                </select>
                            </li>

                            <li>
                                <div id="period_fields">
                                    <label class="required" for="period">Period: </label>
                                    <input type="text" id="period" name="period" class="flatpickr" data-flatpickr-futuredate="true" required="required" disabled="true" autocomplete="off">
                                    <span class="required">Required</span>
                                </div>
                            </li>
                        </ol>
                    </fieldset>
                </div> <!-- /.modal-body -->
                <div class="modal-footer">
                    <button type="submit" class="btn btn-primary">Submit</button>
                    <button type="button" class="btn btn-default" data-dismiss="modal" aria-hidden="true">Cancel</button>
                </div> <!-- /.modal-footer -->
            </div> <!-- /.modal-content -->
        </div> <!-- /.modal-dialog -->
    </form>
</div> <!-- /#placeBookingModal -->
