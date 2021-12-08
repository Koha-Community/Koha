<!-- Cancel booking modal -->
<div class="modal" id="cancelBookingModal" tabindex="-1" role="dialog" aria-labelledby="cancelBookingLabel">
    <form id="cancelBookingForm">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="closebtn" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    <h4 class="modal-title" id="cancelBookingLabel">Cancel booking</h4>
                </div>
                <div class="modal-body">
                    <div id="cancel_booking_result"></div>
                    <input type="hidden" name="booking_id" id="cancel_booking_id">
                    <p>Are you sure you want to cancel this booking?</p>
                </div> <!-- /.modal-body -->
                <div class="modal-footer">
                    <button type="submit" class="btn btn-danger">Confirm</button>
                    <button type="button" class="btn btn-default" data-dismiss="modal" aria-hidden="true">Cancel</button>
                </div> <!-- /.modal-footer -->
            </div> <!-- /.modal-content -->
        </div> <!-- /.modal-dialog -->
    </form>
</div> <!-- /#cancelBookingModal -->
