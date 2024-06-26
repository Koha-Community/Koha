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
                [% IF batch %]
                    <h5 style="margin-bottom: 15px;">Some of these items have linked serial issues, would you like to edit these as well?</h5>
                [% ELSE %]
                    <h5 style="margin-bottom: 15px;">This item has a serial issue linked to it, would you like to edit this as well?</h5>
                [% END %]
            </div>
            <div class="modal-footer">
                [% IF batch %]
                    <button id="edit-serial-issues-modal-btn-submit" type="button" class="btn btn-primary"><i class="fa fa-exclamation-circle"></i> Edit serial issues</button>
                [% ELSE %]
                    <button id="edit-serial-issues-modal-btn-submit" type="button" class="btn btn-primary"><i class="fa fa-exclamation-circle"></i> Edit serial issue</button>
                [% END %]
                [% IF batch %]
                    <button id="no-edit-serial-issues-modal-btn-submit" class="btn btn-default deny cancel" href="#" data-dismiss="modal" aria-hidden="true"><i class="fa fa-times"></i> Save items without editing serial issues</button>
                [% ELSE %]
                    <button id="no-edit-serial-issues-modal-btn-submit" class="btn btn-default deny cancel" href="#" data-dismiss="modal" aria-hidden="true"><i class="fa fa-times"></i> Save item without editing serial issue</button>
                [% END %]
            </div>
        </div>
    </div>
</div>
