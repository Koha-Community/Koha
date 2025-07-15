[% BLOCK 'cancel-hold-modal' %]
    <div id="cancelModal" class="modal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h1 class="modal-title">Confirm deletion</h1>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>

                <form id="cancel_modal_form" method="post" action="[% form_action | html %]">
                    [% INCLUDE 'csrf-token.inc' %]
                    [% IF (from_param) %]
                        <input type="hidden" name="from" value="[% patronpage | html %]" />
                    [% END %]
                    <div id="inputs">
                        <input type="hidden" name="op" value="cud-cancel" />
                    </div>

                    <div class="modal-body">
                        <p>Are you sure you want to cancel this hold?</p>
                        <div id="cancel_hold_alert" class="alert alert-danger" style="display:none;"></div>
                        <fieldset class="action">
                            [% SET hold_cancellation = AuthorisedValues.GetAuthValueDropbox('HOLD_CANCELLATION') %]
                            [% IF hold_cancellation.count %]
                                <label for="modal-cancellation-reason">Cancellation reason: </label>
                                <select class="cancellation-reason" name="cancellation-reason" id="modal-cancellation-reason">
                                    <option value="">No reason given</option>
                                    [% FOREACH reason IN hold_cancellation %]
                                        <option value="[% reason.authorised_value | html %]">[% reason.lib | html %]</option>
                                    [% END %]
                                </select>
                            [% END %]
                        </fieldset>
                    </div>

                    <div class="modal-footer">
                        <button id="cancelModalConfirmBtn" type="submit" class="btn btn-danger">Confirm cancellation</button>
                        <button type="button" class="btn btn-default" data-bs-dismiss="modal">Cancel</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
[% END %]