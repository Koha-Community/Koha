[% USE Koha %]
[% SET hold_cancellation = AuthorisedValues.GetAuthValueDropbox('HOLD_CANCELLATION') %]
[% USE AuthorisedValues %]

[%#This include depends on the asset js/form-submit.js. Any template making use of this include must import form-submit.js as well. %]
[%#FIXME can form-submit.js be imported into this file directly? %]

<table id="patron_holds_table_[% biblio_id | html %]_[% split_data | html %]" class="holds_table" data-total-holds="[% total_holds | html %]">
    <thead>
        <tr>
            <th id="checkbox" data-colname="checkbox"><input type="checkbox" class="select_hold_all" /></th>
            <th id="priority" data-colname="priority">Priority</th>
            <th id="change_priority" data-colname="change_priority">Change priority</th>
            <th id="patron" data-colname="patron">Patron</th>
            <th id="notes" data-colname="notes">Notes</th>
            <th id="date" data-colname="date">Date</th>
            <th id="expiration" data-colname="expiration">Expiration</th>
            <th id="pickup_library" data-colname="pickup_library">Pickup library</th>
            <th id="details" data-colname="details">Details</th>
            <th id="set_lowest_priority" data-colname="set_lowest_priority"><span style="display:none;">Set lowest priority</span><i class="fa fa-lg fa-rotate-90 fa-fast-forward" title="Toggle set to lowest priority"></i></th>
            <th id="delete" data-colname="delete">Delete</th>
            <th id="suspend" data-colname="suspend">Suspend</th>
            <th id="print_slip" data-colname="print_slip">Print hold/transfer slip</th>
        </tr>
    </thead>
</table>
