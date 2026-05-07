use Modern::Perl;

return {
    bug_number  => "36466",
    description => "Fix the incorrect 0000-00-00 date in planneddate and publisheddate field",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # sanitize both columns as they could be filled with invalid dates
        sanitize_zero_date( 'serial', 'planneddate' );
        sanitize_zero_date( 'serial', 'publisheddate' );

        say $out "Incorrect date planneddate and publisheddate fixed";
    },
};
