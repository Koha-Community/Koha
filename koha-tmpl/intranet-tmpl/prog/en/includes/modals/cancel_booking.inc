<!-- Cancel booking modal -->
<div class="modal" id="cancelBookingModal" tabindex="-1" role="dialog" aria-labelledby="cancelBookingLabel">
    <form method="get" id="cancelBookingForm">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h1 class="modal-title" id="cancelBookingLabel">Cancel booking</h1>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div id="cancel_booking_result"></div>
                    <input type="hidden" name="booking_id" id="cancel_booking_id">
                    <p>Are you sure you want to cancel this booking?</p>
                </div> <!-- /.modal-body -->
                <div class="modal-footer">
                    <button type="submit" class="btn btn-default approve"><i class="fa fa-check"></i> Yes, cancel booking</button>
                    <button type="button" class="btn btn-default deny" data-bs-dismiss="modal"><i class="fa fa-remove"></i> No, do not cancel</button>
                </div> <!-- /.modal-footer -->
            </div> <!-- /.modal-content -->
        </div> <!-- /.modal-dialog -->
    </form>
</div> <!-- /#cancelBookingModal -->
