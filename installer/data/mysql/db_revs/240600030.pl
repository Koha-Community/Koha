use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

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

        my $after =
            'AFTER' . ( column_exists( 'bookings', 'modification_date' ) ? q{`modification_date`} : q{`end_date`} );
        my $statement = <<~"SQL";
            ALTER TABLE `bookings`
            ADD COLUMN `status` ENUM('new', 'cancelled', 'completed') NOT NULL DEFAULT 'new' COMMENT 'current status of the booking' $after;
        SQL
        $dbh->do($statement);
        say_success( $out, q{Added column 'bookings.status'} );
    },
};
