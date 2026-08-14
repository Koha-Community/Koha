use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "42112",
    description => "Add UpdateExpiryDateOnCategoryChange and UpdateMessagingPrefsOnCategoryChange",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (`variable`,`value`)
            VALUES ('UpdateExpiryDateOnCategoryChange', 'softyes')
        }
        );
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (`variable`,`value`)
            VALUES ('UpdateMessagingPrefsOnCategoryChange', 'softyes')
        }
        );

        say_success( $out, "System preference UpdateExpiryDateOnCategoryChange added." );
        say_success( $out, "System preference UpdateMessagingPrefsOnCategoryChange added." );
    },
};
