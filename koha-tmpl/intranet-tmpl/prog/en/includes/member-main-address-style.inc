[% USE Koha %]
[% USE AuthorisedValues %]
[% BLOCK 'main-address-style' %]
    <fieldset class="rows" id="memberentry_mainaddress">
        <legend class="expanded" id="main_address_lgd">
            <i class="fa fa-caret-down"></i>
            Main address
        </legend>
        <ol>
            [% IF Koha.Preference( 'AddressFormat' ) %]
                [% PROCESS "member-main-address-style-${ Koha.Preference( 'AddressFormat' ) }" %]
            [% ELSE %]
                [% PROCESS 'member-main-address-style-us' %]
            [% END %]
        </ol>
    </fieldset>
[% END %]

[% BLOCK 'member-main-address-style-us' %]
    [% PROCESS 'address-style_streetnumber' %]
    [% PROCESS 'address-style_roadtypes' %]
    [% PROCESS 'address-style_address' %]
    [% PROCESS 'address-style_address2' %]
    [% PROCESS 'address-style_city' %]
    [% PROCESS 'address-style_state' %]
    [% PROCESS 'address-style_zipcode' %]
    [% PROCESS 'address-style_country' %]
[% END %]

[% BLOCK 'member-main-address-style-de' %]
    [% PROCESS 'address-style_roadtypes' %]
    [% PROCESS 'address-style_address' %]
    [% PROCESS 'address-style_streetnumber' %]
    [% PROCESS 'address-style_address2' %]
    [% PROCESS 'address-style_zipcode' %]
    [% PROCESS 'address-style_city' %]
    [% PROCESS 'address-style_state' %]
    [% PROCESS 'address-style_country' %]
[% END %]

[% BLOCK 'member-main-address-style-fr' %]
    [% PROCESS 'address-style_streetnumber' %]
    [% PROCESS 'address-style_roadtypes' %]
    [% PROCESS 'address-style_address' %]
    [% PROCESS 'address-style_address2' %]
    [% PROCESS 'address-style_zipcode' %]
    [% PROCESS 'address-style_city' %]
    [% PROCESS 'address-style_state' %]
    [% PROCESS 'address-style_country' %]
[% END %]

[% BLOCK 'address-style_roadtypes' %]
    [% SET roadtypes = AuthorisedValues.GetAuthValueDropbox('ROADTYPE') %]
    [% IF roadtypes.count %]
        [% UNLESS nostreettype %]
            <li>
                <label for="streettype" [% IF mandatorystreettype %]class="required"[% END %]>Street type: </label>
                <select name="streettype">
                    <option value=""></option>
                    [% FOR roadtype IN roadtypes %]
                        [% IF roadtype.authorised_value == patron.streettype %]
                            <option value="[% roadtype.authorised_value | html %]" selected="selected">[% roadtype.lib | html %]</option>
                        [% ELSE %]
                            <option value="[% roadtype.authorised_value | html %]">[% roadtype.lib | html %]</option>
                        [% END %]
                    [% END %]
                </select>
                [% IF ( mandatorystreettype ) %]<span class="required">Required</span>[% END %]
            </li>
        [% END %]
    [% END %]
[% END %]

[% BLOCK 'address-style_address' %]
    [% UNLESS noaddress %]
        <li>
            <label for="address" [% IF mandatoryaddress %]class="required"[% END %]>Address: </label>
            <input type="text" id="address" name="address" size="40" value="[% patron.address | html %]" />
            [% IF ( mandatoryaddress ) %]<span class="required">Required</span>[% END %]
        </li>
    [% END %]
[% END %]

[% BLOCK 'address-style_streetnumber' %]
    [% UNLESS nostreetnumber %]
        <li>
            <label for="streetnumber" [% IF mandatorystreetnumber %]class="required"[% END %]>Street number: </label>
            <input type="text" id="streetnumber" name="streetnumber" size="5" maxlength="10" value="[% patron.streetnumber | html %]" />
            [% IF ( mandatorystreetnumber ) %]<span class="required">Required</span>[% END %]
        </li>
    [% END %]
[% END %]

[% BLOCK 'address-style_address2' %]
    [% UNLESS noaddress2 %]
        <li>
            <label for="address2" [% IF mandatoryaddress2 %]class="required"[% END %]>Address 2: </label>
            <input type="text" id="address2" name="address2" size="40" value="[% patron.address2 | html %]" />
            [% IF ( mandatoryaddress2 ) %]<span class="required">Required</span>[% END %]
        </li>
    [% END %]
[% END %]

[% BLOCK 'address-style_zipcode' %]
    [% UNLESS nozipcode %]
        <li>
            <label for="zipcode" [% IF mandatoryzipcode %]class="required"[% END %]>ZIP/Postal code: </label>
            <input type="text" id="zipcode" name="zipcode" maxlength="10" size="10" value="[% patron.zipcode | html %]" />
            [% IF ( mandatoryzipcode ) %]<span class="required">Required</span>[% END %]
        </li>
    [% END %]
[% END %]

[% BLOCK 'address-style_city' %]
    [% UNLESS nocity %]
        <li>
            <label for="city" [% IF mandatorycity %]class="required"[% END %]>City: </label>
            [% IF cities.count %]
                <select class="select_city" data-addressfield="" name="select_city">
                    <option value="|||"></option>
                    [% FOREACH c IN cities %]
                        [% SET option_value = c.city_zipcode _ '|' _ c.city_name _ '|' _ c.city_state _ '|' _ c.city_country %]
                        [% SET option_selected = 0 %]
                        [% IF c.city_name == patron.city && c.city_state == patron.state && c.city_zipcode == patron.zipcode %]
                            [% option_selected = 1 %]
                        [% END %]
                        <option value="[% option_value | html %]" [% IF option_selected %]selected="selected"[% END %]> [% c.city_name | html %] [% c.city_state | html %] [% c.city_zipcode | html %] </option>
                    [% END %]
                </select>
                <span class="hint">or enter</span>
            [% END %]
            <input type="text" id="city" name="city" size="20" value="[% patron.city | html %]" />
            [% IF ( mandatorycity ) %]<span class="required">Required</span>[% END %]
        </li>
    [% END %]
[% END %]

[% BLOCK 'address-style_state' %]
    [% UNLESS nostate %]
        <li>
            <label for="state" [% IF mandatorystate %]class="required"[% END %]>State: </label>
            <input type="text" id="state" name="state" size="20" value="[% patron.state | html %]" />
            [% IF ( mandatorystate ) %]<span class="required">Required</span>[% END %]
        </li>
    [% END %]
[% END %]

[% BLOCK 'address-style_country' %]
    [% UNLESS nocountry %]
        <li>
            <label for="country" [% IF mandatorycountry %]class="required"[% END %]>Country: </label>
            <input type="text" id="country" name="country" size="20" value="[% patron.country | html %]" />
            [% IF ( mandatorycountry ) %]<span class="required">Required</span>[% END %]
        </li>
    [% END %]
[% END %]
