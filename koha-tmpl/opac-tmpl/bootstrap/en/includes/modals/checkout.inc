<!-- Checkout form hidden by default, used for modal window -->
<div class="modal" id="checkoutModal" tabindex="-1" role="dialog" aria-labelledby="checkoutModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h3 class="modal-title" id="checkoutModalLabel">Self checkout</h3>
                <button type="button" class="closebtn" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <div id="checkoutResults"></div>
                <div id="availabilityResult"></div>
                <div class="form-group">
                    <label for="checkout_barcode">Enter item barcode: </label>
                    <input type="text" name="checkout_barcode" id="checkout_barcode" required="required"></input>
                </div>
                <table id="checkoutsTable" class="table table-bordered table-striped" style="width:100%;">
                    <thead>
                      <tr>
                          <th>Barcode</th>
                          <th>Title</th>
                          <th>Call number</th>
                          <th>Due date</th>
                      </tr>
                    </thead>
                    <tbody>
                    </tbody>
                    <tfoot>
                      <tr>
                        <td colspan="4" class="text-right"><span id="checkoutsCount"></span> items checked out</td>
                      </tr>
                    </tfoot>
                </table>
            </div>
            <div class="modal-footer">
                <button type="submit" id="checkoutSubmit" class="btn btn-primary">Submit</button>
                <button type="button" id="checkoutClose" class="btn btn-default" data-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>
