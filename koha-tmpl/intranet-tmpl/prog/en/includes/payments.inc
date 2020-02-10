[% USE AuthorisedValues %]
[%- BLOCK account_payment_types -%]
    [% SET payment_types = [] %]
    [% FOR pt IN AuthorisedValues.GetAuthValueDropbox('PAYMENT_TYPE') %]
        [% NEXT IF pt.authorised_value.grep("^SIP[[:digit:]]{2}$").size() %]
        [% payment_types.push(pt) %]
    [% END %]
    [% IF payment_types.size > 0 %]
        <li>
            <label for="payment_type">Payment type: </label>
            [% IF Koha.Preference('UseCashRegisters') %]
            <select name="payment_type" id="payment_type" required>
            [% ELSE %]
            <select name="payment_type" id="payment_type">
                <option value=""></option>
            [% END %]
                [% FOREACH pt IN payment_types %]
                    <option value="[% pt.authorised_value | html %]">[% pt.lib | html %]</option>
                [% END %]
            </select>
        </li>
    [% END %]
[%- END -%]
