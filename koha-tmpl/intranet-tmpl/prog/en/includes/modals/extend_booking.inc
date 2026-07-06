<!-- Extend booking modal -->
<div class="modal" id="extendBookingModal" tabindex="-1" role="dialog" aria-labelledby="extendBookingLabel">
    <form method="get" id="extendBookingForm">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h1 class="modal-title" id="extendBookingLabel">Extend booking</h1>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body overflow-visible">
                    <div id="extend_booking_result"></div>
                    <input type="hidden" name="booking_id" id="extend_booking_id" />
                    <input type="hidden" name="checkout_id" id="extend_checkout_id" />
                    <fieldset class="brief">
                        <ol>
                            <li>
                                <span class="label">Current end date: </span>
                                <span id="extend_current_end_date"></span>
                            </li>
                            <li>
                                <span class="label">Checkout due date: </span>
                                <span id="extend_current_due_date"></span>
                            </li>
                            <li>
                                <label for="extend_new_end_date" class="required">New end date: </label>
                                <input type="text" id="extend_new_end_date" name="new_end_date" class="form-control" autocomplete="off" required />
                                <div class="hint">Dates blocked in the picker are unavailable due to other bookings on this item</div>
                            </li>
                        </ol>
                    </fieldset>
                    <!-- /.brief -->
                </div>
                <!-- /.modal-body -->
                <div class="modal-footer">
                    <button type="submit" class="btn btn-default approve"><i class="fa fa-check"></i> Confirm</button>
                    <button type="button" class="btn btn-default deny" data-bs-dismiss="modal"><i class="fa fa-remove"></i> Cancel</button>
                </div>
                <!-- /.modal-footer -->
            </div>
            <!-- /.modal-content -->
        </div>
        <!-- /.modal-dialog -->
    </form>
</div>
<!-- /#extendBookingModal -->
