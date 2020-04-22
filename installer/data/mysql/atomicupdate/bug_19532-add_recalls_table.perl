$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(q{ DROP TABLE IF EXISTS recalls });
    $dbh->do(q{
        CREATE TABLE recalls (
            recall_id int(11) NOT NULL auto_increment,
            borrowernumber int(11) NOT NULL DEFAULT 0,
            recalldate datetime DEFAULT NULL,
            biblionumber int(11) NOT NULL DEFAULT 0,
            branchcode varchar(10) DEFAULT NULL,
            cancellationdate datetime DEFAULT NULL,
            recallnotes mediumtext,
            priority smallint(6) DEFAULT NULL,
            status varchar(1) DEFAULT NULL,
            timestamp timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            itemnumber int(11) DEFAULT NULL,
            waitingdate datetime DEFAULT NULL,
            expirationdate datetime DEFAULT NULL,
            old TINYINT(1) DEFAULT NULL,
            item_level_recall TINYINT(1) NOT NULL DEFAULT 0,
            PRIMARY KEY (recall_id),
            KEY borrowernumber (borrowernumber),
            KEY biblionumber (biblionumber),
            KEY itemnumber (itemnumber),
            KEY branchcode (branchcode),
            CONSTRAINT recalls_ibfk_1 FOREIGN KEY (borrowernumber) REFERENCES borrowers (borrowernumber) ON DELETE CASCADE ON UPDATE CASCADE,
            CONSTRAINT recalls_ibfk_2 FOREIGN KEY (biblionumber) REFERENCES biblio (biblionumber) ON DELETE CASCADE ON UPDATE CASCADE,
            CONSTRAINT recalls_ibfk_3 FOREIGN KEY (itemnumber) REFERENCES items (itemnumber) ON DELETE CASCADE ON UPDATE CASCADE,
            CONSTRAINT recalls_ibfk_4 FOREIGN KEY (branchcode) REFERENCES branches (branchcode) ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    });

    NewVersion( $DBversion, 19532, "Add recalls table" );
}
