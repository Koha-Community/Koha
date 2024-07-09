<!-- Delete Vendor modal form -->
<div id="deleteVendorModal" class="modal" tabindex="-1" role="dialog" aria-labelledby="deleteVendorModalLabel">
    <form method="post" action="/cgi-bin/koha/acqui/supplier.pl">
        [% INCLUDE 'csrf-token.inc' %]
        <input type="hidden" name="op" value="cud-delete" />
        <input type="hidden" name="booksellerid" id="booksellerid" value="" />
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="closebtn" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    <h4 class="modal-title" id="deleteVendorModalLabel">Delete vendor</h4>
                </div>
                <div class="modal-body">
                    <p>Are you sure you want to delete this vendor?</p>
                </div>
                <div class="modal-footer">
                    <button id="deleteVendorModaConfirmBtn" class="btn btn-primary"><i class="fa fa-check" aria-hidden="true"></i> Yes</button>
                    <button id="deleteVendorModaCancelBtn"data-dismiss="modal" class="btn btn-secondary"><i class="fa fa-times" aria-hidden="true"></i> No</button>
                </div>
            </div>
        </div>
    </form>
</div>