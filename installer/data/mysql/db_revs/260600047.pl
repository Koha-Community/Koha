use Modern::Perl;
use C4::Installer           qw(column_exists);
use Koha::Installer::Output qw(say_success say_failure);

return {
    bug_number  => "42108",
    description => "Add run_type column to saved_sql to constrain reports to foreground or background execution",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'saved_sql', 'run_type' ) ) {
            my $ok = $dbh->do(
                q{ ALTER TABLE saved_sql
                     ADD COLUMN run_type ENUM('any','foreground','background') NOT NULL DEFAULT 'any'
                     COMMENT 'optional constraint forcing this report to always run in the foreground or always as a background job' }
            );
            if ($ok) {
                say_success( $out, "Added column 'run_type' to saved_sql" );
            } else {
                say_failure( $out, "Failed to add column 'run_type' to saved_sql: " . $dbh->errstr );
            }
        }
    },
};
