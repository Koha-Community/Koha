[% USE Koha %]
[% BLOCK 'alt-contact-style' %]
    <fieldset class="rows" id="memberentry_altaddress">
        <legend class="expanded" id="alt_contact_lgd">
            <i class="fa fa-caret-down"></i>
            Alternate contact
        </legend>
        <ol>
            [% IF Koha.Preference( 'AddressFormat' ) %]
                [% PROCESS "member-alt-contact-style-${ Koha.Preference( 'AddressFormat' ) }" %]
            [% ELSE %]
                [% PROCESS 'member-alt-contact-style-us' %]
            [% END %]
        </ol>
    </fieldset>
[% END %]

[% BLOCK 'member-alt-contact-style-us' %]
    [% PROCESS 'alt-contact-style_altcontactsurname' %]
    [% PROCESS 'alt-contact-style_altcontactfirstname' %]
    [% PROCESS 'alt-contact-style_altcontactaddress1' %]
    [% PROCESS 'alt-contact-style_altcontactaddress2' %]
    [% PROCESS 'alt-contact-style_altcontactaddress3' %]
    [% PROCESS 'alt-contact-style_altcontactstate' %]
    [% PROCESS 'alt-contact-style_altcontactzipcode' %]
    [% PROCESS 'alt-contact-style_altcontactcountry' %]
    [% PROCESS 'alt-contact-style_altcontactphone' %]
[% END %]

[% BLOCK 'member-alt-contact-style-de' %]
    [% PROCESS 'alt-contact-style_altcontactsurname' %]
    [% PROCESS 'alt-contact-style_altcontactfirstname' %]
    [% PROCESS 'alt-contact-style_altcontactaddress1' %]
    [% PROCESS 'alt-contact-style_altcontactaddress2' %]
    [% PROCESS 'alt-contact-style_altcontactzipcode' %]
    [% PROCESS 'alt-contact-style_altcontactaddress3' %]
    [% PROCESS 'alt-contact-style_altcontactstate' %]
    [% PROCESS 'alt-contact-style_altcontactcountry' %]
    [% PROCESS 'alt-contact-style_altcontactphone' %]
[% END %]

[% BLOCK 'member-alt-contact-style-fr' %]
    [% PROCESS 'alt-contact-style_altcontactsurname' %]
    [% PROCESS 'alt-contact-style_altcontactfirstname' %]
    [% PROCESS 'alt-contact-style_altcontactaddress1' %]
    [% PROCESS 'alt-contact-style_altcontactaddress2' %]
    [% PROCESS 'alt-contact-style_altcontactzipcode' %]
    [% PROCESS 'alt-contact-style_altcontactaddress3' %]
    [% PROCESS 'alt-contact-style_altcontactstate' %]
    [% PROCESS 'alt-contact-style_altcontactcountry' %]
    [% PROCESS 'alt-contact-style_altcontactphone' %]
[% END %]

[% BLOCK 'alt-contact-style_altcontactsurname' %]
    [% UNLESS noaltcontactsurname %]
        <li>
            <label for="altcontactsurname" [% IF mandatoryaltcontactsurname %]class="required"[% END %]>Surname: </label>
            <input type="text" name="altcontactsurname" id="altcontactsurname" value="[% patron.altcontactsurname | html %]" />
            [% IF ( mandatoryaltcontactsurname ) %]<span class="required">Required</span>[% END %]
        </li>
    [% END %]
[% END %]

[% BLOCK 'alt-contact-style_altcontactfirstname' %]
    [% UNLESS noaltcontactfirstname %]
        <li>
            <label for="altcontactfirstname" [% IF mandatoryaltcontactfirstname %]class="required"[% END %]>First name: </label>
            <input type="text" name="altcontactfirstname" id="altcontactfirstname" value="[% patron.altcontactfirstname | html %]" />
            [% IF ( mandatoryaltcontactfirstname ) %]<span class="required">Required</span>[% END %]
        </li>
    [% END %]
[% END %]

[% BLOCK 'alt-contact-style_altcontactaddress1' %]
    [% UNLESS noaltcontactaddress1 %]
        <li>
            <label for="altcontactaddress1" [% IF mandatoryaltcontactaddress1 %]class="required"[% END %]>Address: </label>
            <input type="text" name="altcontactaddress1" id="altcontactaddress1" value="[% patron.altcontactaddress1 | html %]" size="40" />
            [% IF ( mandatoryaltcontactaddress1 ) %]<span class="required">Required</span>[% END %]
        </li>
    [% END %]
[% END %]

[% BLOCK 'alt-contact-style_altcontactaddress2' %]
    [% UNLESS noaltcontactaddress2 %]
        <li>
            <label for="altcontactaddress2" [% IF mandatoryaltcontactaddress2 %]class="required"[% END %]>Address 2: </label>
            <input type="text" name="altcontactaddress2" id="altcontactaddress2" value="[% patron.altcontactaddress2 | html %]" size="40" />
            [% IF ( mandatoryaltcontactaddress2 ) %]<span class="required">Required</span>[% END %]
        </li>
    [% END %]
[% END %]

[% BLOCK 'alt-contact-style_altcontactzipcode' %]
    [% UNLESS noaltcontactzipcode %]
        <li>
            <label for="altcontactzipcode" [% IF mandatoryaltcontactzipcode %]class="required"[% END %]>ZIP/Postal code: </label>
            <input type="text" name="altcontactzipcode" id="altcontactzipcode" value="[% patron.altcontactzipcode | html %]" size="5" />
            [% IF ( mandatoryaltcontactzipcode ) %]<span class="required">Required</span>[% END %]
        </li>
    [% END %]
[% END %]

[% BLOCK 'alt-contact-style_altcontactaddress3' %]
    [% UNLESS noaltcontactaddress3 %]
        <li>
            <label for="altcontactaddress3" [% IF mandatoryaltcontactaddress3 %]class="required"[% END %]>City: </label>
            [% IF cities.count %]
                <select class="select_city" data-addressfield="altcontact" name="select_city">
                    <option value="|||"></option>
                    [% FOREACH c IN cities %]
                        [% SET option_value = c.city_zipcode _ '|' _ c.city_name _ '|' _ c.city_state _ '|' _ c.city_country %]
                        [% SET option_selected = 0 %]
                        [% IF c.city_name == patron.altcontactaddress3 && c.city_state == patron.altcontactstate && c.city_zipcode == patron.altcontactzipcode %]
                            [% option_selected = 1 %]
                        [% END %]
                        <option value="[% option_value | html %]" [% IF option_selected %]selected="selected"[% END %]> [% c.city_name | html %] [% c.city_state | html %] [% c.city_zipcode | html %] </option>
                    [% END %]
                </select>
                <span class="hint">or enter</span>
            [% END %]
            <input type="text" name="altcontactaddress3" id="altcontactcity" value="[% patron.altcontactaddress3 | html %]" size="20" />
            [% IF ( mandatoryaltcontactaddress3 ) %]<span class="required">Required</span>[% END %]
        </li>
    [% END %]
[% END %]

[% BLOCK 'alt-contact-style_altcontactstate' %]
    [% UNLESS noaltcontactstate %]
        <li>
            <label for="altcontactstate" [% IF mandatoryaltcontactstate %]class="required"[% END %]>State: </label>
            <input type="text" name="altcontactstate" id="altcontactstate" value="[% patron.altcontactstate | html %]" size="20" />
            [% IF ( mandatoryaltcontactstate ) %]<span class="required">Required</span>[% END %]
        </li>
    [% END %]
[% END %]

[% BLOCK 'alt-contact-style_altcontactcountry' %]
    [% UNLESS noaltcontactcountry %]
        <li>
            <label for="altcontactcountry" [% IF mandatoryaltcontactcountry %]class="required"[% END %]>Country: </label>
            <input type="text" name="altcontactcountry" id="altcontactcountry" value="[% patron.altcontactcountry | html %]" size="20" />
            [% IF ( mandatoryaltcontactcountry ) %]<span class="required">Required</span>[% END %]
        </li>
    [% END %]
[% END %]

[% BLOCK 'alt-contact-style_altcontactphone' %]
    [% UNLESS noaltcontactphone %]
        <li>
            <label for="altcontactphone" [% IF mandatoryaltcontactphone %]class="required"[% END %]>Phone: </label>
            <input type="text" name="altcontactphone" id="altcontactphone" value="[% patron.altcontactphone | html %]" />
            [% IF ( mandatoryaltcontactphone ) %]<span class="required">Required</span>[% END %]
        </li>
    [% END %]
[% END %]
