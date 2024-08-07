use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_failure say_success say_info);

return {
    bug_number  => '37592',
    description => 'Add created_at, updated_at fields to bookings table',
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @{$args}{qw(dbh out)};

        my $columns_exist_query = <<~'SQL';
            SELECT column_name
            FROM information_schema.COLUMNS
            WHERE table_name = 'bookings'
                AND column_name IN ('created_at', 'updated_at')
        SQL
        my $existing_columns = $dbh->selectcol_arrayref($columns_exist_query);
        if ( @{$existing_columns} == 2 ) {
            say_info( $out, q{Columns 'created_at' and 'updated_at' already exist in 'bookings' table. Skipping...} );

            return;
        }

        my $created_at_statement = <<~'SQL';
            ALTER TABLE bookings ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'The timestamp for when a bookings was created'
        SQL
        my $updated_at_statement = <<~'SQL';
            ALTER TABLE bookings ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'The timestamp for when a booking has been updated'
        SQL
        if ( @{$existing_columns} == 0 ) {
            if ( $dbh->do("$created_at_statement AFTER `end_date`") ) {
                say_success( $out, q{Added column 'bookings.created_at'} );
            } else {
                say_failure( $out, q{Failed to add column 'bookings.created_at': } . $dbh->errstr );
            }

            if ( $dbh->do("$updated_at_statement AFTER `created_at`") ) {
                say_success( $out, q{Added column 'bookings.updated_at'} );
            } else {
                say_failure( $out, q{Failed to add column 'bookings.updated_at': } . $dbh->errstr );
            }

            return;
        }

        if ( @{$existing_columns} == 1 ) {
            foreach my $column ( 'created_at', 'updated_at' ) {
                if ( column_exists( 'bookings', $column ) ) {
                    next;
                }

                my $statement;
                if ( $column eq 'created_at' ) {
                    $statement = "$created_at_statement AFTER `end_date`";
                }

                if ( $column eq 'updated_at' ) {
                    $statement = "$updated_at_statement AFTER `created_at`";
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
