        <fieldset class="rows" id="memberentry_altaddress">
            <legend id="alt_contact_lgd">Alternate contact</legend><ol>
        [% UNLESS noaltcontactsurname %]
            <li>
                [% IF ( mandatoryaltcontactsurname ) %]
                <label for="altcontactsurname" class="required">
                [% ELSE %]
                <label for="altcontactsurname">
                [% END %]
                Surname:</label>
                    <input type="text" name="altcontactsurname" id="altcontactsurname" value="[% patron.altcontactsurname | html %]" />
                [% IF ( mandatoryaltcontactsurname ) %]<span class="required">Required</span>[% END %]
            </li>
        [% END %]
        [% UNLESS noaltcontactfirstname %]
            <li>
                [% IF ( mandatoryaltcontactfirstname ) %]
                <label for="altcontactfirstname" class="required">
                [% ELSE %]
                <label for="altcontactfirstname">
                [% END %]
                First name:</label>
                    <input type="text" name="altcontactfirstname" id="altcontactfirstname" value="[% patron.altcontactfirstname | html %]" />
                [% IF ( mandatoryaltcontactfirstname ) %]<span class="required">Required</span>[% END %]
            </li>
        [% END %]
        [% UNLESS noaltcontactaddress1 %]
            <li>
                [% IF ( mandatoryaltcontactaddress1 ) %]
                <label for="altcontactaddress1" class="required">
                [% ELSE %]
                <label for="altcontactaddress1">
                [% END %]
                Address:</label>
                    <input type="text" name="altcontactaddress1" id="altcontactaddress1" value="[% patron.altcontactaddress1 | html %]" size="40" />
                [% IF ( mandatoryaltcontactaddress1 ) %]<span class="required">Required</span>[% END %]
            </li>
        [% END %]
        [% UNLESS noaltcontactaddress2 %]
            <li>
                [% IF ( mandatoryaltcontactaddress2 ) %]
                <label for="altcontactaddress2" class="required">
                [% ELSE %]
                <label for="altcontactaddress2">
                [% END %]
                Address 2:</label>
                <input type="text" name="altcontactaddress2" id="altcontactaddress2" value="[% patron.altcontactaddress2 | html %]" size="40" />
                [% IF ( mandatoryaltcontactaddress2 ) %]<span class="required">Required</span>[% END %]
            </li>
        [% END %]
        [% UNLESS noaltcontactzipcode %]
                        <li>
                            [% IF ( mandatoryaltcontactzipcode ) %]
                                <label for="altcontactzipcode" class="required">
                                [% ELSE %]
                                <label for="altcontactzipcode">
                                [% END %]
                                ZIP/Postal code:</label>
                    <input type="text" name="altcontactzipcode" id="altcontactzipcode" value="[% patron.altcontactzipcode | html %]" size="5" />
                                [% IF ( mandatoryaltcontactzipcode ) %]<span class="required">Required</span>[% END %]
                        </li>
        [% END %]
        [% UNLESS noaltcontactaddress3 %]
            <li>
                [% IF ( mandatoryaltcontactaddress3 ) %]
                <label for="altcontactaddress3" class="required">
                [% ELSE %]
                <label for="altcontactaddress3">
                [% END %]
                City:</label>
                <input type="text" name="altcontactaddress3" id="altcontactcity" value="[% patron.altcontactaddress3 | html %]" size="20" />
                [% IF cities.count %]or choose
                    <select class="select_city" data-addressfield="altcontact" name="select_city">
                        <option value="|||"></option>
                        [% FOREACH c IN cities %]
                            [% IF c.city_name == patron.altcontactaddress3 && c.city_state == patron.altcontactstate && c.city_zipcode == patron.altcontactzipcode %]
                            <option value="[% c.city_zipcode | html %]|[% c.city_name | html %]|[% c.city_state | html %]|[% c.city_country | html %]" selected="selected">
                            [% ELSE %]
                            <option value="[% c.city_zipcode | html %]|[% c.city_name | html %]|[% c.city_state | html %]|[% c.city_country | html %]">
                            [% END %]
                                [% c.city_name | html %] [% c.city_state | html %] [% c.city_zipcode | html %]
                            </option>
                        [% END %]
                    </select>
                [% END %]
                [% IF ( mandatoryaltcontactaddress3 ) %]<span class="required">Required</span>[% END %]
            </li>
        [% END %]
        [% UNLESS noaltcontactstate %]
            <li>
                [% IF ( mandatoryaltcontactstate ) %]
                <label for="altcontactstate" class="required">
                [% ELSE %]
                <label for="altcontactstate">
                [% END %]
                State:</label>
                <input type="text" name="altcontactstate" id="altcontactstate" value="[% patron.altcontactstate | html %]" size="20" />
                [% IF ( mandatoryaltcontactstate ) %]<span class="required">Required</span>[% END %]
            </li>
        [% END %]
        [% UNLESS noaltcontactcountry %]
            <li>
                [% IF ( mandatoryaltcontactcountry ) %]
                <label for="altcontactcountry" class="required">
                [% ELSE %]
                <label for="altcontactcountry">
                [% END %]
                Country:</label>
                    <input type="text" name="altcontactcountry" id="altcontactcountry" value="[% patron.altcontactcountry | html %]" size="20" />
                [% IF ( mandatoryaltcontactcountry ) %]<span class="required">Required</span>[% END %]
            </li>
        [% END %]
        [% UNLESS noaltcontactphone %]
            <li>
                [% IF ( mandatoryaltcontactphone ) %]
                <label for="altcontactphone" class="required">
                [% ELSE %]
                <label for="altcontactphone">
                [% END %]
                Phone:</label>
                    <input type="text" name="altcontactphone" id="altcontactphone" value="[% patron.altcontactphone | html %]" />
                [% IF ( mandatoryaltcontactphone ) %]<span class="required">Required</span>[% END %]
            </li>
        [% END %]
            </ol>
        </fieldset>
