use Modern::Perl;

return {
    bug_number  => "36687",
    description => "Set itemtypes.notforloan to NOT NULL and tinyint(1)",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        my $count_sql = q{SELECT COUNT(*) FROM itemtypes WHERE notforloan IS NULL};
        my ($count) = $dbh->selectrow_array($count_sql);

        if ($count) {
            $dbh->do(q{UPDATE itemtypes SET notforloan = 0 WHERE notforloan IS NULL});
            say $out "Updated $count columns where itemtypes.notforloan was NULL";
        }
        $dbh->do(
            q{
             ALTER TABLE itemtypes MODIFY COLUMN `notforloan` tinyint(1) NOT NULL DEFAULT 0
        }
        );

        say $out "Updated itemtypes.notforlaon column'";
    },
};
