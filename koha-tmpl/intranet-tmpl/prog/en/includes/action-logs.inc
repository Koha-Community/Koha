[% BLOCK translate_log_module %]
    [% SWITCH module %]
    [% CASE 'APIKEYS' %]
        <span>API keys</span>[% UNLESS Koha.Preference('ApiKeyLog') %]<i class="log-disabled fa-solid fa-triangle-exclamation" title="Log not enabled" data-log="ApiKeyLog"></i>[% END %]
    [% CASE 'AUTH' %]
        <span>Authentication</span>[% UNLESS Koha.Preference('AuthFailureLog') && Koha.Preference('AuthSuccessLog') %]
            <i class="log-disabled fa-solid fa-triangle-exclamation" title="Log not enabled" data-log="AuthFailureLog|AuthSuccessLog"></i>
        [% END %]
    [% CASE 'CATALOGUING' %]
        <span>Cataloging</span>[% UNLESS Koha.Preference('CataloguingLog') %]<i class="log-disabled fa-solid fa-triangle-exclamation" title="Log not enabled" data-log="CataloguingLog"></i>[% END %]
    [% CASE 'AUTHORITIES' %]
        <span>Authorities</span>[% UNLESS Koha.Preference('AuthoritiesLog') %]<i class="log-disabled fa-solid fa-triangle-exclamation" title="Log not enabled" data-log="AuthoritiesLog"></i>[% END %]
    [% CASE 'MEMBERS' %]
        <span>Patrons</span>[% UNLESS Koha.Preference('BorrowersLog') %]<i class="log-disabled fa-solid fa-triangle-exclamation" title="Log not enabled" data-log="BorrowersLog"></i>[% END %]
    [% CASE 'ACQUISITIONS' %]
        <span>Acquisitions</span>[% UNLESS Koha.Preference('AcquisitionLog') %]<i class="log-disabled fa-solid fa-triangle-exclamation" title="Log not enabled" data-log="AcquisitionLog"></i>[% END %]
    [% CASE 'SERIAL' %]
        <span>Serials</span>[% UNLESS Koha.Preference('SubscriptionLog') %]<i class="log-disabled fa-solid fa-triangle-exclamation" title="Log not enabled" data-log="SubscriptionLog"></i>[% END %]
    [% CASE 'HOLDS' %]
        <span>Holds</span>[% UNLESS Koha.Preference('HoldsLog') %]<i class="log-disabled fa-solid fa-triangle-exclamation" title="Log not enabled" data-log="HoldsLog"></i>[% END %]
    [% CASE 'ILL' %]
        <span>Interlibrary loans</span>[% UNLESS Koha.Preference('IllLog') %]<i class="log-disabled fa-solid fa-triangle-exclamation" title="Log not enabled" data-log="IllLog"></i>[% END %]
    [% CASE 'CIRCULATION' %]
        <span>Circulation</span>[% UNLESS Koha.Preference('IssueLog') %]<i class="log-disabled fa-solid fa-triangle-exclamation" title="Log not enabled" data-log="IssueLog"></i>[% END %]
    [% CASE 'CLAIMS' %]
        <span>Claims</span>[% UNLESS Koha.Preference('ClaimsLog') %]<i class="log-disabled fa-solid fa-triangle-exclamation" title="Log not enabled" data-log="ClaimsLog"></i>[% END %]
    [% CASE 'FINES' %]
        <span>Fines</span>[% UNLESS Koha.Preference('FinesLog') %]<i class="log-disabled fa-solid fa-triangle-exclamation" title="Log not enabled" data-log="FinesLog"></i>[% END %]
    [% CASE 'SYSTEMPREFERENCE' %]
        <span>System preferences</span>
    [% CASE 'CRONJOBS' %]
        <span>Cron jobs</span>[% UNLESS Koha.Preference('CronjobLog') %]<i class="log-disabled fa-solid fa-triangle-exclamation" title="Log not enabled" data-log="CronjobLog"></i>[% END %]
    [% CASE 'REPORTS' %]
        <span>Reports</span>[% UNLESS Koha.Preference('ReportsLog') %]<i class="log-disabled fa-solid fa-triangle-exclamation" title="Log not enabled" data-log="ReportsLog"></i>[% END %]
    [% CASE 'SEARCHENGINE' %]
        <span>Search engine</span>
    [% CASE 'NOTICES' %]
        <span>Notices</span>[% UNLESS Koha.Preference('NoticesLog') %]<i class="log-disabled fa-solid fa-triangle-exclamation" title="Log not enabled" data-log="NoticesLog"></i>[% END %]
    [% CASE 'NEWS' %]
        <span>Additional content</span>[% UNLESS Koha.Preference('AdditionalContentLog') %]<i class="log-disabled fa-solid fa-triangle-exclamation" title="Log not enabled" data-log="AdditionalContentLog"></i>[% END %]
    [% CASE 'RECALLS' %]
        <span>Recalls</span>[% UNLESS Koha.Preference('RecallsLog') %]<i class="log-disabled fa-solid fa-triangle-exclamation" title="Log not enabled" data-log="RecallsLog"></i>[% END %]
    [% CASE 'SUGGESTION' %]
        <span>Suggestions</span>[% UNLESS Koha.Preference('SuggestionsLog') %]<i class="log-disabled fa-solid fa-triangle-exclamation" title="Log not enabled" data-log="SuggestionsLog"></i>[% END %]
    [% CASE 'TRANSFERS' %]
        <span>Transfers</span>[% UNLESS Koha.Preference('TransfersLog') %]<i class="log-disabled fa-solid fa-triangle-exclamation" title="Log not enabled" data-log="TransfersLog"></i>[% END %]
    [% CASE %]
        [% module | html %]
    [% END %]
[% END %]

[% BLOCK translate_log_action %]
    [% SWITCH action %]
    [% CASE 'ACTIVATE' %]
        <span>Activate</span>
    [% CASE 'ADD' %]
        <span>Add</span>
    [% CASE 'DELETE' %]
        <span>Delete</span>
    [% CASE 'MODIFY' %]
        <span>Modify</span>
    [% CASE 'REVOKE' %]
        <span>Revoke</span>
    [% CASE 'ISSUE' %]
        <span>Checkout</span>
    [% CASE 'RETURN' %]
        <span>Return</span>
    [% CASE 'CREATE' %]
        <span>Create</span>
    [% CASE 'CANCEL' %]
        <span>Cancel</span>
    [% CASE 'FILL' %]
        <span>Fill</span>
    [% CASE 'RESUME' %]
        <span>Resume</span>
    [% CASE 'SUSPEND' %]
        <span>Suspend</span>
    [% CASE 'RENEW' %]
        <span>Renew</span>
    [% CASE 'RENEWAL' %]
        <span>Renew</span>
    [% CASE 'CHANGE PASS' %]
        <span>Change password</span>
    [% CASE 'RESET PASS' %]
        <span>Reset password</span>
    [% CASE 'ADDCIRCMESSAGE' %]
        <span>Add circulation message</span>
    [% CASE 'MODCIRCMESSAGE' %]
        <span>Modify circulation message</span>
    [% CASE 'DELCIRCMESSAGE' %]
        <span>Delete circulation message</span>
    [% CASE 'STATUS_CHANGE' %]
        <span>Change ILL request status</span>
    [% CASE 'PATRON_NOTICE' %]
        <span>ILL notice sent to patron</span>
    [% CASE 'ADD_BASKET' %]
        <span>Create an acquisitions basket</span>
    [% CASE 'MODIFY_BASKET' %]
        <span>Modify an acquisitions basket</span>
    [% CASE 'MODIFY_BASKET_HEADER' %]
        <span>Modify an acquisitions basket header</span>
    [% CASE 'MODIFY_BASKET_USERS' %]
        <span>Modify an acquisitions basket's users</span>
    [% CASE 'CLOSE_BASKET' %]
        <span>Close an acquisitions basket</span>
    [% CASE 'APPROVE_BASKET' %]
        <span>Approve an acquisitions basket</span>
    [% CASE 'REOPEN_BASKET' %]
        <span>Reopen an acquisitions basket</span>
    [% CASE 'CANCEL_ORDER' %]
        <span>Cancel an order</span>
    [% CASE 'CREATE_ORDER' %]
        <span>Create an order</span>
    [% CASE 'MODIFY_ORDER' %]
        <span>Modify an order</span>
    [% CASE 'CREATE_INVOICE_ADJUSTMENT' %]
        <span>Create an invoice adjustment</span>
    [% CASE 'UPDATE_INVOICE_ADJUSTMENT' %]
        <span>Modify an invoice adjustment</span>
    [% CASE 'DELETE_INVOICE_ADJUSTMENT' %]
        <span>Delete an invoice adjustment</span>
    [% CASE 'RECEIVE_ORDER' %]
        <span>Receive an order</span>
    [% CASE 'MODIFY_BUDGET' %]
        <span>Modify a budget</span>
    [% CASE 'CREATE_FUND' %]
        <span>Create a fund</span>
    [% CASE 'MODIFY_FUND' %]
        <span>Modify a fund</span>
    [% CASE 'DELETE_FUND' %]
        <span>Delete a fund</span>
    [% CASE 'CREATE_RESTRICTION' %]
        <span>Create restriction</span>
    [% CASE 'MODIFY_RESTRICTION' %]
        <span>Modify restriction</span>
    [% CASE 'DELETE_RESTRICTION' %]
        <span>Delete restriction</span>
    [% CASE 'Run' %]
        <span>Run</span>
    [% CASE 'End' %]
        <span>End</span>
    [% CASE 'PATRON_MERGE' %]
        <span>Merge</span>
    [% CASE 'EDIT_MAPPINGS' %]
        <span>Edit mappings</span>
    [% CASE 'RESET_MAPPINGS' %]
        <span>Reset mappings</span>
    [% CASE 'SERIAL CLAIM' %]
        <span>Serial claim</span>
    [% CASE 'ACQUISITION CLAIM' %]
        <span>Acquisition claim</span>
    [% CASE 'ACQUISITION ORDER' %]
        <span>Acquisition order</span>
    [% CASE 'OVERDUE' %]
        <span>Overdue</span>
    [% CASE 'EXPIRE' %]
        <span>Expire</span>
    [% CASE 'MODIFY_CARDNUMBER' %]
        <span>Modify cardnumber</span>
    [% CASE 'RESET 2FA' %]
        <span>Reset 2FA</span>
    [% CASE %]
        [% action | html %]
    [% END %]
[% END %]

[% BLOCK translate_log_interface %]
    [% SWITCH log_interface.upper %]
    [% CASE 'INTRANET' %]
        <span>Staff interface</span>
    [% CASE 'OPAC' %]
        <span>OPAC</span>
    [% CASE 'SIP' %]
        <span>SIP</span>
    [% CASE 'COMMANDLINE' %]
        <span>Command-line</span>
    [% CASE 'API' %]
        <span>REST API</span>
    [% CASE 'CRON' %]
        <span>Cron job</span>
    [% CASE 'UPGRADE' %]
        <span>Upgrade</span>
    [% CASE %]
        <span>[% log_interface | html %]</span>
    [% END %]
[% END %]

[% BLOCK translate_log_override %]
    [% SWITCH override %]
    [% CASE 'HOLD_POLICY_OVERRIDE' %]
        <span>Hold policy override</span>
    [% CASE 'INVALID_DATE' %]
        <span>Invalid date confirmed</span>
    [% CASE 'DEBT_GUARANTEES' %]
        <span>Guarantees had debts</span>
    [% CASE 'DEBT_GUARANTORS' %]
        <span>Guarantors had debts</span>
    [% CASE 'DEBT' %]
        <span>Patron had debt</span>
    [% CASE 'USERBLOCKEDOVERDUE' %]
        <span>Patron had overdues</span>
    [% CASE 'USERBLOCKEDNOENDDATE' %]
        <span>Patron had an indefinite restriction</span>
    [% CASE 'ADDITIONAL_MATERIALS' %]
        <span>Additional materials were confirmed</span>
    [% CASE 'RENEW_ISSUE' %]
        <span>Renewal</span>
    [% CASE 'ISSUED_TO_ANOTHER' %]
        <span>Item was issued to another patron prior to this checkout</span>
    [% CASE 'PATRON_CANT' %]
        <span>Max renewals reached</span>
    [% CASE 'TOO_MANY' %]
        <span>Too many checkouts</span>
    [% CASE 'PREVISSUE' %]
        <span>Patron was notified of previous issues</span>
    [% CASE 'NOT_FOR_LOAN' %]
        <span>Item was not for loan</span>
    [% CASE 'NOT_FOR_LOAN_FORCING' %]
        <span>Item was not for loan</span>
    [% CASE 'ITEM_LOST' %]
        <span>Item was reported lost</span>
    [% CASE 'BORRNOTSAMEBRANCH' %]
        <span>Patron does not belong to this library</span>
    [% CASE 'RENTALCHARGE' %]
        <span>Item had a rental charge</span>
    [% CASE 'RECALLED' %]
        <span>Item was recalled</span>
    [% CASE 'RESERVE_WAITING' %]
        <span>Hold waiting on item</span>
    [% CASE 'RESERVED' %]
        <span>Hold placed on item</span>
    [% CASE 'TRANSFERRED' %]
        <span>Item was transferred</span>
    [% CASE 'PROCESSING' %]
        <span>Item was in processing</span>
    [% CASE 'BOOKED_EARLY' %]
        <span>Item was booked and checked out early</span>
    [% CASE 'BOOKED_TO_ANOTHER' %]
        <span>Item was booked to another patron</span>
    [% CASE 'AGE_RESTRICTION' %]
        <span>Item has an age restriction</span>
    [% CASE 'HIGHHOLDS' %]
        <span>Item had high holds</span>
    [% CASE 'BIBLIO_ALREADY_ISSUED' %]
        <span>Biblio was already issued</span>
    [% CASE 'DEBARRED' %]
        <span>Patron is restricted</span>
    [% CASE 'RENEWAL_LIMIT' %]
        <span>Renewal limit override</span>
    [% CASE 'UNSEEN_LIMIT' %]
        <span>Override unseen item restriction</span>
    [% CASE 'AUTO_TOO_SOON' %]
        <span>Override auto-renew too soon restriction</span>
    [% CASE 'AUTO_TOO_LATE' %]
        <span>Override auto-renew too late restriction</span>
    [% CASE 'ACCOUNT_EXPIRED' %]
        <span>Account expired override</span>
    [% CASE 'ON_RESERVE' %]
        <span>Override renew hold for another</span>
    [% CASE 'TOO_MUCH' %]
        <span>Override auto-renew too much owing restriction</span>
    [% CASE 'CURRENTISSUE' %]
        <span>Item is currently checked out to this patron</span>
    [% CASE 'UNSEEN' %]
        <span>Unseen renewal</span>
    [% CASE 'SEEN' %]
        <span>Seen renewal</span>
    [% CASE %]
        <span>[% override | html %]</span>
    [% END %]
[% END %]
