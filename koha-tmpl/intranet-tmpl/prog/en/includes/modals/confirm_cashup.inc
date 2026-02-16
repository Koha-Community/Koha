[% USE raw %]
<!-- Confirm cashup modal -->
<!-- Parameters:
     - modal_id: ID for the modal (required)
     - reconciliation_note_avs: Authorized values for notes (optional)
     - reconciliation_note_required: Whether note is required (optional)
     - cashup_in_progress: Whether completing in-progress cashup (optional)
     - form_action: Form action URL (optional, defaults to current page)
     - redirect_to: Where to redirect after completion (optional: 'register' or 'registers')
-->
<div class="modal" id="[% modal_id | html %]" tabindex="-1" role="dialog" aria-labelledby="[% modal_id | html %]Label">
    <form method="post" enctype="multipart/form-data" class="validated confirm-cashup-form" [% IF form_action %]action="[% form_action | html %]"[% END %]>
        [% INCLUDE 'csrf-token.inc' %]
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h1 class="modal-title" id="[% modal_id | html %]Label">
                        [% IF cashup_in_progress %]
                            Complete cashup of <em><span class="register-name">[% register.description | html %]</span></em>
                        [% ELSE %]
                            Confirm cashup of <em><span class="register-name"></span></em>
                        [% END %]
                    </h1>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <fieldset class="rows">
                        <ol>
                            <li>
                                <span class="label expected-amount-label">
                                    [% IF cashup_in_progress %]
                                        [% IF cashup_in_progress.amount < 0 %]
                                            Expected amount to add:
                                        [% ELSE %]
                                            Expected cashup amount:
                                        [% END %]
                                    [% ELSE %]
                                        Expected cashup amount:
                                    [% END %]
                                </span>
                                <span class="expected-amount">[% IF cashup_in_progress %][% cashup_in_progress.amount | $Price %][% END %]</span>
                            </li>
                            <li>
                                <label class="required actual-amount-label" for="cashup_amount">
                                    [% IF cashup_in_progress %]
                                        [% IF cashup_in_progress.amount < 0 %]
                                            Actual amount added to register:
                                        [% ELSE %]
                                            Actual cashup amount counted:
                                        [% END %]
                                    [% ELSE %]
                                        Actual cashup amount counted:
                                    [% END %]
                                </label>
                                <input type="text" inputmode="decimal" pattern="^-?\d+(\.\d{2})?$" id="cashup_amount" name="amount" class="cashup-amount-input" required="required" />
                                <span class="required">Required</span>
                            </li>
                            <li class="reconciliation-display" style="display: none;">
                                <span class="label">Reconciliation:</span>
                                <span class="reconciliation-text"></span>
                            </li>
                            <li class="reconciliation-note-field" style="display: none;">
                                <label class="reconciliation-note-label" for="cashup_reconciliation_note"> Note[% IF reconciliation_note_required %](required)[% ELSE %](optional)[% END %]: </label>
                                [% IF reconciliation_note_avs %]
                                    <select id="cashup_reconciliation_note" class="reconciliation-note-input" name="reconciliation_note">
                                        <option value="">-- Select a reason --</option>
                                        [% FOREACH av IN reconciliation_note_avs %]
                                            <option value="[% av.authorised_value | html %]">[% av.lib | html %]</option>
                                        [% END %]
                                    </select>
                                    [% IF reconciliation_note_required %]
                                        <span class="required">Required</span>
                                    [% END %]
                                [% ELSE %]
                                    <textarea
                                        id="cashup_reconciliation_note"
                                        class="reconciliation-note-input"
                                        name="reconciliation_note"
                                        rows="3"
                                        cols="40"
                                        maxlength="1000"
                                        placeholder="Enter a note explaining the surplus or deficit..."
                                    ></textarea>
                                    [% IF reconciliation_note_required %]
                                        <span class="required">Required</span>
                                    [% END %]
                                    <div class="hint">Maximum 1000 characters</div>
                                [% END %]
                            </li>
                        </ol>
                    </fieldset>
                </div>
                <div class="modal-footer">
                    <input type="hidden" name="registerid" class="register-id-field" value="[% IF cashup_in_progress %][% register.id | html %][% END %]" />
                    <input type="hidden" name="op" value="cud-cashup" />
                    [% IF redirect_to %]
                        <input type="hidden" name="redirect_to" value="[% redirect_to | html %]" />
                    [% END %]
                    <button type="submit" class="btn btn-primary"> [% IF cashup_in_progress %]Complete cashup[% ELSE %]Confirm cashup[% END %] </button>
                    <button type="button" class="btn btn-default" data-bs-dismiss="modal">Cancel</button>
                </div>
            </div>
        </div>
    </form>
</div>
<!-- /#[% modal_id | html %] -->
