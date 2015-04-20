$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    $dbh->do("
        CREATE TABLE `message_queue_items` ( -- items linked to the message_queue
            `id` int(12) NOT NULL auto_increment, -- unique identifier assigned by Koha
            `issue_id` int(12) DEFAULT NULL, -- foreign key to the issue table.
            `letternumber` int(1) DEFAULT NULL, -- for which overdue letter this item was notified by
            `itemnumber` int(11) NOT NULL, -- foreign key from the items table, links transaction to the notified instrument
            `branch` varchar(10) NOT NULL, -- foreign key, branch related to the item
            `message_id` int(11) NOT NULL, -- foreign key to the message_queue
            PRIMARY KEY  (`id`),
            FOREIGN KEY (message_id) REFERENCES message_queue(message_id) ON DELETE CASCADE ON UPDATE CASCADE,
            UNIQUE KEY `no_duplicate_item_per_message` (`message_id`,`itemnumber`),
            KEY `itemnumber_idx` (`itemnumber`),
            KEY `issue_id_idx` (`issue_id`),
            KEY `branch_idx` (`branch`)
        )   ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;"
    );

    $dbh->do("
        CREATE TABLE `overdue_calendar_weekdays` (
            `id` int(11) NOT NULL auto_increment,
            `branchcode` varchar(10) NOT NULL default '',
            `weekdays` varchar(20) NOT NULL,
            PRIMARY KEY  (`id`),
            UNIQUE KEY `branchcode_idx` (`branchcode`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;"
    );
    
    $dbh->do("
        CREATE TABLE `overdue_calendar_exceptions` (
            `id` int(11) NOT NULL auto_increment,
            `branchcode` varchar(10) NOT NULL default '',
            `exceptiondate` date NOT NULL,
            PRIMARY KEY  (`id`),
            UNIQUE KEY `no_sameday_for_branch` (`branchcode`,`exceptiondate`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;"
    );

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (KD-2292 - Overduemessages for sending letters)\n";
}
