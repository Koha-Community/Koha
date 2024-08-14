use Modern::Perl;

return {
    bug_number  => "20411",
    description => "Remove StaffDetailItemSelection system preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{
            DELETE FROM systempreferences WHERE variable='StaffDetailItemSelection'
        }
        ) == 1 && say $out "Removed system preference 'StaffDetailItemSelection'";

    },
};
