use Modern::Perl;

{
    bug_number => "BUG_NUMBER",
    description => "A single line description",
    # description => ["Multi", "lines", "description"],
    # description => sub { return ["Your dynamic description"] },
    up => sub {
        my $dbh = C4::Context->dbh;
        # Do you stuffs here
        $dbh->do(q{});
    },
}
