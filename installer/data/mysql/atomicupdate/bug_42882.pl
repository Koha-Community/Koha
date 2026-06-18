use Modern::Perl;
use Koha::Installer::Output qw(say_success say_failure);

return {
    bug_number  => "42882",
    description => "Add copy_file_attrs column to file_transports",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'file_transports', 'copy_file_attrs' ) ) {
            my $ok = $dbh->do(
                q{ ALTER TABLE file_transports
                     ADD COLUMN copy_file_attrs TINYINT(1) NOT NULL DEFAULT 1 AFTER debug }
            );
            if ($ok) {
                say_success( $out, "Added column 'copy_file_attrs' to table 'file_transports'" );
            } else {
                say_failure(
                    $out,
                    "Failed to add column 'copy_file_attrs' to table 'file_transports': " . $dbh->errstr
                );
            }
        }
    },
};
