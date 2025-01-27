use Modern::Perl;

return {
    bug_number  => "7021",
    description => "Add patron category to the statistics table",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( !column_exists( 'statistics', 'categorycode' ) ) {
            $dbh->do(
                q{
                ALTER TABLE statistics
                    ADD COLUMN categorycode varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'foreign key from the borrowers table, links transaction to a specific borrower category'
            }
            );
            say $out "Added column 'statistics.categorycode'";
        }
    },
};
