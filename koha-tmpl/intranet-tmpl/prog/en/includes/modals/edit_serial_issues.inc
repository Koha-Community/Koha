[% USE Item %]

<!-- edit_serial_issues.inc -->
<!-- Edit serials confirmation dialog -->
<div class="modal fade" id="edit-serial-issues-modal" tabindex="-1" role="dialog" aria-labelledby="edit-serial-issues-modal-label">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h4 class="modal-title" id="edit-serial-issues-modal-label">Edit serial issues</h4>
            </div>
            <div class="modal-body">
                <h5 style="margin-bottom: 15px;">This item has a serial issue linked to it, would you like to edit this as well?</h5>
            </div>
            <div class="modal-footer">
                <button id="edit-serial-issues-modal-btn-submit" type="button" class="btn btn-primary"><i class="fa fa-exclamation-circle"></i> Edit serial issue</button>
                <button id="no-edit-serial-issues-modal-btn-submit" class="btn btn-default deny cancel" href="#" data-dismiss="modal" aria-hidden="true"><i class="fa fa-times"></i> Save item without editing serial issue</button>
            </div>
        </div>
    </div>
</div>
