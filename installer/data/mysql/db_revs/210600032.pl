use Modern::Perl;

return {
    bug_number  => "29138",
    description => "Use a zero instead of a 'no' in LoadSearchHistoryToTheFirstLoggedUser",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
            UPDATE systempreferences SET value='0'
            WHERE variable='LoadSearchHistoryToTheFirstLoggedUser' AND value='no';
        }
        );
    },
    }
