use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "14180",
    description => "Add system preference AlwaysLoadCheckoutsTable",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (`variable`,`value`,`options`,`explanation`,`type`)
            VALUES ('AlwaysLoadCheckoutsTable','0','','Option to always load the checkout table','YesNo')
        }
        );
        say_success( $out, "Added new system preference 'AlwaysLoadCheckoutsTable'" );

    },
};
