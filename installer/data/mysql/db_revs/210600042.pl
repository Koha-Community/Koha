use Modern::Perl;

return {
    bug_number  => "26326",
    description => "Add primary key to import_record_matches",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        unless ( primary_key_exists( 'import_record_matches', 'import_record_id' )
            && primary_key_exists( 'import_record_matches', 'candidate_match_id' ) )
        {
            if ( primary_key_exists('import_record_matches') ) {
                $dbh->do(
                    q|
                    ALTER TABLE import_record_matches DROP PRIMARY KEY
                |
                );
            }
            $dbh->do(
                q|
                ALTER TABLE import_record_matches ADD PRIMARY KEY (import_record_id,candidate_match_id)
            |
            );
        }
    },
    }
