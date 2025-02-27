use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "23010",
    description => "Add new PreventWithDrawingItemsStatus system preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (`variable`,`value`,`options`,`explanation`,`type`)
            VALUES ('PreventWithDrawingItemsStatus',NULL,'','Prevent the withdrawing of items based on statuses','Choice')
        }
        );

        say $out "Added new system preference 'PreventWithDrawingItemsStatus'";
    },
};
