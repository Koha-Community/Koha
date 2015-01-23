[% FOR m IN messages %]
    [% SWITCH m.code %]
        [% CASE 'success_on_insert_library' %]
            <div class="alert alert-success">Library created!</div>
        [% CASE 'error_on_insert_library' %]
            <div class="alert alert-danger">Library already exists and cannot be modified!</div>
        [% CASE 'success_on_insert_category' %]
            <div class="alert alert-success">Patron category created!</div>
        [% CASE 'error_on_insert_category' %]
            <div class="alert alert-danger">Patron category already exists and cannot be modified!</div>
        [% CASE 'success_on_insert_patron' %]
            <div class="alert alert-success">Administrator account created!</div>
        [% CASE 'error_on_insert_patron' %]
            <div class="alert alert-danger">The patron has not been created! Cardnumber or Userid may already exist.</div>
        [% CASE 'ERROR_cardnumber_already_exists' %]
            <div class="alert alert-danger">Card number already in use.</div>
        [% CASE 'ERROR_cardnumber_length' %]
            <div class="alert alert-danger">Card number length is incorrect.</div>
        [% CASE 'ERROR_password_mismatch' %]
            <div class="alert alert-danger">Passwords do not match.</div>
        [% CASE 'success_on_insert_itemtype' %]
            <div class="alert alert-success">New item type created!</div>
        [% CASE 'error_on_insert_itemtype' %]
            <div class="alert alert-danger">Item type already exists!</div>
        [% CASE 'success_on_insert_circ_rule' %]
            <div class="alert alert-success">Circulation rule created!</div>
        [% CASE 'error_on_insert_circ_rule' %]
            <div class="alert alert-danger">Circulation rule not created!</div>
        [% CASE 'ERROR_password_too_short' %]
            <div class="alert alert-danger">The patron has not been created the entered password was too short</div>
        [% CASE 'ERROR_password_too_weak' %]
            <div class="alert alert-danger">The patron has not been created the entered password was too weak, must contain at least one uppercase, and lower case letter and one number</div>
        [% CASE 'ERROR_password_has_whitespaces' %]
            <div class="alert alert-danger">The patron has not been created the entered password contained whitespaces</div>
        [% CASE %][% message | html %]
    [% END %]
[% END %]
