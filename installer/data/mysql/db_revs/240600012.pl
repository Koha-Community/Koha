use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "26205",
    description => "Add new system preference OPACShowLibraries",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (variable, value, explanation, options, type)
            VALUES ('OPACShowLibraries', '1', 'If enabled, a "Libraries" link appears in the OPAC pointing to a page with library information', '', 'YesNo')
        }
        );
        say_success( $out, "Added new system preference 'OPACShowLibraries'" );
    },
};
