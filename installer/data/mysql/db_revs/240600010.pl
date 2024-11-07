use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "34481",
    description => "Add IncludeSeeAlsoFromInSearches like IncludeSeeFromInSearches",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (`variable`,`value`,`options`,`explanation`,`type`)
            VALUES ('IncludeSeeAlsoFromInSearches','0','','Include see-also-from references in searches.','YesNo')
        }
        );

        say_success( $out, "Added new system preference 'IncludeSeeAlsoFromInSearches'" );
    },
};
