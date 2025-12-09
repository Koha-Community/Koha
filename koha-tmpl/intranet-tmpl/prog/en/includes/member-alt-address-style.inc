[% USE Koha %]
[% USE AuthorisedValues %]
[% BLOCK 'alt-address-style' %]
    <fieldset class="rows" id="memberentry_address">
        <legend class="expanded" id="alt_address_lgd">
            <i class="fa fa-caret-down"></i>
            Alternate address
        </legend>
        <ol>
            [% IF Koha.Preference( 'AddressFormat' ) %]
                [% PROCESS "member-alt-address-style-${ Koha.Preference( 'AddressFormat' ) }" %]
            [% ELSE %]
                [% PROCESS 'member-alt-address-style-us' %]
            [% END %]
        </ol>
    </fieldset>
[% END %]

[% BLOCK 'member-alt-address-style-us' %]
    [% PROCESS 'alt-address-style_B_streetnumber' %]
    [% PROCESS 'alt-address-style_roadtypes' %]
    [% PROCESS 'alt-address-style_B_address' %]
    [% PROCESS 'alt-address-style_B_address2' %]
    [% PROCESS 'alt-address-style_B_city' %]
    [% PROCESS 'alt-address-style_B_state' %]
    [% PROCESS 'alt-address-style_B_zipcode' %]
    [% PROCESS 'alt-address-style_B_country' %]
    [% PROCESS 'alt-address-style_B_phone' %]
    [% PROCESS 'alt-address-style_B_email' %]
    [% PROCESS 'alt-address-style_B_contactnote' %]
[% END %]

[% BLOCK 'member-alt-address-style-de' %]
    [% PROCESS 'alt-address-style_roadtypes' %]
    [% PROCESS 'alt-address-style_B_address' %]
    [% PROCESS 'alt-address-style_B_streetnumber' %]
    [% PROCESS 'alt-address-style_B_address2' %]
    [% PROCESS 'alt-address-style_B_zipcode' %]
    [% PROCESS 'alt-address-style_B_city' %]
    [% PROCESS 'alt-address-style_B_state' %]
    [% PROCESS 'alt-address-style_B_country' %]
    [% PROCESS 'alt-address-style_B_phone' %]
    [% PROCESS 'alt-address-style_B_email' %]
    [% PROCESS 'alt-address-style_B_contactnote' %]
[% END %]

[% BLOCK 'member-alt-address-style-fr' %]
    [% PROCESS 'alt-address-style_B_streetnumber' %]
    [% PROCESS 'alt-address-style_roadtypes' %]
    [% PROCESS 'alt-address-style_B_address' %]
    [% PROCESS 'alt-address-style_B_address2' %]
    [% PROCESS 'alt-address-style_B_zipcode' %]
    [% PROCESS 'alt-address-style_B_city' %]
    [% PROCESS 'alt-address-style_B_state' %]
    [% PROCESS 'alt-address-style_B_country' %]
    [% PROCESS 'alt-address-style_B_phone' %]
    [% PROCESS 'alt-address-style_B_email' %]
    [% PROCESS 'alt-address-style_B_contactnote' %]
[% END %]

[% BLOCK 'alt-address-style_roadtypes' %]
    [% SET roadtypes = AuthorisedValues.GetAuthValueDropbox('ROADTYPE') %]
    [% IF roadtypes.count %]
        [% UNLESS noB_streettype %]
            <li>
                <label for="B_streettype" [% IF mandatoryB_streettype %]class="required"[% END %]>Street type: </label>
                <select name="B_streettype">
                    <option value=""></option>
                    [% FOR roadtype IN roadtypes %]
                        [% IF roadtype.authorised_value == patron.B_streettype %]
                            <option value="[% roadtype.authorised_value | html %]" selected="selected">[% roadtype.lib | html %]</option>
                        [% ELSE %]
                            <option value="[% roadtype.authorised_value | html %]">[% roadtype.lib | html %]</option>
                        [% END %]
                    [% END %]
                </select>
                [% IF ( mandatoryB_streettype ) %]<span class="required">Required</span>[% END %]
            </li>
        [% END %]
    [% END %]
[% END %]

[% BLOCK 'alt-address-style_B_address' %]
    [% UNLESS noB_address %]
        <li>
            <label for="B_address" [% IF mandatoryB_address %]class="required"[% END %]>Address: </label>
            <input type="text" id="B_address" name="B_address" size="40" value="[% patron.B_address | html %]" />
            [% IF ( mandatoryB_address ) %]<span class="required">Required</span>[% END %]
        </li>
    [% END %]
[% END %]

[% BLOCK 'alt-address-style_B_streetnumber' %]
    [% UNLESS noB_streetnumber %]
        <li>
            <label for="B_streetnumber" [% IF mandatoryB_streetnumber %]class="required"[% END %]>Street number: </label>
            <input type="text" id="B_streetnumber" name="B_streetnumber" value="[% patron.B_streetnumber | html %]" />
            [% IF ( mandatoryB_streetnumber ) %]<span class="required">Required</span>[% END %]
        </li>
    [% END %]
[% END %]

[% BLOCK 'alt-address-style_B_address2' %]
    [% UNLESS noB_address2 %]
        <li>
            <label for="B_address2" [% IF mandatoryB_address2 %]class="required"[% END %]>Address 2: </label>
            <input type="text" id="B_address2" name="B_address2" size="40" value="[% patron.B_address2 | html %]" />
            [% IF ( mandatoryB_address2 ) %]<span class="required">Required</span>[% END %]
        </li>
    [% END %]
[% END %]

[% BLOCK 'alt-address-style_B_zipcode' %]
    [% UNLESS noB_zipcode %]
        <li>
            <label for="B_zipcode" [% IF mandatoryB_zipcode %]class="required"[% END %]>ZIP/Postal code: </label>
            <input type="text" id="B_zipcode" name="B_zipcode" maxlength="10" size="10" value="[% patron.B_zipcode | html %]" />
            [% IF ( mandatoryB_zipcode ) %]<span class="required">Required</span>[% END %]
        </li>
    [% END %]
[% END %]

[% BLOCK 'alt-address-style_B_city' %]
    [% UNLESS noB_city %]
        <li>
            <label for="B_city" [% IF mandatoryB_city %]class="required"[% END %]>City: </label>
            [% IF cities.count %]
                <select class="select_city" data-addressfield="B_" name="select_city">
                    <option value="|||"></option>
                    [% FOREACH c IN cities %]
                        [% SET option_value = c.city_zipcode _ '|' _ c.city_name _ '|' _ c.city_state _ '|' _ c.city_country %]
                        [% SET option_selected = 0 %]
                        [% IF c.city_name == patron.B_city && c.city_state == patron.B_state && c.city_zipcode == patron.B_zipcode %]
                            [% option_selected = 1 %]
                        [% END %]
                        <option value="[% option_value | html %]" [% IF option_selected %]selected="selected"[% END %]> [% c.city_name | html %] [% c.city_state | html %] [% c.city_zipcode | html %] </option>
                    [% END %]
                </select>
                <span class="hint">or enter</span>
            [% END %]
            <input type="text" id="B_city" name="B_city" size="20" value="[% patron.B_city | html %]" />
            [% IF ( mandatoryB_city ) %]<span class="required">Required</span>[% END %]
        </li>
    [% END %]
[% END %]

[% BLOCK 'alt-address-style_B_state' %]
    [% UNLESS noB_state %]
        <li>
            <label for="B_state" [% IF mandatoryB_state %]class="required"[% END %]>State: </label>
            <input type="text" id="B_state" name="B_state" size="20" value="[% patron.B_state | html %]" />
            [% IF ( mandatoryB_state ) %]<span class="required">Required</span>[% END %]
        </li>
    [% END %]
[% END %]

[% BLOCK 'alt-address-style_B_country' %]
    [% UNLESS noB_country %]
        <li>
            <label for="B_country" [% IF mandatoryB_country %]class="required"[% END %]>Country: </label>
            <input type="text" id="B_country" name="B_country" size="20" value="[% patron.B_country | html %]" />
            [% IF ( mandatoryB_country ) %]<span class="required">Required</span>[% END %]
        </li>
    [% END %]
[% END %]

[% BLOCK 'alt-address-style_B_phone' %]
    [% UNLESS noB_phone %]
        <li>
            <label for="B_phone" [% IF mandatoryB_phone %]class="required"[% END %]>Phone: </label>
            <input type="text" id="B_phone" name="B_phone" value="[% patron.B_phone | html %]" />
            [% IF ( mandatoryB_phone ) %]<span class="required">Required</span>[% END %]
        </li>
    [% END %]
[% END %]

[% BLOCK 'alt-address-style_B_email' %]
    [% UNLESS noB_email %]
        <li>
            <label for="B_email" [% IF mandatoryB_email %]class="required"[% END %]>Email: </label>
            [% IF ( NoUpdateEmail ) %]
                <input type="text" id="B_email" name="B_email" size="45" value="[% patron.B_email | html %]" disabled="disabled" />
            [% ELSE %]
                <input type="text" id="B_email" name="B_email" size="45" value="[% patron.B_email | html %]" />
            [% END %]
            [% IF ( mandatoryB_email ) %]<span class="required">Required</span>[% END %]
        </li>
    [% END %]
[% END %]

[% BLOCK 'alt-address-style_B_contactnote' %]
    [% UNLESS nocontactnote %]
        <li>
            <label for="contactnote" [% IF mandatorycontactnote %]class="required"[% END %]>Contact note: </label>
            <textarea id="contactnote" name="contactnote" cols="40" rows="2">[% patron.contactnote | html %]</textarea>
            [% IF ( mandatorycontactnote ) %]<span class="required">Required</span>[% END %]
        </li>
    [% END %]
[% END %]
