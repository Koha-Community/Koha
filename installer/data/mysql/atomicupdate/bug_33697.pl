use Modern::Perl;

return {
    bug_number => "33697",
    description => "Remove RecordedBooks (rbdigital) integration",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        for my $pref_name ( qw( RecordedBooksClientSecret RecordedBooksDomain RecordedBooksLibraryID ) ) {
            $dbh->do(q{
                DELETE FROM systempreferences
                WHERE variable=?
            }, undef, $pref_name) == 1 && say $out "Removed system preference '$pref_name'";
        }
    },
};
