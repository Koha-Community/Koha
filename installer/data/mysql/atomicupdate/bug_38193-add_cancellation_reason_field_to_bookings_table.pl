use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_failure say_success say_info);

return {
    bug_number  => '38193',
    description => 'Add cancellation_reason field to bookings table',
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @{$args}{qw(dbh out)};

        if ( column_exists( 'bookings', 'cancellation_reason' ) ) {
            say_info( $out, q{Column 'cancellation_reason' already exists in 'bookings' table. Skipping...} );

            return;
        }

        my $statement = <<~"SQL";
            ALTER TABLE `bookings`
            ADD COLUMN `cancellation_reason` varchar(80) DEFAULT NULL COMMENT 'optional authorised value BOOKING_CANCELLATION' AFTER `status`;
        SQL
        if ( $dbh->do($statement) ) {
            say_success( $out, q{Added column 'bookings.cancellation_reason'} );
        } else {
            say_failure( $out, q{Failed to add column 'bookings.cancellation_reason'} );
        }
    },
};
