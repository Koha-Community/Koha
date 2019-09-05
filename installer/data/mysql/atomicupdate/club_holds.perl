$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do(q|
        CREATE TABLE IF NOT EXISTS club_holds (
            id        INT(11) NOT NULL AUTO_INCREMENT,
            club_id   INT(11) NOT NULL, -- id for the club the hold was generated for
            biblio_id INT(11) NOT NULL, -- id for the bibliographic record the hold has been placed against
            item_id   INT(11) NULL DEFAULT NULL, -- If item-level, the id for the item the hold has been placed agains
            date_created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Timestamp for the placed hold
            PRIMARY KEY (id),
            -- KEY club_id (club_id),
            CONSTRAINT clubs_holds_ibfk_1 FOREIGN KEY (club_id)   REFERENCES clubs  (id) ON DELETE CASCADE ON UPDATE CASCADE,
            CONSTRAINT clubs_holds_ibfk_2 FOREIGN KEY (biblio_id) REFERENCES biblio (biblionumber) ON DELETE CASCADE ON UPDATE CASCADE,
            CONSTRAINT clubs_holds_ibfk_3 FOREIGN KEY (item_id)   REFERENCES items  (itemnumber) ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    |);

    $dbh->do(q|
        CREATE TABLE IF NOT EXISTS club_holds_to_patron_holds (
            id              INT(11) NOT NULL AUTO_INCREMENT,
            club_hold_id    INT(11) NOT NULL,
            patron_id       INT(11) NOT NULL,
            hold_id         INT(11),
            error_code      ENUM ( 'damaged', 'ageRestricted', 'itemAlreadyOnHold',
                                'tooManyHoldsForThisRecord', 'tooManyReservesToday',
                                'tooManyReserves', 'notReservable', 'cannotReserveFromOtherBranches',
                                'libraryNotFound', 'libraryNotPickupLocation', 'cannotBeTransferred'
                            ) NULL DEFAULT NULL,
            error_message   varchar(100) NULL DEFAULT NULL,
            PRIMARY KEY (id),
            -- KEY club_hold_id (club_hold_id),
            CONSTRAINT clubs_holds_paton_holds_ibfk_1 FOREIGN KEY (club_hold_id) REFERENCES club_holds (id) ON DELETE CASCADE ON UPDATE CASCADE,
            CONSTRAINT clubs_holds_paton_holds_ibfk_2 FOREIGN KEY (patron_id) REFERENCES borrowers (borrowernumber) ON DELETE CASCADE ON UPDATE CASCADE,
            CONSTRAINT clubs_holds_paton_holds_ibfk_3 FOREIGN KEY (hold_id) REFERENCES reserves (reserve_id) ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    |);

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 19618 - add club_holds tables)\n";
}
