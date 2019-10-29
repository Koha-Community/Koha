$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    if( !TableExists( 'return_claims' ) ) {
        $dbh->do(q{
            CREATE TABLE return_claims (
                id int(11) auto_increment,
                itemnumber int(11) NOT NULL,
                issue_id int(11) NULL DEFAULT NULL,
                borrowernumber int(11) NOT NULL,
                notes MEDIUMTEXT DEFAULT NULL,
                created_on TIMESTAMP NULL,
                created_by int(11) NULL DEFAULT NULL,
                updated_on TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
                updated_by int(11) NULL DEFAULT NULL,
                resolution  varchar(80) NULL DEFAULT NULL,
                resolved_on TIMESTAMP NULL DEFAULT NULL,
                resolved_by int(11) NULL DEFAULT NULL,
                PRIMARY KEY (`id`),
                KEY `itemnumber` (`itemnumber`),
                CONSTRAINT UNIQUE `issue_id` ( issue_id ),
                CONSTRAINT `issue_id` FOREIGN KEY (`issue_id`) REFERENCES `issues` (`issue_id`) ON DELETE SET NULL ON UPDATE CASCADE,
                CONSTRAINT `rc_items_ibfk` FOREIGN KEY (`itemnumber`) REFERENCES `items` (`itemnumber`) ON DELETE CASCADE ON UPDATE CASCADE,
                CONSTRAINT `rc_borrowers_ibfk` FOREIGN KEY (`borrowernumber`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE CASCADE ON UPDATE CASCADE,
                CONSTRAINT `rc_created_by_ibfk` FOREIGN KEY (`created_by`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE,
                CONSTRAINT `rc_updated_by_ibfk` FOREIGN KEY (`updated_by`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE,
                CONSTRAINT `rc_resolved_by_ibfk` FOREIGN KEY (`resolved_by`) REFERENCES `borrowers` (`borrowernumber`) ON DELETE SET NULL ON UPDATE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        });
    }

    $dbh->do(q{
        INSERT IGNORE INTO systempreferences ( `variable`, `value`, `options`, `explanation`, `type` ) VALUES
        ('ClaimReturnedChargeFee', 'ask', 'ask|charge|no_charge', 'Controls whether or not a lost item fee is charged for return claims', 'Choice'),
        ('ClaimReturnedLostValue', '', '', 'Sets the LOST AV value that represents "Claims returned" as a lost value', 'Free'),
        ('ClaimReturnedWarningThreshold', '', '', 'Sets the number of return claims past which the librarian will be warned the patron has many return claims', 'Integer');
    });

    $dbh->do(q{
        INSERT IGNORE INTO authorised_value_categories ( category_name ) VALUES
            ('RETURN_CLAIM_RESOLUTION');
    });

    $dbh->do(q{
        INSERT IGNORE INTO `authorised_values` ( category, authorised_value, lib )
        VALUES
          ('RETURN_CLAIM_RESOLUTION', 'RET_BY_PATRON', 'Returned by patron'),
          ('RETURN_CLAIM_RESOLUTION', 'FOUND_IN_LIB', 'Found in library');
    });

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 14697 - Extend and enhance 'Claims returned' lost status)\n";
}
