$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    $dbh->do( "UPDATE systempreferences SET explanation = 'This syspref allows to define custom rules for hiding specific items at the OPAC. See http://wiki.koha-community.org/wiki/OpacHiddenItems for more information.' WHERE variable = 'OpacHiddenItems'");
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 8701 - Update OpacHiddenItems system preference description)\n";
}
