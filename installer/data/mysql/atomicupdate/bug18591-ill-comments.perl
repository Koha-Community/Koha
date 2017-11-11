$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    unless (TableExists('illcomments')) {
        $dbh->do(q{
            CREATE TABLE illcomments (
                illcomment_id int(11) NOT NULL AUTO_INCREMENT, -- Unique ID of the comment
                illrequest_id bigint(20) unsigned NOT NULL,    -- ILL request number
                borrowernumber integer DEFAULT NULL,           -- Link to the user who made the comment (could be librarian, patron or ILL partner library)
                comment text DEFAULT NULL,                     -- The text of the comment
                timestamp timestamp DEFAULT CURRENT_TIMESTAMP, -- Date and time when the comment was made
                PRIMARY KEY  ( illcomment_id ),
                CONSTRAINT illcomments_bnfk
                  FOREIGN KEY ( borrowernumber )
                  REFERENCES  borrowers  ( borrowernumber )
                  ON UPDATE CASCADE ON DELETE CASCADE,
                CONSTRAINT illcomments_ifk
                  FOREIGN KEY (illrequest_id)
                  REFERENCES illrequests ( illrequest_id )
                  ON UPDATE CASCADE ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        });
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 18591 - Add comments to ILL requests)\n";
}
