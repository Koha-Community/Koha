[% USE raw %]
<!-- Trigger cashup modal -->
<!-- Parameters:
     - modal_id: ID for the modal (required)
     - register_description: Register description to pre-populate (optional, for register.tt)
     - register_id: Register ID to pre-populate (optional, for register.tt)
     - form_action: Form action URL (optional, defaults to current page)
     - redirect_to: Where to redirect after completion (optional: 'register' or 'registers')
-->
<div class="modal" id="[% modal_id | html %]" tabindex="-1" role="dialog" aria-labelledby="[% modal_id | html %]Label">
    <form method="post" class="validated trigger-cashup-form" [% IF form_action %]action="[% form_action | html %]"[% END %]>
        [% INCLUDE 'csrf-token.inc' %]
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h1 class="modal-title" id="[% modal_id | html %]Label">
                        Cashup for <em><span class="register-description">[% IF register_description %][% register_description | html %][% END %]</span></em>
                    </h1>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p><strong>Choose how to proceed with the cashup:</strong></p>
                    <p><strong>Start cashup</strong></p>
                    <ul class="start-cashup-instructions">
                        <!-- JavaScript will populate this based on positive/negative amount -->
                    </ul>
                    <p><strong>Quick cashup</strong></p>
                    <ul class="quick-cashup-instructions">
                        <!-- JavaScript will populate this based on positive/negative amount -->
                    </ul>
                    <p class="float-reminder-text">
                        <!-- JavaScript will populate this based on positive/negative amount -->
                    </p>
                </div>
                <div class="modal-footer">
                    <input type="hidden" name="registerid" class="register-id-field" value="[% IF register_id %][% register_id | html %][% END %]" />
                    <input type="hidden" name="op" value="cud-cashup_start" />
                    [% IF redirect_to %]
                        <input type="hidden" name="redirect_to" value="[% redirect_to | html %]" />
                    [% END %]
                    <button type="submit" class="btn btn-primary">Start cashup</button>
                    <button type="button" class="btn btn-success quick-cashup-btn">Quick cashup</button>
                    <button type="button" class="btn btn-default" data-bs-dismiss="modal">Cancel</button>
                </div>
            </div>
        </div>
    </form>
</div>
<!-- /#[% modal_id | html %] -->
