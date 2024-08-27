use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_failure say_success say_info);

return {
    bug_number  => '37592',
    description => 'Add created_on, updated_on fields to bookings table',
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @{$args}{qw(dbh out)};

        my $columns_exist_query = <<~'SQL';
            SELECT column_name
            FROM information_schema.COLUMNS
            WHERE table_name = 'bookings'
                AND column_name IN ('created_on', 'updated_on')
        SQL
        my $existing_columns = $dbh->selectcol_arrayref($columns_exist_query);
        if ( @{$existing_columns} == 2 ) {
            say_info( $out, q{Columns 'created_on' and 'updated_on' already exist in 'bookings' table. Skipping...} );

            return;
        }

        my $created_on_statement = <<~'SQL';
            ALTER TABLE bookings ADD COLUMN created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'The timestamp for when a bookings was created'
        SQL
        my $updated_on_statement = <<~'SQL';
            ALTER TABLE bookings ADD COLUMN updated_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'The timestamp for when a booking has been updated'
        SQL
        if ( @{$existing_columns} == 0 ) {
            if ( $dbh->do("$created_on_statement AFTER `end_date`") ) {
                say_success( $out, q{Added column 'bookings.created_on'} );
            } else {
                say_failure( $out, q{Failed to add column 'bookings.created_on': } . $dbh->errstr );
            }

            if ( $dbh->do("$updated_on_statement AFTER `created_on`") ) {
                say_success( $out, q{Added column 'bookings.updated_on'} );
            } else {
                say_failure( $out, q{Failed to add column 'bookings.updated_on': } . $dbh->errstr );
            }

            return;
        }

        if ( @{$existing_columns} == 1 ) {
            foreach my $column ( 'created_on', 'updated_on' ) {
                if ( column_exists( 'bookings', $column ) ) {
                    next;
                }

                my $statement;
                if ( $column eq 'created_on' ) {
                    $statement = "$created_on_statement AFTER `end_date`";
                }

                if ( $column eq 'updated_on' ) {
                    $statement = "$updated_on_statement AFTER `created_on`";
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
