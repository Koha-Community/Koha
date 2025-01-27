use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => '37592',
    description => 'Add creation_date, modification_date fields to bookings table',
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @{$args}{qw(dbh out)};

        if ( column_exists( 'bookings', 'creation_date' ) && column_exists( 'bookings', 'modification_date' ) ) {
            say_info(
                $out,
                q{Columns 'creation_date' and 'modification_date' already exist in 'bookings' table. Skipping...}
            );

            return;
        }

        my $creation_date_statement = <<~'SQL';
            ALTER TABLE bookings ADD COLUMN creation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT 'the timestamp for when a booking was created'
        SQL
        my $modification_date_statement = <<~'SQL';
            ALTER TABLE bookings ADD COLUMN modification_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT 'the timestamp for when a booking has been updated'
        SQL
        unless ( column_exists( 'bookings', 'creation_date' ) && column_exists( 'bookings', 'modification_date' ) ) {
            $dbh->do("$creation_date_statement AFTER `end_date`");
            say_success( $out, q{Added column 'bookings.creation_date'} );

            $dbh->do("$modification_date_statement AFTER `creation_date`");
            say_success( $out, q{Added column 'bookings.modification_date'} );

            return;
        }

        if ( column_exists( 'bookings', 'creation_date' ) || column_exists( 'bookings', 'modification_date' ) ) {
            foreach my $column ( 'creation_date', 'modification_date' ) {
                if ( column_exists( 'bookings', $column ) ) {
                    next;
                }

                my $statement;
                if ( $column eq 'creation_date' ) {
                    $statement = "$creation_date_statement AFTER `end_date`";
                }

                if ( $column eq 'modification_date' ) {
                    $statement = "$modification_date_statement AFTER `creation_date`";
                }

                $dbh->do($statement);
                say_success( $out, "Added column 'bookings.$column'" );
            }
        }
    },
};
