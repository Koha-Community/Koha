use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "41996",
    description => "Add invoicenumber column to edifact_errors for per-invoice error filtering",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( !column_exists( 'edifact_errors', 'invoicenumber' ) ) {
            $dbh->do(
                q{
                ALTER TABLE edifact_errors
                ADD COLUMN invoicenumber varchar(48) DEFAULT NULL
                AFTER message_id
            }
            );
            say_success( $out, "Added invoicenumber column to edifact_errors" );

            $dbh->do(
                q{
                ALTER TABLE edifact_errors
                ADD INDEX message_id_invoicenumber (message_id, invoicenumber)
            }
            );
            say_success( $out, "Added index message_id_invoicenumber to edifact_errors" );
        } else {
            say_info( $out, "Column invoicenumber already exists in edifact_errors" );
        }
    },
};
