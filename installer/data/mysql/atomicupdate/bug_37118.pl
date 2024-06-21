use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_failure say_success say_info);

return {
    bug_number  => "37118",
    description => "Adds new system preference 'OPACVirtualCard'",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('OPACVirtualCard', '0', NULL,'Enable virtual library cards for patrons on the OPAC.', 'YesNo')
        }
        );

        # sysprefs
        say $out "Added new system preference 'OPACVirtualCard'";

    },
};
