$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('UpdateItemLocationOnCheckin', 'PROC: _PERM_\n', 'NULL', 'This a list of value pairs.\n Examples:\n PROC: FIC - causes an item in the Processing Center location to be updated into the Fiction location on check in.\n FIC: GEN - causes an item in the Fiction location to be updated into the General stacks location on check in.\n _BLANK_:FIC - causes an item that has no location to be updated into the Fiction location on check in.\nFIC: _BLANK_ - causes an item in location FIC to be updated to a blank location on check in.\n_ALL_:FIC - causes all items to be updated into the Fiction location on check in.\nPROC: _PERM_ - causes an item that is in the Processing Center to be updated to it''s permanent location.\nGeneral rule: if the location value on the left matches the item''s current location, it will be updated to match the location value on the right.\nNote: PROC and CART are special values, for these locations only can location and permanent_location differ, in all other cases an update will affect both. Items in the CART location will be returned to their permanent location on checkout.\nThe special term _BLANK_ may be used on either side of a value pair to update or remove the location from items with no locaiton assigned. The special term _ALL_ is used on the left side of the colon (:) to affect all items.\nThe special term _PERM_ is used on the right side of the colon (:) to return items to their permanent location.', 'Free');
    });
    $dbh->do(q{
        UPDATE systempreferences s1, (SELECT IF(value,'PROC: CART\n','') AS p2c FROM systempreferences WHERE variable='InProcessingToShelvingCart') s2 SET s1.value= CONCAT(s2.p2c, REPLACE(s1.value,'PROC: _PERM_\n','') ) WHERE s1.variable='UpdateItemLocationOnCheckin' AND s1.value NOT LIKE '%PROC: CART%';
    });
    $dbh->do(q{
        DELETE FROM systempreferences WHERE variable='InProcessingToShelvingCart';
    });
    $dbh->do(q{
        UPDATE systempreferences s1, (SELECT IF(value,'_ALL_: CART\n','') AS rtc FROM systempreferences WHERE variable='ReturnToShelvingCart') s2 SET s1.value= CONCAT(s2.rtc,s1.value) WHERE s1.variable='UpdateItemLocationOnCheckin' AND s1.value NOT LIKE '%_ALL_: CART%';
    });
    $dbh->do(q{
        DELETE FROM systempreferences WHERE variable='ReturnToShelvingCart';
    });
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 14576: Add UpdateItemLocationOnCheckin syspref)\n";
}
