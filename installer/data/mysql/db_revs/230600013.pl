use Modern::Perl;

return {
    bug_number  => "28966",
    description => "Holds queue view too slow to load for large numbers of holds",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( primary_key_exists( 'tmp_holdsqueue', 'itemnumber' ) ) {
            $dbh->do(
                q{ALTER TABLE tmp_holdsqueue ADD PRIMARY KEY (itemnumber)}
            );
        }

        say $out "Set primary key for table 'tmp_holdsqueue' to 'itemnumber'";
    },
};
