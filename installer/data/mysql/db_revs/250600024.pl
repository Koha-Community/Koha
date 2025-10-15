use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "40070",
    description => "Add pref DisplayPublishedDate",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
            ('DisplayPublishedDate', '1', NULL, 'Display serial publisheddate on detail pages', 'YesNo')
            }
        );
        say_success( $out, "Added new system preference DisplayPublishedDate" );
    },
};
