use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "23010",
    description => "Add new PreventWithdrawingItemsStatus system preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (`variable`,`value`,`options`,`explanation`,`type`)
            VALUES ('PreventWithdrawingItemsStatus','','','Prevent the withdrawing of items based on statuses','multiple')
        }
        );

        say_success( $out, "Added new system preference 'PreventWithdrawingItemsStatus'" );
    },
};
