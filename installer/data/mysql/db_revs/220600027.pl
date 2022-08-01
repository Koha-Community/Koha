use Modern::Perl;

return {
    bug_number => "28269",
    description => "Add new system preference SearchWithISSNVariations",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};

        $dbh->do( q{
            INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type)
            VALUES ('SearchWithISSNVariations','0',NULL,'If enabled, search on all variations of the ISSN','YesNo')

        });
    },
};
