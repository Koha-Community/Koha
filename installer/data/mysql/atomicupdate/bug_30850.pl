use Modern::Perl;
use Encode qw( encode_utf8 );

return {
    bug_number => 30850,
    description => 'Message about mappings changes for 110$a',
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        say $out encode_utf8 '110$a was added as a default mapping for biblio.author in MARC21.';
        say $out encode_utf8 'This will only change the mapping on new installations.';
        say $out encode_utf8 'If you wish to change the mappings on your existing installation,';
        say $out encode_utf8 'go to Administration > Koha to MARC mapping and add 110$a to biblio.author';
        say $out encode_utf8 'and then run batchRebuilBiblioTables.pl';
    },
}
