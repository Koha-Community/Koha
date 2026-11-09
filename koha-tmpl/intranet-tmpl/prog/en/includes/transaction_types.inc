[% USE AuthorisedValues %]
[% USE Registers %]
[% SET payment_types = [] %]
[%# CASH cannot be paid out or refunded when the current library has no cash register %]
[% SET hide_cash = 0 %]
[% IF ( type == 'payout' || type == 'refund' ) && Koha.Preference('UseCashRegisters') && Registers.all( filters => { current_branch => 1 } ).size == 0 %]
    [% SET hide_cash = 1 %]
[% END %]
[% FOR pt IN AuthorisedValues.GetAuthValueDropbox('PAYMENT_TYPE') %]
    [% NEXT IF pt.authorised_value.grep("^SIP[[:digit:]]{2}$").size() %]
    [% NEXT IF hide_cash && pt.authorised_value == 'CASH' %]
    [% payment_types.push(pt) %]
[% END %]
[% IF payment_types.size > 0 %]
    <li>
        [% IF Koha.Preference('UseCashRegisters') || Koha.Preference('RequirePaymentType') %]
            <label for="[% type | html %]_type" class="required">[% IF type == 'payment' %]<span>Payment type:</span>[% ELSE %]<span>Transaction type:</span>[% END %] </label>
            <select name="[% type | html %]_type" id="[% type | html %]_type" class="required" required="required">
                <option value="">None selected</option>
                [% IF type == 'refund' %]
                    <option value="AC">Account credit</option>
                [% END %]
                [% FOREACH pt IN payment_types %]
                    <option value="[% pt.authorised_value | html %]">[% pt.lib | html %]</option>
                [% END %]
            </select>
            <span class="required">Required</span>
        [%- ELSE -%]
            <label for="[% type | html %]_type">[% IF type == 'payment' %]<span>Payment type:</span>[% ELSE %]<span>Transaction type:</span>[% END %] </label>
            <select name="[% type | html %]_type" id="[% type | html %]_type">
                <option value="">None selected</option>
                [% IF type == 'refund' %]
                    <option value="AC">Account credit</option>
                [% END %]
                [% FOREACH pt IN payment_types %]
                    <option value="[% pt.authorised_value | html %]">[% pt.lib | html %]</option>
                [% END %]
            </select>
        [%- END -%]
    </li>
[% END %]
