use Modern::Perl;

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
              ADD COLUMN `pickup_library_id` varchar(10) DEFAULT NULL COMMENT 'Identifier for booking pickup library' AFTER `item_id`,
              ADD CONSTRAINT `bookings_ibfk_4` FOREIGN KEY (`pickup_library_id`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
          }
            );

            say $out "Added column 'bookings.pickup_library_id'";

            $dbh->do(
                q{UPDATE bookings JOIN items ON bookings.item_id = items.itemnumber SET bookings.pickup_library_id = items.homebranch }
            );

            say $out "Set existing bookings pickup location to item homebranch";

            $dbh->do(
                q{
              ALTER TABLE bookings
              MODIFY pickup_library_id varchar(10) NOT NULL COMMENT 'Identifier for booking pickup library'
          }
            );

            say $out "Set pickup_library_id to NOT NULL";
        }
    },
};
