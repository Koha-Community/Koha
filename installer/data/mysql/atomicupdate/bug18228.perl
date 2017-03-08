$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    # Add the new columns
    $dbh->do(
q|ALTER TABLE virtualshelves
ADD COLUMN allow_change_from_owner tinyint(1) default 1,
ADD COLUMN allow_change_from_others tinyint(1) default 0|
    );

    # Conversion:
    # Since we had no readonly lists, change_from_owner is set to true.
    # When adding or delete_other was granted, change_from_others is true.
    # Note: In my opinion the best choice; there is no exact match.
    $dbh->do(
q|UPDATE virtualshelves
SET allow_change_from_owner = 1,
allow_change_from_others = CASE WHEN allow_add=1 OR allow_delete_other=1 THEN 1 ELSE 0 END|
    );

    # Remove the old columns
    $dbh->do(
q|ALTER TABLE virtualshelves
DROP COLUMN allow_add,
DROP COLUMN allow_delete_own,
DROP COLUMN allow_delete_other|
    );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18228 - Alter table virtualshelves)\n";
}
