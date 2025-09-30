[% USE Item %]

<!-- delete_item_confirmation.inc -->
<!-- Item deletion confirmation dialog -->
<div class="modal fade" id="delete-item-modal" tabindex="-1" role="dialog" aria-labelledby="claims-returned-modal-label">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="delete-item-modal-label">Delete item</h4>
            </div>
            <div class="modal-body">
                <h5 style="margin-bottom: 15px;">Are you sure you want to delete this item?</h5>

                <div class="form-group">
                    <div class="checkbox">
                        <label for="delete_associated_serial_issues">
                            <input id="delete_associated_serial_issues" type="checkbox" value="1" />
                            Delete serial issues linked to item
                        </label>
                    </div>
                </div>
                <input type="hidden" id="delete-item-itemnumber" />
            </div>
            <div class="modal-footer">
                <button id="delete-item-modal-btn-submit" type="button" class="btn btn-primary"><i class="fa fa-exclamation-circle"></i> Delete item</button>
                <button class="btn btn-default deny cancel" href="#" data-bs-dismiss="modal" aria-hidden="true"><i class="fa fa-times"></i> Cancel</button>
            </div>
        </div>
    </div>
</div>
