use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "39075",
    description => "Follow up for bug 34587 to fix incorrect default values for timestamps",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( TableExists('erm_counter_files') ) {
            if ( column_exists( 'erm_counter_files', 'date_uploaded' ) ) {
                $dbh->do(
                    q{
                    ALTER TABLE erm_counter_files CHANGE COLUMN date_uploaded date_uploaded timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'counter file upload date'
                }
                );
                say_success(
                    $out,
                    "Successfully corrected incorrect default value for 'erm_counter_files.date_uploaded"
                );
            }
        }

        if ( TableExists('erm_counter_logs') ) {
            if ( column_exists( 'erm_counter_logs', 'importdate' ) ) {
                $dbh->do(
                    q{
                    ALTER TABLE erm_counter_logs CHANGE COLUMN importdate importdate timestamp NOT NULL DEFAULT current_timestamp() COMMENT 'counter file import date'
                }
                );
                say_success( $out, "Successfully corrected incorrect default value for 'erm_counter_logs.importdate" );
            }
        }
    },
};
