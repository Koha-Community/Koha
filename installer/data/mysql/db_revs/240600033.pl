use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "35655",
    description => "Add a way to disable RabbitMQ",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences
                (`variable`, `value`, `options`, `explanation`, `type` )
            VALUES
                ('JobsNotificationMethod', 'STOMP', 'polling|STOMP', 'Define the preferred job worker notification method', 'Choice')
        }
        );

        say_success( $out, "Added new system preference 'JobsNotificationMethod'" );
    },
};
