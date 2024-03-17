use Modern::Perl;

return {
    bug_number  => "35973",
    description => "Correct system preference 'RedirectGuaranteeEmail'",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(q{UPDATE systempreferences SET value = 1 WHERE variable = "RedirectGuaranteeEmail" and value = "yes"});
        $dbh->do(q{UPDATE systempreferences SET value = 0 WHERE variable = "RedirectGuaranteeEmail" and value = "no"});

        say $out "Corrected system preference 'RedirectGuaranteeEmail'";
    },
};
