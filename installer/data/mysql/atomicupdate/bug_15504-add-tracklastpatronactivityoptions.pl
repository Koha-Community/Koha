use Modern::Perl;

return {
    bug_number  => "15504",
    description => "Adds a new system preference - TrackLastPatronActivityTriggers",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Get existing value from the TrackLastPatronActivity system preference
        my ($tracklastactivity) = $dbh->selectrow_array(
            q{
            SELECT value FROM systempreferences WHERE variable='TrackLastPatronActivity';
        }
        );

        my $triggers = $tracklastactivity ? 'check_out,connection,login' : '';
        $dbh->do(
            qq{INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('TrackLastPatronActivityTriggers',?,NULL,'If set, the field borrowers.lastseen will be updated every time a patron performs a selected action','multiple') },
            undef, $triggers,
        );

        say $out "Added system preference 'TrackLastPatronActivityTriggers'";

        $dbh->do(
            q{
            DELETE FROM systempreferences WHERE variable='TrackLastPatronActivity'
        }
        );

        say $out "Removed system preference 'TrackLastPatronActivity'";
    },
};
