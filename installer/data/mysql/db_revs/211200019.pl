use Modern::Perl;

return {
    bug_number  => "27812",
    description => "Remove the ability to transmit a patron's plain text password over email",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        say $out
            "The notice template ACCTDETAILS no longer has access to the patron's plain text password. Please update the language of your ACCTDETAILS as needed.";
    },
};
