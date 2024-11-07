use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "36798",
    description => "Add 'SearchCancelledAndInvalidISBNandISSN' preference",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Do you stuffs here
        $dbh->do(
            q{
            INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` )
            VALUES ('SearchCancelledAndInvalidISBNandISSN','0',NULL,'Enable search for cancelled or invalid forms of ISBN/ISSN when performing ISBN/ISSN search (when using ES)','YesNo')
            }
        );

        say_success( $out, "Added new system preference 'SearchCancelledAndInvalidISBNandISSN'" );
    },
};
