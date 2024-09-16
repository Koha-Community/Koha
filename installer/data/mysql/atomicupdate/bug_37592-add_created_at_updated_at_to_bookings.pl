use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_failure say_success say_info);

return {
    bug_number  => '37592',
    description => 'Add creation_date, modification_date fields to bookings table',
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @{$args}{qw(dbh out)};

        my $columns_exist_query = <<~'SQL';
            SELECT column_name
            FROM information_schema.COLUMNS
            WHERE table_name = 'bookings'
                AND column_name IN ('creation_date', 'modification_date')
        SQL
        my $existing_columns = $dbh->selectcol_arrayref($columns_exist_query);
        if ( @{$existing_columns} == 2 ) {
            say_info(
                $out,
                q{Columns 'creation_date' and 'modification_date' already exist in 'bookings' table. Skipping...}
            );

            return;
        }

        my $creation_date_statement = <<~'SQL';
            ALTER TABLE bookings ADD COLUMN creation_date DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'The datetime for when a bookings was created'
        SQL
        my $modification_date_statement = <<~'SQL';
            ALTER TABLE bookings ADD COLUMN modification_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'The datetime for when a booking has been updated'
        SQL
        if ( @{$existing_columns} == 0 ) {
            if ( $dbh->do("$creation_date_statement AFTER `end_date`") ) {
                say_success( $out, q{Added column 'bookings.creation_date'} );
            } else {
                say_failure( $out, q{Failed to add column 'bookings.creation_date': } . $dbh->errstr );
            }

            if ( $dbh->do("$modification_date_statement AFTER `creation_date`") ) {
                say_success( $out, q{Added column 'bookings.modification_date'} );
            } else {
                say_failure( $out, q{Failed to add column 'bookings.modification_date': } . $dbh->errstr );
            }

            return;
        }

        if ( @{$existing_columns} == 1 ) {
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

                if ( $dbh->do($statement) ) {
                    say_success( $out, "Added column 'bookings.$column'" );
                } else {
                    say_failure( $out, "Failed to add column 'bookings.$column': " . $dbh->errstr );
                }
            }
        }
    },
};
