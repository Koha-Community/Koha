use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_failure say_success say_info);

return {
    bug_number  => "20638",
    description => "Add ApiKeyLog system preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type) VALUES
            ('ApiKeyLog', '0', NULL, 'If ON, log API key creation, deletion, revocation and activation actions', 'YesNo')
        }
        );

        say_success( $out, "Added new system preference 'ApiKeyLog'" );
    },
};
