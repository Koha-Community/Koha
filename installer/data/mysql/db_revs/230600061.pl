use Modern::Perl;

return {
    bug_number  => "29002",
    description => "Add bookings table",
    up          => sub {
        my ($args) = @_;
        my ( $dbh, $out ) = @$args{qw(dbh out)};

        # Handle cases of roombookings plugin existing
        if ( TableExists('bookings') ) {
            if ( column_exists( 'bookings', 'bookingid' ) ) {
                my $old_rooms_table         = 'booking_rooms';
                my $old_rooms_index         = 'bookingrooms_idx';
                my $old_bookings_table      = 'bookings';
                my $old_bookings_index      = 'bookingbookings_idx';
                my $old_equipment_table     = 'booking_equipment';
                my $old_equipment_index     = 'bookingequipment_idx';
                my $old_roomequipment_table = 'booking_room_equipment';
                my $old_roomequipment_index = 'bookingroomequipment_idx';

                my $prefix = 'bws_rr_';
                our $rooms_table         = $prefix . $old_rooms_table;
                our $rooms_index         = $prefix . $old_rooms_index;
                our $bookings_table      = $prefix . $old_bookings_table;
                our $bookings_index      = $prefix . $old_bookings_index;
                our $equipment_table     = $prefix . $old_equipment_table;
                our $equipment_index     = $prefix . $old_equipment_index;
                our $roomequipment_table = $prefix . $old_roomequipment_table;
                our $roomequipment_index = $prefix . $old_roomequipment_index;

                $dbh->do(
                    qq{
                RENAME TABLE
                $old_rooms_table TO $rooms_table,
                $old_bookings_table TO $bookings_table,
                $old_equipment_table TO $equipment_table,
                $old_roomequipment_table TO $roomequipment_table
            }
                );
                $dbh->do("ALTER TABLE $rooms_table RENAME INDEX $old_rooms_index TO $rooms_index");
                $dbh->do("ALTER TABLE $bookings_table RENAME INDEX $old_bookings_index TO $bookings_index");
                $dbh->do("ALTER TABLE $equipment_table RENAME INDEX $old_equipment_index TO $equipment_index");
                $dbh->do(
                    "ALTER TABLE $roomequipment_table RENAME INDEX $old_roomequipment_index TO $roomequipment_index");

                say "Migrated room reservations plugin to it's own namespace";
                say "You MUST upgrade to the latest room reservation plugin to continue using it";
                $dbh->do(
                    "UPDATE plugin_data SET plugin_value = 0 WHERE plugin_class = 'Koha::Plugin::Com::MarywoodUniversity::RoomReservations' AND plugin_key = '__ENABLED__'"
                );

                say "Plugin disabled, please re-enable once you have upgraded it";
            }
        }

        if ( !TableExists('bookings') ) {
            $dbh->do(
                q{
                CREATE TABLE `bookings` (
                  `booking_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'primary key',
                  `patron_id` int(11) NOT NULL DEFAULT 0 COMMENT 'foreign key from the borrowers table defining which patron this booking is for',
                  `biblio_id` int(11) NOT NULL DEFAULT 0 COMMENT 'foreign key from the biblio table defining which bib record this booking is on',
                  `item_id` int(11) DEFAULT NULL COMMENT 'foreign key from the items table defining the specific item the patron has placed a booking for',
                  `start_date` datetime DEFAULT NULL COMMENT 'the start date of the booking',
                  `end_date` datetime DEFAULT NULL COMMENT 'the end date of the booking',
                PRIMARY KEY (`booking_id`),
                KEY `patron_id` (`patron_id`),
                KEY `biblio_id` (`biblio_id`),
                KEY `item_id` (`item_id`),
                CONSTRAINT `bookings_ibfk_1` FOREIGN KEY (`patron_id`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
                CONSTRAINT `bookings_ibfk_2` FOREIGN KEY (`biblio_id`) REFERENCES `biblio` (`biblionumber`) ON DELETE CASCADE ON UPDATE CASCADE,
                CONSTRAINT `bookings_ibfk_3` FOREIGN KEY (`item_id`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
            }
            );
            say $out "Added new table 'bookings'";
        }

        if ( !column_exists( 'items', 'bookable' ) ) {
            $dbh->do(
                q{
                ALTER TABLE items ADD COLUMN `bookable` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'boolean value defining whether this item is available for bookings or not' AFTER `barcode`
            }
            );

            say $out "Added column 'items.bookable'";
        }

        if ( !column_exists( 'deleteditems', 'bookable' ) ) {
            $dbh->do(
                q{
                ALTER TABLE deleteditems ADD COLUMN `bookable` tinyint(1) NOT NULL DEFAULT 0 COMMENT 'boolean value defining whether this item is available for bookings or not' AFTER `barcode`
            }
            );

            say $out "Added column 'deleteditems.bookable'";
        }

        $dbh->do(
            q{
          INSERT IGNORE INTO permissions (module_bit, code, description) VALUES (
            1,
            'manage_bookings',
            'Manage item bookings'
          );
        }
        );
        say $out "Added new permission 'manage_bookings'";

    },
};
