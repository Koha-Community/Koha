[% FOR m IN messages %]
    <div class="dialog [% m.type %]">
        [% SWITCH m.code %]
        [% CASE 'success_on_insert_library' %]<span>Library created!</span>
        [% CASE 'error_on_insert_library' %]<span>Library already exists and cannot be modified!</span>
        [% CASE 'success_on_insert_category' %]<span>Patron category created!</span>
        [% CASE 'error_on_insert_category' %]<span>Patron category already exists and cannot be modified!</span>
        [% CASE 'success_on_insert_patron' %]<span>Administrator Patron created!</span>
        [% CASE 'error_on_insert_patron' %]<span>The patron has not been created! Cardnumber or Userid may already exist.</span>
        [% CASE 'ERROR_cardnumber_already_exists' %]<span>Cardnumber already in use.</span>
        [% CASE 'ERROR_cardnumber_length' %]<span>Cardnumber length is incorrect.</span>
        [% CASE 'ERROR_password_mismatch' %]<span>Passwords do not match.</span>
        [% CASE 'success_on_insert_itemtype' %]<span>New item type created!</span>
        [% CASE 'error_on_insert_itemtype' %]<span>Item type already exists!</span>
        [% CASE 'success_on_insert_circ_rule' %]<span>Circulation rule created!</span>
        [% CASE 'error_on_insert_circ_rule' %]<span>Circulation rule not created!</span>
        [% CASE %][% message %]
        [% END %]
    </div>
[% END %]
