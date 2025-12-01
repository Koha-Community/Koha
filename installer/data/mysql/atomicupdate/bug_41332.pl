use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "41332",
    description => "Adds new option for Greek (el) to system preference 'KohaManualLanguage'",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            UPDATE systempreferences SET options = 'el|en|ar|cs|de|es|fr|it|pt_BR|tr|zh_TW' WHERE variable = 'KohaManualLanguage'
            }
        );
        say_success( $out, "Added new option for Greek (el) to system preference 'KohaManualLanguage'" );
    },
};
