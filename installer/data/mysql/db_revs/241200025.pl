use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "39374",
    description => "Add system preference OPACDisableSendList",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` )
            VALUES ('OPACDisableSendList','0',NULL,'Allow OPAC users to email lists via a "Send list" button','YesNo');
        }
        );

        say_success( $out, "Added new system preference 'OPACDisableSendList'" );
    },
};
