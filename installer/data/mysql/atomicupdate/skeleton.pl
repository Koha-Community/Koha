use Modern::Perl;

return {
    bug_number => "BUG_NUMBER",
    description => "A single line description",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        # Do you stuffs here
        $dbh->do(q{});
        # Print useful stuff here
        say $out "Update is going well so far";
    },
};
