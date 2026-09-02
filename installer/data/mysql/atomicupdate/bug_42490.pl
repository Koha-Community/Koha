use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "42490",
    description => "Add system preference LocalHoldsPriorityScope",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
                    INSERT IGNORE INTO systempreferences (variable, value, options, explanation, type)
                    VALUES (
                        'LocalHoldsPriorityScope',
                        'checkin_and_queue',
                        NULL,
                        'Define whether these settings are used when building the holds queue or only when checking items in',
                        'Choice'
                        )
        }
        );

        say $out "Added new system preference 'LocalHoldsPriorityScope'";
    },
};
