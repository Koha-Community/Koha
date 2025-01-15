<!-- Delete Vendor modal form -->
<div id="deleteVendorModal" class="modal" tabindex="-1" role="dialog" aria-labelledby="deleteVendorModalLabel">
    <form id="deleteVendorForm">
        <input type="hidden" name="booksellerid" id="booksellerid" value="" />
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h4 class="modal-title" id="deleteVendorModalLabel">Delete vendor</h4>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p>Are you sure you want to delete this vendor?</p>
                </div>
                <div class="modal-footer">
                    <button type="submit" id="deleteVendorModaConfirmBtn" class="btn btn-default approve"><i class="fa fa-check" aria-hidden="true"></i> Yes</button>
                    <button type="button" id="deleteVendorModaCancelBtn" data-bs-dismiss="modal" class="btn btn-default deny"><i class="fa fa-times" aria-hidden="true"></i> No</button>
                </div>
            </div>
        </div>
    </form>
</div>
