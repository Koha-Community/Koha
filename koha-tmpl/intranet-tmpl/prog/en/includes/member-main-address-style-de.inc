<fieldset class="rows" id="memberentry_mainaddress">
    <legend id="main_address_lgd">Main address</legend><ol>
[% UNLESS nostreettype %]
    [% IF roadtypes %]
      <li>
      [% IF ( mandatorystreettype ) %]
      <label for="streettype" class="required">
      [% ELSE %]
      <label for="streettype">
      [% END %]
      Street type: </label>
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
        [% UNLESS noaddress %]
    <li>
      [% IF ( mandatoryaddress ) %]
      <label for="address" class="required">
      [% ELSE %]
      <label for="address">
      [% END %]
      Address: </label>
            <input type="text" id="address" name="address" size="35" value="[% patron.address | html %]" />
      [% IF ( mandatoryaddress ) %]<span class="required">Required</span>[% END %]
    </li>
        [% END %]
        [% UNLESS nostreetnumber %]
    <li>
      [% IF ( mandatorystreetnumber ) %]
      <label for="streetnumber" class="required">
      [% ELSE %]
      <label for="streetnumber">
      [% END %]
      Street number: </label>
        <input type="text" id="streetnumber" name="streetnumber" size="5" value="[% patron.streetnumber | html %]" />
[% IF ( mandatorystreetnumber ) %]<span class="required">Required</span>[% END %]
    </li>
        [% END %]
        [% UNLESS noaddress2 %]
    <li>
      [% IF ( mandatoryaddress2 ) %]
      <label for="address2" class="required">
      [% ELSE %]
      <label for="address2">
      [% END %]
      Address 2: </label>
            <input type="text" id="address2" name="address2" size="35" value="[% patron.address2 | html %]" />
      [% IF ( mandatoryaddress2 ) %]<span class="required">Required</span>[% END %]
    </li>
        [% END %]
        [% UNLESS nozipcode %]
    <li>
      [% IF ( mandatoryzipcode ) %]
        <label for="zipcode" class="required">
      [% ELSE %]
        <label for="zipcode">
      [% END %]
      ZIP/Postal code: </label>
            <input type="text" name="zipcode" id="zipcode" size="10" value="[% patron.zipcode | html %]" />
          [% IF ( mandatoryzipcode ) %]<span class="required">Required</span>[% END %]
    </li>
        [% END %]
        [% UNLESS nocity %]
    <li>
      [% IF ( mandatorycity ) %]
        <label for="city" class="required">
      [% ELSE %]
        <label for="city">
      [% END %]
      City: </label>
        <input type="text" id="city" name="city" size="20" value="[% patron.city | html %]" />
        [% IF cities.count %]or choose
        <select id="select_city" name="select_city">
            <option value="|||"></option>
            [% FOREACH c IN cities %]
                [% IF c.city_name == patron.city && c.city_state == patron.state && c.city_zipcode == patron.zipcode %]
                <option value="[% c.city_zipcode | html %]|[% c.city_name | html %]|[% c.city_state | html %]|[% c.city_country | html %]" selected="selected">
                [% ELSE %]
                <option value="[% c.city_zipcode | html %]|[% c.city_name | html %]|[% c.city_state | html %]|[% c.city_country | html %]">
                [% END %]
                    [% c.city_name | html %] [% c.city_state | html %] [% c.city_zipcode | html %]
                </option>
            [% END %]
        </select>
        [% END %]
      [% IF ( mandatorycity ) %]<span class="required">Required</span>[% END %]
    </li>
        [% END %]
        [% UNLESS nostate %]
    <li>
      [% IF ( mandatorystate ) %]
        <label for="state" class="required">
      [% ELSE %]
        <label for="state">
      [% END %]
      State: </label>
      <input type="text" name="state" id="state" size="20" value="[% patron.state | html %]" />
      [% IF ( mandatorystate ) %]<span class="required">Required</span>[% END %]
    </li>
        [% END %]
        [% UNLESS nocountry %]
    <li>
      [% IF ( mandatorycountry ) %]
        <label for="country" class="required">
      [% ELSE %]
        <label for="country">
      [% END %]
      Country: </label>
        <input type="text" name="country" id="country" size="20" value="[% patron.country | html %]" />
      [% IF ( mandatorycountry ) %]<span class="required">Required</span>[% END %]
    </li>
        [% END %]
    </ol>
</fieldset>
