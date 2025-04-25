use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "32034",
    description => "Add library branch transfers to the action logs",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (variable, value, explanation, options, type)
            VALUES ('TransfersLog', '0', 'If enabled, log item transfer changes', '', 'YesNo')
        }
        );

        say_success( $out, "Added new system preference 'TransfersLog'" );
    },
};
