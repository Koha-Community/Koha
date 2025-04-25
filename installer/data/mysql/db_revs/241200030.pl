use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "38694",
    description => "Add ElasticsearchBoostFieldMatch system preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{
           INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
           ('ElasticsearchBoostFieldMatch', '0', NULL, 'Add a "match" query to es when searching, will follow indexes chosen in advanced search, or use title-cover for generic keyword or title index search', 'YesNo')
       }
        );

        say_success( $out, "Added new system preference 'ElasticsearchBoostFieldMatch'" );
    },
};
