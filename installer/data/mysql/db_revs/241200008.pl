use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => '35028',
    description => "Add system preference 'PatronSelfRegistrationAlert'",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do( "
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('PatronSelfRegistrationAlert','0',NULL,'If enabled, an alter will be shown on staff interface home page when there are self-registered patrons.','YesNo')
        " );
        say_success( $out, "Added new system preference 'PatronSelfRegistrationAlert'" );
    },
};
