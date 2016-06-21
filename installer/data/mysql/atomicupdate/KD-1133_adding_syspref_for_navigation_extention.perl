$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
	$dbh->do("INSERT INTO systempreferences (variable, value, options, explanation, type) VALUES ('opacnavigation', '', '', 'Include the following HTML in the OPAC navigation', 'textarea')");

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-1133: Adding syspref for navigation extension)\n";
}
