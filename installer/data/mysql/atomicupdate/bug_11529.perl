$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    if( !column_exists( 'biblio', 'subtitle' ) ) {
        $dbh->do( "ALTER TABLE biblio ADD COLUMN medium LONGTEXT AFTER title" );
        $dbh->do( "ALTER TABLE biblio ADD COLUMN subtitle LONGTEXT AFTER medium" );
        $dbh->do( "ALTER TABLE biblio ADD COLUMN part_number LONGTEXT AFTER subtitle" );
        $dbh->do( "ALTER TABLE biblio ADD COLUMN part_name LONGTEXT AFTER part_number" );

        $dbh->do( "ALTER TABLE deletedbiblio ADD COLUMN medium LONGTEXT AFTER title" );
        $dbh->do( "ALTER TABLE deletedbiblio ADD COLUMN subtitle LONGTEXT AFTER medium" );
        $dbh->do( "ALTER TABLE deletedbiblio ADD COLUMN part_number LONGTEXT AFTER subtitle" );
        $dbh->do( "ALTER TABLE deletedbiblio ADD COLUMN part_name LONGTEXT AFTER part_number" );
    }

    $dbh->do( "UPDATE marc_subfield_structure SET kohafield='biblio.subtitle' WHERE kohafield='bibliosubtitle.subtitle'" );

    my $marcflavour = C4::Context->preference('marcflavour');

    if ( $marcflavour eq 'UNIMARC' ) {
        $dbh->do( "UPDATE marc_subfield_structure SET kohafield='biblio.medium' WHERE frameworkcode='' AND tagfield='200' AND tagsubfield='b'" );
        $dbh->do( "UPDATE marc_subfield_structure SET kohafield='biblio.subtitle' WHERE frameworkcode='' AND tagfield='200' AND tagsubfield='e'" );
        $dbh->do( "UPDATE marc_subfield_structure SET kohafield='biblio.part_number' WHERE frameworkcode='' AND tagfield='200' AND tagsubfield='h'" );
        $dbh->do( "UPDATE marc_subfield_structure SET kohafield='biblio.part_name' WHERE frameworkcode='' AND tagfield='200' AND tagsubfield='i'" );
    } else {
        $dbh->do( "UPDATE marc_subfield_structure SET kohafield='biblio.medium' WHERE frameworkcode='' AND tagfield='245' AND tagsubfield='h'" );
        $dbh->do( "UPDATE marc_subfield_structure SET kohafield='biblio.subtitle' WHERE frameworkcode='' AND tagfield='245' AND tagsubfield='b'" );
        $dbh->do( "UPDATE marc_subfield_structure SET kohafield='biblio.part_number' WHERE frameworkcode='' AND tagfield='245' AND tagsubfield='n'" );
        $dbh->do( "UPDATE marc_subfield_structure SET kohafield='biblio.part_name' WHERE frameworkcode='' AND tagfield='245' AND tagsubfield='p'" );
    }

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 11529 - Add medium, subtitle and part information to biblio table)\n";
}
