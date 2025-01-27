use Modern::Perl;

return {
    bug_number  => "11175",
    description => "Show component records in detail views",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` )
            VALUES ('ShowComponentRecords', 'nowhere', 'nowhere|staff|opac|both','In which record detail pages to show list of the component records, as linked via 773','Choice')
        }
        );

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` )
            VALUES ('MaxComponentRecords', '300', '','Max number of component records to display','Integer')
        }
        );
    },
    }
