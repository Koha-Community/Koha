use Modern::Perl;

return {
    bug_number => "33961",
    description => "Remove Offline circulation tool",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        $dbh->do(q{
            DELETE FROM systempreferences
            WHERE variable="AllowOfflineCirculation"
        });
        say $out "Removed system preference 'AllowOfflineCirculation'";
    },
};
