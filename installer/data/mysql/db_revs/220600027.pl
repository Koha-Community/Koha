use Modern::Perl;

return {
    bug_number  => "28269",
    description => "Make it possible to search orders with ISSN",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type)
            VALUES ('SearchWithISSNVariations','0',NULL,'If enabled, search on all variations of the ISSN','YesNo')
        }
        );

        say $out "Added new system preference 'SearchWithISSNVariations'";
    },
};
