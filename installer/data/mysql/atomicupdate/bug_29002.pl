use Modern::Perl;

return {
    bug_number => "29002",
    description => "Add bookings table",
    up => sub {
        my ($args) = @_;
        my ($dbh, $out) = @$args{qw(dbh out)};
        if( !TableExists( 'bookings' ) ) {
            $dbh->do(q{
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
            });
        }
    },
}
