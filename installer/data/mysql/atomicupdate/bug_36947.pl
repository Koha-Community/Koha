use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "36947",
    description => "Add FacetSortingLocale system preference for locale-based facet sorting",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences (`variable`,`value`,`options`,`explanation`,`type`)
            VALUES ('FacetSortingLocale','default','',
                'Choose the locale for sorting facet names when FacetOrder is set to Alphabetical. This enables proper Unicode-aware sorting of accented characters and locale-specific alphabetical ordering.',
                'Choice')
        }
        );

        say_success( $out, "Added new system preference 'FacetSortingLocale'" );
    },
};
