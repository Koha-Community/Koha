use Modern::Perl;

return {
    bug_number  => "17617",
    description => "Notify patron when their hold has been placed",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type) VALUES ('EmailPatronWhenHoldIsPlaced', '0', NULL, 'Email patron when a hold has been placed for them', 'YesNo') }
        );

        say $out "Added system preference 'EmailPatronWhenHoldIsPlaced'";
    },
};
