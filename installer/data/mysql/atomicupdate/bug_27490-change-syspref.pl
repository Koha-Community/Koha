use Modern::Perl;

return {
    bug_number  => "27490",
    description => "Changing language syspref to StaffInterfaceLanguages",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(q{UPDATE systempreferences SET variable='StaffInterfaceLanguages' WHERE variable='language'});

        say $out "Updated system preference 'Change language to StaffInterfaceLanguages'";
    },
};
