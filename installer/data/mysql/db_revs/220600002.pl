use Modern::Perl;

return {
    bug_number  => 30850,
    description => 'Message about mappings changes for 110$a',
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        say $out
            q|110$a was added as a default mapping for biblio.author in MARC21. This will only change the mapping on new installations. If you wish to change the mappings on your existing installation, go to Administration > Koha to MARC mapping and add 110$a to biblio.author and then run batchRebuilBiblioTables.pl.|;
    },
    }
