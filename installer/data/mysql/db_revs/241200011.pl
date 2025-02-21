use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "26684",
    description => "Drop marc column from auth_header",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( column_exists( 'auth_header', 'marc' ) ) {
            $dbh->do("ALTER TABLE auth_header DROP COLUMN marc");
            say_success( $out, "Removed column 'auth_header.marc'" );
        }
    },
};
