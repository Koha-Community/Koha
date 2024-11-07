use Modern::Perl;
use Koha::Installer::Output qw(say_warning say_success say_info);

return {
    bug_number  => "36120",
    description => "Add pickup location to bookings",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'bookings', 'pickup_library_id' ) ) {
            $dbh->do(
                q{
              ALTER TABLE bookings
              ADD COLUMN `pickup_library_id` varchar(10) DEFAULT NULL COMMENT 'Identifier for booking pickup library' AFTER `item_id`
                }
                ) == 1
                && say_success( $out, "Added column 'bookings.pickup_library_id'" );

            my $updated = $dbh->do(
                q{UPDATE bookings JOIN items ON bookings.item_id = items.itemnumber SET bookings.pickup_library_id = items.homebranch }
            );

            if ( $updated != '0E0' ) {
                say_success( $out, "Set $updated existing bookings pickup location to item homebranch" );
            } else {
                say_info( $out, "No bookings found that need updating to include a pickup library" );
            }

            $updated = $dbh->do(
                q{UPDATE bookings JOIN items ON bookings.item_id = items.itemnumber SET pickup_library_id = items.holdingbranch WHERE pickup_library_id IS NULL}
            );

            if ( $updated != '0E0' ) {
                say_success(
                    $out,
                    "Set $updated existing bookings pickup location to item holdingbranch where items.homebranch was null"
                );
            }

            my ($firstBranch) = $dbh->selectrow_array(q{SELECT branchcode FROM branches LIMIT 1});
            $updated = $dbh->do(
                q{UPDATE bookings SET pickup_library_id = ? WHERE pickup_library_id IS NULL}, undef,
                $firstBranch
            );

            if ( $updated != '0E0' ) {
                say_warning(
                    $out,
                    "Some $updated bookings still had a null pickup location value so we have set them to $firstBranch"
                );
            }

            $dbh->do(
                q{
              ALTER TABLE bookings
              MODIFY pickup_library_id varchar(10) NOT NULL COMMENT 'Identifier for booking pickup library'
          }
            ) == 1 && say_success( $out, "Updated column 'bookings.pickup_library_id' to NOT NULL" );
        }

        unless ( foreign_key_exists( 'bookings', 'bookings_ibfk_4' ) ) {
            $dbh->do(
                q{
                    ALTER TABLE bookings
                    ADD CONSTRAINT `bookings_ibfk_4` FOREIGN KEY (`pickup_library_id`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
                }
                ) == 1
                && say_success( $out, "Added foreign key 'bookings_ibfk_4' to column 'bookings.pickup_library_id'" );
        }
    },
};
