<div class="modal" id="overdrive-checkout" tabindex="-1" aria-labelledby="overdrive-checkoutLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="overdrive-checkoutLabel">Select a download format</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <form action="#" method="post" id="overdrive-checkout-form">
                [% INCLUDE 'csrf-token.inc' %]
                <div class="modal-body">
                    <input type="hidden" name="id" value="" />
                    <div id="overdrive-format-list">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="submit" class="btn btn-primary overdrive-checkout-submit">Save changes</button>
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                </div>
            </form> <!-- /#overdrive-checkout-form -->
        </div> <!-- /.modal-content -->
    </div> <!-- /.modal-dialog -->
</div> <!-- /.modal -->
