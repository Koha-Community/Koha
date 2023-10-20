use Modern::Perl;

return {
    bug_number  => "31357",
    description => "Add new system preference IntranetReadingHistoryHolds",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) SELECT
            'IntranetReadingHistoryHolds', value, '', 'If ON, Holds history is enabled for all patrons', 'YesNo'
            FROM systempreferences WHERE variable = 'intranetreadinghistory';
        }
        );
    },
    }
