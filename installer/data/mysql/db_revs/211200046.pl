use Modern::Perl;

return {
    bug_number  => "22785",
    description => "Add chosen column to import_record_matches",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        unless ( column_exists( 'import_record_matches', 'chosen' ) ) {
            $dbh->do(
                q{
                ALTER TABLE import_record_matches ADD COLUMN chosen TINYINT null DEFAULT null AFTER score
            }
            );
            say $out "chosen column added to import_record_matches";
        } else {
            say $out "chosen column exists. Update has already been run";
        }
    },
};
