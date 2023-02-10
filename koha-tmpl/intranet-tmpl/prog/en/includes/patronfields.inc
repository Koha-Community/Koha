[%- BLOCK patron_fields -%]
     [%- SWITCH name -%]
     [%- CASE standard -%]<span>Standard</span>
     [%- CASE full_address -%]<span>Full address</span>
     [%- CASE all_emails -%]<span>All emails</span>
     [%- CASE all_phones -%]<span>All phones</span>
     [%- CASE 'borrowernumber' -%]<span>Borrowernumber</span>
     [%- CASE 'cardnumber' -%]<span>Card number</span>
     [%- CASE 'surname' -%]<span>Surname</span>
     [%- CASE 'firstname' -%]<span>First name</span>
     [%- CASE 'middle_name' -%]<span>Middle name</span>
     [%- CASE 'title' -%]<span>Salutation</span>
     [%- CASE 'othernames' -%]<span>Other name</span>
     [%- CASE 'initials' -%]<span>Initials</span>
     [%- CASE 'pronouns' -%]<span>Pronouns</span>
     [%- CASE 'streetnumber' -%]<span>Street number</span>
     [%- CASE 'streettype' -%]<span>Street type</span>
     [%- CASE 'address' -%]<span>Address</span>
     [%- CASE 'address2' -%]<span>Address 2</span>
     [%- CASE 'city' -%]<span>City</span>
     [%- CASE 'state' -%]<span>State</span>
     [%- CASE 'zipcode' -%]<span>ZIP/Postal code</span>
     [%- CASE 'country' -%]<span>Country</span>
     [%- CASE 'email' -%]<span>Primary email</span>
     [%- CASE 'phone' -%]<span>Primary phone</span>
     [%- CASE 'mobile' -%]<span>Mobile phone</span>
     [%- CASE 'fax' -%]<span>Fax</span>
     [%- CASE 'emailpro' -%]<span>Secondary email</span>
     [%- CASE 'phonepro' -%]<span>Secondary phone</span>
     [%- CASE 'B_streetnumber' -%]<span>Alternate street number</span>
     [%- CASE 'B_streettype' -%]<span>Alternate street type</span>
     [%- CASE 'B_address' -%]<span>Alternate address</span>
     [%- CASE 'B_address2' -%]<span>Alternate address line 2</span>
     [%- CASE 'B_city' -%]<span>Alternate city</span>
     [%- CASE 'B_state' -%]<span>Alternate state</span>
     [%- CASE 'B_zipcode' -%]<span>Alternate zip code</span>
     [%- CASE 'B_country' -%]<span>Alternate country</span>
     [%- CASE 'B_email' -%]<span>Alternate email</span>
     [%- CASE 'B_phone' -%]<span>Alternate phone</span>
     [%- CASE 'dateofbirth' -%]<span>Date of birth</span>
     [%- CASE 'branchcode' -%]<span>Library (code)</span>
     [%- CASE 'categorycode' -%]<span>Category (code)</span>
     [%- CASE 'dateenrolled' -%]<span>Registration date</span>
     [%- CASE 'dateexpiry' -%]<span>Expiry date</span>
     [%- CASE 'gonenoaddress' -%]<span>Gone no address</span>
     [%- CASE 'lost' -%]<span>Lost card</span>
     [%- CASE 'debarred' -%]<span>Restricted</span>
     [%- CASE 'debarredcomment' -%]<span>Restriction reason</span>
     [%- CASE 'contactname' -%]<span>Guarantor surname</span>
     [%- CASE 'contactfirstname' -%]<span>Guarantor firstname</span>
     [%- CASE 'contacttitle' -%]<span>Guarantor title</span>
     [%- CASE 'guarantorid' -%]<span>Guarantor ID</span>
     [%- CASE 'borrowernotes' -%]<span>Circulation note</span>
     [%- CASE 'relationship' -%]<span>Guarantor relationship</span>
     [%- CASE 'sex' -%]<span>Gender</span>
     [%- CASE 'flags' -%]<span>Permissions (code)</span>
     [%- CASE 'userid' -%]<span>Username</span>
     [%- CASE 'opacnote' -%]<span>OPAC note</span>
     [%- CASE 'contactnote' -%]<span>Contact note</span>
     [%- CASE 'sort1' -%]<span>Sort 1</span>
     [%- CASE 'sort2' -%]<span>Sort 2</span>
     [%- CASE 'altcontactfirstname' -%]<span>Alternate contact first name</span>
     [%- CASE 'altcontactsurname' -%]<span>Alternate contact surname</span>
     [%- CASE 'altcontactaddress1' -%]<span>Alternate contact address</span>
     [%- CASE 'altcontactaddress2' -%]<span>Alternate contact address 2</span>
     [%- CASE 'altcontactaddress3' -%]<span>Alternate contact city</span>
     [%- CASE 'altcontactstate' -%]<span>Alternate contact state</span>
     [%- CASE 'altcontactzipcode' -%]<span>Alternate contact ZIP/postal code</span>
     [%- CASE 'altcontactcountry' -%]<span>Alternate contact country</span>
     [%- CASE 'altcontactphone' -%]<span>Alternate contact phone</span>
     [%- CASE 'smsalertnumber' -%]<span>SMS alert number</span>
     [%- CASE 'sms_provider_id' -%]<span>SMS provider</span>
     [%- CASE 'privacy' -%]<span>Privacy (code)</span>
     [%- CASE 'privacy_guarantor_checkouts' -%]<span>Guarantor can view checkouts</span>
     [%- CASE 'updated_on' -%]<span>Last updated</span>
     [%- CASE 'lastseen' -%]<span>Last seen</span>
     [%- CASE 'checkprevcheckout' -%]<span>Check previous checkout</span>
     [%- CASE DEFAULT -%]
     [%- END -%]
[%- END -%]
[%- BLOCK patron_fields_dropdown -%]
    [% IF search_box %]
        <label for="searchfieldstype" class="control-label">Search field:</label>
        <select name="searchfieldstype" id="searchfieldstype" class="form-control">
    [% ELSE %]
        <label for="searchfieldstype_filter">Search field:</label>
        <select name="searchfieldstype" id="searchfieldstype_filter">
    [% END %]
        [% SET standard = Koha.Preference('DefaultPatronSearchFields') || 'firstname|middle_name|surname|othernames|cardnumber|userid' %]
        [% standard.replace('|', ',') %]
        [% SET full_address = 'streetnumber,streettype,address,address2,city,state,zipcode,country' %]
        [% SET all_emails = 'email,emailpro,B_email' %]
        [% SET all_phones = 'phone,phonepro,B_phone,altcontactphone,mobile' %]
        [% default_fields = [ standard, 'surname', 'cardnumber', all_emails, 'borrowernumber', 'userid', all_phones, full_address, 'dateofbirth', 'sort1', 'sort2' ] %]
        [% search_options = default_fields.merge(standard.split(',')).unique %]
        [% FOREACH s_o IN search_options %]
            [% display_name = PROCESS patron_fields name=s_o %]
            [% NEXT IF !display_name %]
            [% IF searchfieldstype == s_o %]
                <option selected="selected" value=[% s_o | html %]>[% display_name | $raw %]</option>
            [% ELSE %]
                <option value=[% s_o | html %]>[% display_name | $raw %]</option>
            [% END %]
        [% END %]
    </select>
[%- END -%]
