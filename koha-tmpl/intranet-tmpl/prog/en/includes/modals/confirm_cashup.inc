[% USE raw %]
[% USE To %]
[% USE Koha %]
<!-- Confirm cashup modal -->
<!-- Parameters:
     - modal_id: ID for the modal (required)
     - reconciliation_note_avs: Authorized values for notes (optional)
     - reconciliation_note_required: Whether note is required (optional)
     - cashup_in_progress: Whether completing in-progress cashup (optional)
     - form_action: Form action URL (optional, defaults to current page)
     - redirect_to: Where to redirect after completion (optional: 'register' or 'registers')
-->
[% SET note_av_options = [] %]
[% FOREACH av IN reconciliation_note_avs %]
    [% note_av_options.push({ value => av.authorised_value, label => av.lib }) %]
[% END %]
<style nonce="[% Koha.CSPNonce | $raw %]">
    /* Bootstrap form-control / form-select inherit a transparent background from
     * Koha's _forms styling, which makes them look greyed out inside the modal's
     * tabular layout. Force a white background on enabled inputs so the
     * Reconciliation note input matches the Actual counted column. */
    .cashup-reconciliation-grid input.form-control:not(:disabled),
    .cashup-reconciliation-grid select.form-select:not(:disabled),
    .cashup-reconciliation-grid input.cashup-amount-input:not(:disabled),
    .cashup-reconciliation-grid input.reconciliation-note-input:not(:disabled),
    .cashup-reconciliation-grid select.reconciliation-note-input:not(:disabled) {
        background-color: #fff !important;
    }
</style>
<div
    class="modal"
    id="[% modal_id | html %]"
    tabindex="-1"
    role="dialog"
    aria-labelledby="[% modal_id | html %]Label"
    data-note-avs="[% To.json(note_av_options) | html %]"
    data-note-required="[% reconciliation_note_required ? 1 : 0 | html %]"
>
    <form method="post" enctype="multipart/form-data" class="validated confirm-cashup-form" [% IF form_action %]action="[% form_action | html %]"[% END %]>
        [% INCLUDE 'csrf-token.inc' %]
        <div class="modal-dialog modal-lg">
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
                            <li class="cashup-per-type-rows">
                                <table class="cashup-reconciliation-grid table">
                                    <thead>
                                        <tr>
                                            <th scope="col">Payment type</th>
                                            <th scope="col" class="text-end">Expected</th>
                                            <th scope="col">Actual counted <span class="required">*</span></th>
                                            <th scope="col" class="text-end">Discrepancy</th>
                                            <th scope="col">Reconciliation note [% IF reconciliation_note_required %]<span class="required reconciliation-note-required-marker">*</span>[% END %]</th>
                                        </tr>
                                    </thead>
                                    <tbody class="cashup-rows">
                                        <!-- Populated by initConfirmCashupModal from paymentTypes config -->
                                    </tbody>
                                    <tfoot>
                                        <tr class="cashup-totals-row">
                                            <th scope="row">Total</th>
                                            <th class="text-end expected-total"></th>
                                            <th class="text-end actual-total"></th>
                                            <th class="text-end discrepancy-total"></th>
                                            <th></th>
                                        </tr>
                                    </tfoot>
                                </table>
                            </li>
                            <li class="reconciliation-display" style="display: none;">
                                <span class="label">Reconciliation:</span>
                                <span class="reconciliation-text"></span>
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
