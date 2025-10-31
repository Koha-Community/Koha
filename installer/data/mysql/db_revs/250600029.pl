use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "40292",
    description => "Rename new_record_id if exists",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( column_exists( 'additional_field_values', 'new_record_id' ) ) {
            $dbh->do(
                q{ ALTER TABLE additional_field_values CHANGE COLUMN new_record_id record_id VARCHAR(11) NOT NULL DEFAULT '' COMMENT 'record_id'; }
            );

            say_success( $out, "Renamed new_record_id to record_id" );
        }
    },
};
