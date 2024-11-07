use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "37216",
    description => "Ensure EmailFieldSelection options are correct",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Fix options field on EmailFieldSelection
        $dbh->do(
            q{ UPDATE systempreferences SET options = 'email|emailpro|B_email' WHERE variable = 'EmailFieldSelection' }
        );

        # Clear invalid value from EmailFieldSelection
        $dbh->do(
            q{ UPDATE systempreferences SET value = '' WHERE variable = 'EmailFieldSelection' AND value='email|emailpro|B_email' }
        );

        say_success( $out, "Updated system preference 'EmailFieldSelection'" );
    },
};
