[%# EDIFACT interchange modal include %]
[%# This modal can be used on any page that needs to display EDIFACT interchanges %]

<!-- Modal to display EDIFACT interchanges -->
<div class="modal" id="EDI_modal" tabindex="-1" role="dialog" aria-labelledby="EDI_modal_label" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h1 class="modal-title" id="EDI_modal_label">EDIFACT Interchange</h1>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div id="edi_loading"><img src="[% interface | html %]/[% theme | html %]/img/spinner-small.gif" alt="" /> Loading</div>
            </div>
            <div class="modal-footer">
                <button class="btn btn-default" data-bs-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>

<!-- Modal to display EDIFACT errors -->
<div class="modal" id="EDI_errors_modal" tabindex="-1" role="dialog" aria-labelledby="EDI_errors_modal_label" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h1 class="modal-title" id="EDI_errors_modal_label">EDIFACT processing errors for <span id="EDI_errors_filename"></span></h1>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div id="edi_errors_loading"><img src="[% interface | html %]/[% theme | html %]/img/spinner-small.gif" alt="" /> Loading</div>
            </div>
            <div class="modal-footer">
                <button class="btn btn-default" data-bs-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>
