use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "35305",
    description => "Add XSLT for authority details display in staff interface",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (`variable`, `value`, `options`, `explanation`, `type`)
            VALUES ('AuthorityXSLTDetailsDisplay','','','Enable XSL stylesheet control over authority details page display on intranet','Free')
        }
        );
        say_success( $out, "Added new system preference 'AuthorityXSLTDetailsDisplay'" );
    },
};
