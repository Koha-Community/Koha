use Modern::Perl;
use Koha::Installer::Output qw(say_success say_failure say_info);

return {
    bug_number  => "41996",
    description => "Add invoicenumber column to edifact_errors for per-invoice error filtering",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( !column_exists( 'edifact_errors', 'invoicenumber' ) ) {
            my $ok = $dbh->do(
                q{
                    ALTER TABLE edifact_errors
                    ADD COLUMN invoicenumber varchar(48) DEFAULT NULL
                    AFTER message_id
                }
            );
            if ($ok) {
                say_success( $out, "Added invoicenumber column to edifact_errors" );
            } else {
                say_failure( $out, "Failed to add invoicenumber column to edifact_errors: " . $dbh->errstr );
            }
        } else {
            say_info( $out, "Column invoicenumber already exists in edifact_errors" );
        }

        unless ( index_exists( 'edifact_errors', 'message_id_invoicenumber' ) ) {
            my $ok = $dbh->do(
                q{
                    ALTER TABLE edifact_errors
                    ADD INDEX message_id_invoicenumber (message_id, invoicenumber)
                }
            );
            if ($ok) {
                say_success( $out, "Added index message_id_invoicenumber to edifact_errors" );
            } else {
                say_failure( $out, "Failed to add index message_id_invoicenumber to edifact_errors: " . $dbh->errstr );
            }
        } else {
            say_info( $out, "Index message_id_invoicenumber already exists on edifact_errors" );
        }
    },
};
