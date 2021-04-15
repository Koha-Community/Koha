[% USE AuthorisedValues %]
[% SET payment_types = [] %]
[% FOR pt IN AuthorisedValues.GetAuthValueDropbox('PAYMENT_TYPE') %]
    [% NEXT IF pt.authorised_value.grep("^SIP[[:digit:]]{2}$").size() %]
    [% payment_types.push(pt) %]
[% END %]
[% IF payment_types.size > 0 %]
    <li>
        [% IF Koha.Preference('UseCashRegisters') %]
            <label for="[% type | html %]_type" class="required">[% IF type == 'payment' %]Payment[% ELSE %]Transaction[% END %] type: </label>
            <select name="[% type | html %]_type" id="[% type | html %]_type" class="required" required="required">
                [% IF type == 'refund' %]
                <option value="AC">Account credit</option>
                [% END %]
                [% FOREACH pt IN payment_types %]
                    <option value="[% pt.authorised_value | html %]">[% pt.lib | html %]</option>
                [% END %]
            </select>
            <span class="required">Required</span>
        [%- ELSE -%]
            <label for="[% type | html %]_type">[% IF type == 'payment' %]Payment[% ELSE %]Transaction[% END %] type: </label>
            <select name="[% type | html %]_type" id="[% type | html %]_type">
                <option value=""></option>
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
