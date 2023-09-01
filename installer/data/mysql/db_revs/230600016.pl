use Modern::Perl;

return {
    bug_number  => "34584",
    description => "Update SocialNetworks system preference to Choice",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{UPDATE systempreferences SET type = "Choice", options = "facebook|linkedin|email" WHERE variable = "SocialNetworks"}
        );

        say $out "Updated system preference 'SocialNetworks'";
    },
};
