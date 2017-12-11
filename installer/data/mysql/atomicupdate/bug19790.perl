$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "UPDATE marc_subfield_structure SET kohafield=NULL where kohafield='additionalauthors.author'" );
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 19790 - Remove additionalauthors.author from installer files)\n";
}
