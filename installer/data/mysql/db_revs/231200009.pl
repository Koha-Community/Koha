use Modern::Perl;

return {
    bug_number  => "34668",
    description => "Notify staff with a pop-up about waiting holds when checking out",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{INSERT IGNORE INTO `systempreferences` (variable,value,options,explanation,type) VALUES ('WaitingNotifyAtCheckout','0',NULL,'If ON, notify librarians of waiting holds for the patron whose items they are checking out.','YesNo') }
        );

        say $out "Added new system preference 'WaitingNotifyAtCheckout'";
    },
};
