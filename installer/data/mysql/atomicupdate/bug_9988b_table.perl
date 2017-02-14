$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(
q|ALTER TABLE need_merge_authorities
ADD COLUMN authid_new BIGINT AFTER authid,
ADD COLUMN reportxml text AFTER authid_new,
ADD COLUMN timestamp timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;|
    );

    $dbh->do( q|UPDATE need_merge_authorities SET authid_new=authid WHERE done<>1| );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 9988 - Alter table need_merge_authorities)\n";
}
