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
        $dbh->do(qq{
            UPDATE marc_subfield_structure SET kohafield='biblio.medium'
            WHERE (kohafield IS NULL OR kohafield='') AND frameworkcode='' AND tagfield='200' AND tagsubfield='b'
        });
        $dbh->do(qq{
            UPDATE marc_subfield_structure SET kohafield='biblio.subtitle'
            WHERE (kohafield IS NULL OR kohafield='') AND frameworkcode='' AND tagfield='200' AND tagsubfield='e'
        });
        $dbh->do(qq{
            UPDATE marc_subfield_structure SET kohafield='biblio.part_number'
            WHERE (kohafield IS NULL OR kohafield='') AND frameworkcode='' AND tagfield='200' AND tagsubfield='h'
        });
        $dbh->do(qq{
            UPDATE marc_subfield_structure SET kohafield='biblio.part_name'
            WHERE (kohafield IS NULL OR kohafield='') AND frameworkcode='' AND tagfield='200' AND tagsubfield='i'
        });
    } else {
        $dbh->do(qq{
            UPDATE marc_subfield_structure SET kohafield='biblio.medium'
            WHERE (kohafield IS NULL OR kohafield='') AND frameworkcode='' AND tagfield='245' AND tagsubfield='h'
        });
        $dbh->do(qq{
            UPDATE marc_subfield_structure SET kohafield='biblio.subtitle'
            WHERE (kohafield IS NULL OR kohafield='') AND frameworkcode='' AND tagfield='245' AND tagsubfield='b'
        });
        $dbh->do(qq{
            UPDATE marc_subfield_structure SET kohafield='biblio.part_number'
            WHERE (kohafield IS NULL OR kohafield='') AND frameworkcode='' AND tagfield='245' AND tagsubfield='n'
        });
        $dbh->do(qq{
            UPDATE marc_subfield_structure SET kohafield='biblio.part_name'
            WHERE (kohafield IS NULL OR kohafield='') AND frameworkcode='' AND tagfield='245' AND tagsubfield='p'
        });
    }

    $dbh->do("UPDATE marc_subfield_structure JOIN fieldmapping ON tagfield = fieldcode AND subfieldcode=tagsubfield SET kohafield='biblio.subtitle' WHERE fieldmapping.frameworkcode=''");
    $sth = $dbh->prepare("SELECT * FROM fieldmapping WHERE frameworkcode != '' OR field != 'subtitle'");
    $sth->execute;
    print "Keyword to MARC mappings below cannot be preserved: \n" if $sth->rows;
    while ( my $value = $sth->fetchrow_hashref() ){
        my $framework = $value->{frameworkcode} eq "" ? "Default" : $value->{frameworkcode};
        print "    keyword: " . $value->{'field'} . " to field: " . $value->{fieldcode} . "\$" . $value->{subfieldcode} . " for $framework framework\n";
    }
    print "You will need to remap using Koha to MARC mappings in administration\n" if $sth->rows;


#    $dbh->do( "DROP TABLE IF EXISTS fieldmapping" );

    $dbh->do( "DELETE FROM user_permissions WHERE code='manage_keywords2koha_mappings'" );

    $dbh->do( "DELETE FROM permissions WHERE code='manage_keywords2koha_mappings'" );

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 11529 - Add medium, subtitle and part information to biblio table)\n";
}
