use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_failure say_success say_info);

return {
    bug_number  => "37216",
    description => "Ensure EmailFieldSelection options are correct",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{ UPDATE systempreferences SET options = 'email|emailpro|B_email' WHERE variable = 'EmailFieldSelection' }
        );

        say_success( $out, "Updated system preference 'EmailFieldSelection'" );
    },
};
