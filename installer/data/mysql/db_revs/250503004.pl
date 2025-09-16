use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "36561",
    description => "Add new permission for validation passwords on the API",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO permissions (module_bit, code, description)
            VALUES (4, 'api_validate_password', 'Validate patron passwords using the API')
        }
        );

        say_success( $out, "Added new permission 'borrowers:api_validate_password'" );
    },
};
