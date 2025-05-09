use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "39452",
    description => "Add CardnumberLog system preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('CardnumberLog','0',NULL,'If ON, log edit actions on patron cardnumbers','YesNo')
        }
        );

        say_success( $out, "Added new system preference 'CardnumberLog'" );
    },
};
