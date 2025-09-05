use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "40665",
    description => "Add booking_id to issues and old_issues tables to link checkouts to bookings",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        if ( !column_exists( 'issues', 'booking_id' ) ) {
            $dbh->do(
                q{
                ALTER TABLE issues
                ADD COLUMN booking_id int(11) DEFAULT NULL
                COMMENT 'foreign key linking this checkout to the booking it fulfills'
                AFTER itemnumber
            }
            );

            $dbh->do(
                q{
                ALTER TABLE issues
                ADD CONSTRAINT issues_booking_id_fk
                FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
                ON DELETE SET NULL ON UPDATE CASCADE
            }
            );

            say_success( $out, "Added column 'issues.booking_id'" );
        }

        if ( !column_exists( 'old_issues', 'booking_id' ) ) {
            $dbh->do(
                q{
                ALTER TABLE old_issues
                ADD COLUMN booking_id int(11) DEFAULT NULL
                COMMENT 'foreign key linking this checkout to the booking it fulfilled'
                AFTER itemnumber
            }
            );

            $dbh->do(
                q{
                ALTER TABLE old_issues
                ADD CONSTRAINT old_issues_booking_id_fk
                FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
                ON DELETE SET NULL ON UPDATE CASCADE
            }
            );

            say_success( $out, "Added column 'old_issues.booking_id'" );
        }
    },
};
