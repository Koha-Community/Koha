use Modern::Perl;

return {
    bug_number  => "25429",
    description => "Add new system preference CleanUpDatabaseReturnClaims",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('CleanUpDatabaseReturnClaims', '', '', 'Sets the age of resolved return claims to delete from the database for cleanup_database.pl', 'Integer' );
        }
        );
    },
    }
