$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    unless ( TableExists('advanced_editor_macros') ) {
        $dbh->do(q|
            CREATE TABLE advanced_editor_macros (
            id INT(11) NOT NULL AUTO_INCREMENT,
            name varchar(80) NOT NULL,
            macro longtext NULL,
            borrowernumber INT(11) default NULL,
            shared TINYINT(1) default 0,
            PRIMARY KEY (id),
            CONSTRAINT borrower_macro_fk FOREIGN KEY ( borrowernumber ) REFERENCES borrowers ( borrowernumber ) ON UPDATE CASCADE ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;|
        );
    }
    $dbh->do(q|
        INSERT IGNORE INTO permissions (module_bit, code, description)
        VALUES (9, 'create_shared_macros', 'Create public macros')
    |);
    $dbh->do(q|
        INSERT IGNORE INTO permissions (module_bit, code, description)
        VALUES (9, 'delete_shared_macros', 'Delete public macros')
    |);

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 17682 - Add macros db table and permissions)\n";
}
