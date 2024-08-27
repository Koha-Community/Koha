use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_failure say_success say_info);

return {
    bug_number  => '37601',
    description => 'Add status column to bookings table',
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @{$args}{qw(dbh out)};

        if ( column_exists( 'bookings', 'status' ) ) {
            say_info( $out, q{Column 'status' already exists in 'bookings' table. Skipping...} );

            return;
        }

        my $after     = 'AFTER' . ( column_exists( 'bookings', 'updated_on' ) ? q{`updated_on`} : q{`end_date`} );
        my $statement = <<~"SQL";
            ALTER TABLE `bookings`
            ADD COLUMN `status` ENUM('created', 'cancelled') NOT NULL DEFAULT 'created' COMMENT 'current status of the booking' $after;
        SQL
        if ( $dbh->do($statement) ) {
            say_success( $out, q{Added column 'bookings.status'} );
        } else {
            say_failure( $out, q{Failed to add column 'bookings.status'} );
        }
    },
};
