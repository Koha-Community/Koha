use Modern::Perl;

return {
    bug_number  => "15504",
    description => "Adds a new system preference - TrackLastPatronActivityTriggers",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('TrackLastPatronActivityTriggers','',NULL,'If set, the field borrowers.lastseen will be updated every time a patron is does a selected option','multiple') }
        );

        say $out "Added system preference 'TrackLastPatronActivityTriggers'";
    },
};
