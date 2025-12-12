use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "41287",
    description => "Add option for stringwise sorting of facets",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences
            ( variable, value, options, explanation, type ) VALUES
            ('FacetOrder','Alphabetical','Alphabetical|Usage|Stringwise','Specify the order of facets within each category','Choice')
        }
        );
        $dbh->do(
            q{
            UPDATE systempreferences
            SET options = 'Alphabetical|Usage|Stringwise'
            WHERE variable = 'FacetOrder'
        }
        );

        say $out "Added new 'Stringwise' option to system preference 'FacetOrder'";
    },
};
