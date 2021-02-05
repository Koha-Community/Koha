[% USE AuthorisedValues %]
[%- BLOCK account_payment_types -%]
    [% SET payment_types = [] %]
    [% FOR pt IN AuthorisedValues.GetAuthValueDropbox('PAYMENT_TYPE') %]
        [% NEXT IF pt.authorised_value.grep("^SIP[[:digit:]]{2}$").size() %]
        [% payment_types.push(pt) %]
    [% END %]
    [% IF payment_types.size > 0 %]
        <li>
            [% IF Koha.Preference('UseCashRegisters') %]
                <label for="payment_type" class="required">Payment type: </label>
                <select name="payment_type" id="payment_type" class="required" required="required">
                    [% FOREACH pt IN payment_types %]
                        <option value="[% pt.authorised_value | html %]">[% pt.lib | html %]</option>
                    [% END %]
                </select>
                <span class="required">Required</span>
            [%- ELSE -%]
                <label for="payment_type">Payment type: </label>
                <select name="payment_type" id="payment_type">
                    <option value=""></option>
                    [% FOREACH pt IN payment_types %]
                        <option value="[% pt.authorised_value | html %]">[% pt.lib | html %]</option>
                    [% END %]
                </select>
            [%- END -%]
        </li>
    [% END %]
[%- END -%]
