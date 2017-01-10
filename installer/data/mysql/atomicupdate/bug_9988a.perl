$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    my $oldval = C4::Context->preference('dontmerge');
    my $newval = $oldval ? 0 : 50;

    # Remove dontmerge, add AuthorityMergeLimit
    $dbh->do(q/
DELETE FROM systempreferences WHERE variable = 'dontmerge';
    /);
    $dbh->do(qq/
INSERT IGNORE INTO systempreferences ( variable, value, options, explanation, type ) VALUES ('AuthorityMergeLimit','$newval',NULL,'Maximum number of biblio records updated immediately when an authority record has been modified.','integer');
    /);

    SetVersion( $DBversion );
    if( $newval == 0 ) {
        print "NOTE: Since dontmerge was enabled, we have initialized AuthorityMergeLimit to 0 records. Please consider raising this value. This will allow for performing smaller merges directly and only postponing larger merges.\n";
    }
    print "Upgrade to $DBversion done (Bug 9988 - Add AuthorityMergeLimit)\n";
}
