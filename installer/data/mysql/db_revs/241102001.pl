use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "38108",
    description => "Add AlwaysShowHoldingsTableFilters system preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (`variable`,`value`,`options`,`explanation`,`type`)
            VALUES ('AlwaysShowHoldingsTableFilters','0','','Option to always show filters when loading the holdings table','YesNo')
        }
        );

        # sysprefs
        say_success( $out, "Added new system preference 'AlwaysShowHoldingsTableFilters'" );
    },
};
