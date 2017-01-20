$DBversion = "16.12.00.XXX";
if ( CheckVersion($DBversion) ) {
    unless ( column_exists( 'borrower_attribute_types', 'opac_editable' ) )
    {
        $dbh->do(q{
            ALTER TABLE borrower_attribute_types
                ADD COLUMN `opac_editable` tinyint(1) NOT NULL default 0 AFTER `opac_display`
        });
    }

    print "Upgrade to $DBversion done (Bug 13757: Make patron attributes editable in the opac if set to 'editable in OPAC'\n";
    SetVersion($DBversion);
}
