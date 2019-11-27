$DBversion = 'XXX'; # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {
    unless( TableExists( 'pseudonymized_transactions' ) ) {
        $dbh->do(q|
            CREATE TABLE `pseudonymized_transactions` (
              `id` INT(11) NOT NULL AUTO_INCREMENT,
              `hashed_borrowernumber` VARCHAR(60) NOT NULL,
              `has_cardnumber` TINYINT(1) NOT NULL DEFAULT 0,
              `title` LONGTEXT,
              `city` LONGTEXT,
              `state` MEDIUMTEXT default NULL,
              `zipcode` varchar(25) default NULL,
              `country` MEDIUMTEXT,
              `branchcode` varchar(10) NOT NULL default '',
              `categorycode` varchar(10) NOT NULL default '',
              `dateenrolled` date default NULL,
              `sex` varchar(1) default NULL,
              `sort1` varchar(80) default NULL,
              `sort2` varchar(80) default NULL,
              `datetime` datetime default NULL,
              `transaction_branchcode` varchar(10) default NULL,
              `transaction_type` varchar(16) default NULL,
              `itemnumber` int(11) default NULL,
              `itemtype` varchar(10) default NULL,
              `holdingbranch` varchar(10) default null,
              `location` varchar(80) default NULL,
              `itemcallnumber` varchar(255) default NULL,
              `ccode` varchar(80) default NULL,
              PRIMARY KEY (`id`),
              CONSTRAINT `pseudonymized_transactions_ibfk_1` FOREIGN KEY (`categorycode`) REFERENCES `categories` (`categorycode`),
              CONSTRAINT `pseudonymized_transactions_borrowers_ibfk_2` FOREIGN KEY (`branchcode`) REFERENCES `branches` (`branchcode`),
              CONSTRAINT `pseudonymized_transactions_borrowers_ibfk_3` FOREIGN KEY (`transaction_branchcode`) REFERENCES `branches` (`branchcode`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        |);
    }

    $dbh->do(q|
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
        VALUES ('Pseudonymization','0',NULL,'If enabled patrons and transactions will be copied in a separate table for statistics purpose','YesNo')
    |);
    $dbh->do(q|
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
        VALUES ('PseudonymizationPatronFields','','title,city,state,zipcode,country,branchcode,categorycode,dateenrolled,sex,sort1,sort2','Patron fields to copy to the pseudonymized_transactions table','multiple')
    |);
    $dbh->do(q|
        INSERT IGNORE INTO systempreferences (variable,value,options,explanation,type)
        VALUES ('PseudonymizationTransactionFields','','datetime,transaction_branchcode,transaction_type,itemnumber,itemtype,holdingbranch,location,itemcallnumber,ccode','Transaction fields to copy to the pseudonymized_transactions table','multiple')
    |);

    unless( TableExists( 'pseudonymized_borrower_attributes' ) ) {
        $dbh->do(q|
            CREATE TABLE pseudonymized_borrower_attributes (
              `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY, -- Row id field
              `transaction_id` int(11) NOT NULL,
              `code` varchar(10) NOT NULL,
              `attribute` varchar(255) default NULL,
              CONSTRAINT `pseudonymized_borrower_attributes_ibfk_1` FOREIGN KEY (`transaction_id`) REFERENCES `pseudonymized_transactions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
              CONSTRAINT `anonymized_borrower_attributes_ibfk_2` FOREIGN KEY (`code`) REFERENCES `borrower_attribute_types` (`code`) ON DELETE CASCADE ON UPDATE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
        |);
    }

    # Always end with this (adjust the bug info)
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 24151 - Add pseudonymized_transactions tables and sysprefs for Pseudonymization)\n";
}
