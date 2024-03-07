use Modern::Perl;

return {
    bug_number  => "36120",
    description => "Add pickup location to bookings",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        unless ( column_exists( 'bookings', 'pickup_library_id' ) ) {
          $dbh->do(q{
              ALTER TABLE bookings
              ADD COLUMN `pickup_library_id` varchar(10) DEFAULT NULL COMMENT 'Identifier for booking pickup library' AFTER `item_id`,
              ADD CONSTRAINT `bookings_ibfk_4` FOREIGN KEY (`pickup_library_id`) REFERENCES `branches` (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
          });

          say $out "Added column 'bookings.pickup_library_id'";
        }
    },
};
