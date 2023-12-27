use Modern::Perl;

return {
    bug_number  => "31297",
    description => "Allow subscription number pattern description to be NULL",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do("ALTER TABLE subscription_numberpatterns MODIFY description mediumtext DEFAULT NULL");

        say $out "Modified column 'subscription_numberpatterns.description' to allow and default to NULL";
    },
};
