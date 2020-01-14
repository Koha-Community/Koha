$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{
        INSERT IGNORE INTO `userflags` (`bit`, `flag`, `flagdesc`, `defaulton`)
        VALUES (12, 'suggestions', 'Suggestion management', 0)
    });

    $dbh->do(q{
        UPDATE permissions SET module_bit=12
        WHERE code="suggestions_manage"
    });

    $dbh->do(q{
        UPDATE borrowers SET flags = flags + (1<<12) WHERE flags & (1 << 11)
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 22868 - Move suggestions_manage subpermission out of acquisition permission)\n";
}
