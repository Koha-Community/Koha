$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "UPDATE marc_subfield_structure SET kohafield = NULL WHERE kohafield = 'bibliosubject.subject';" );
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 17831 - Remove non-existing bibliosubject.subject from frameworks)\n";
}
