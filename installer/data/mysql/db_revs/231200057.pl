use Modern::Perl;

return {
    bug_number  => "29948",
    description => "Display author information for researchers",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        my ($OPACAuthorIdentifiers) =
            $dbh->selectrow_array(q{SELECT value FROM systempreferences WHERE variable="OPACAuthorIdentifiers"});
        my $value = $OPACAuthorIdentifiers ? 'identifiers' : '';

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('OPACAuthorIdentifiersAndInformation', ?, '', 'Display author information on the OPAC detail page','multiple_sortable')
        }, undef, $value
        );
        say $out "Added new system preference 'OPACAuthorIdentifiersAndInformation'";

        $dbh->do(q{DELETE FROM systempreferences WHERE variable="OPACAuthorIdentifiers"});
        say $out "  Removed system preference 'OPACAuthorIdentifiers'";
    },
};
