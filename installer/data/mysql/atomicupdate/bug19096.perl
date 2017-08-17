$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    my $dbh = C4::Context->dbh;

    my $msss = $dbh->selectall_arrayref(q|
        SELECT kohafield, tagfield, tagsubfield, frameworkcode
        FROM marc_subfield_structure
        WHERE   frameworkcode != ''
    |, { Slice => {} });


    my $sth = $dbh->prepare(q|
        SELECT kohafield
        FROM marc_subfield_structure
        WHERE frameworkcode = ''
        AND tagfield = ?
        AND tagsubfield = ?
    |);

    my @exceptions;
    for my $mss ( @$msss ) {
        $sth->execute($mss->{tagfield}, $mss->{tagsubfield} );
        my ( $default_kohafield ) = $sth->fetchrow_array();
        if( $mss->{kohafield} ) {
            push @exceptions, { frameworkcode => $mss->{frameworkcode}, tagfield => $mss->{tagfield}, tagsubfield => $mss->{tagsubfield}, kohafield => $mss->{kohafield} } if not $default_kohafield or $default_kohafield ne $mss->{kohafield};
        } else {
            push @exceptions, { frameworkcode => $mss->{frameworkcode}, tagfield => $mss->{tagfield}, tagsubfield => $mss->{tagsubfield}, kohafield => q{} } if $default_kohafield;
        }
    }

    if (@exceptions) {
        print
"WARNING: The Default framework is now considered as authoritative for Koha to MARC mappings. We have found that your additional frameworks contained "
          . scalar(@exceptions)
          . " mapping(s) that deviate from the standard mappings. Please look at the following list and consider if you need to add them again in Default (possibly as a second mapping).\n";
        for my $exception (@exceptions) {
            print "Field "
              . $exception->{tagfield} . '$'
              . $exception->{tagsubfield}
              . " in framework "
              . $exception->{frameworkcode} . ': ';
            if ( $exception->{kohafield} ) {
                print "Mapping to "
                  . $exception->{kohafield}
                  . " has been adjusted.\n";
            }
            else {
                print "Mapping has been reset.\n";
            }
        }

        # Sync kohafield

        # Clear the destination frameworks first
        $dbh->do(q|
            UPDATE marc_subfield_structure
            SET kohafield = NULL
            WHERE   frameworkcode > ''
                AND     Kohafield > ''
        |);

        # Now copy from Default
        my $msss = $dbh->selectall_arrayref(q|
            SELECT kohafield, tagfield, tagsubfield
            FROM marc_subfield_structure
            WHERE   frameworkcode = ''
                AND     kohafield > ''
        |, { Slice => {} });
        my $sth = $dbh->prepare(q|
            UPDATE marc_subfield_structure
            SET kohafield = ?
            WHERE frameworkcode > ''
            AND tagfield = ?
            AND tagsubfield = ?
        |);
        for my $mss (@$msss) {
            $sth->execute( $mss->{kohafield}, $mss->{tagfield},
                $mss->{tagsubfield} );
        }

        # Clear the cache
        my @frameworkcodes = $dbh->selectall_arrayref(q|
            SELECT frameworkcode FROM biblio_framework WHERE frameworkcode > ''
        |);
        for my $frameworkcode (@frameworkcodes) {
            Koha::Caches->get_instance->clear_from_cache("MarcSubfieldStructure-$frameworkcode");
        }
        Koha::Caches->get_instance->clear_from_cache("default_value_for_mod_marc-");
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 19096 - Make Default authoritative for Koha to MARC mappings)\n";
}
