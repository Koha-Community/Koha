$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('UpdateItemLocationOnCheckin', 'PROC: _PERM_\n', 'NULL', 'This a list of value pairs. When an item is checked in, if the location value on the left matches the items location value t will be updated to the right-hand value. E.g. ''PROC: FIC'' will cause an item that was set to ''Processing Center'' to now be in the ''Fiction'' shelving location. Note that PROC and CART are special values, for these locations only can location and permanent_location differ, in all other cases an update will affect both.  Items in the CART location will be returned to their permanent location on checkout.  You can also use the special term _BLANK_ on either side of a pair to update/remove items with no locaiton assigned.  You can use the special term _ALL_ on the left side to affect all items and the special term _PERM_ on the right side to return items to their permanent location', 'Free');
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
