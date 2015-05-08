$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    #Check if the table has already been CREATEd and possibly CREATE it
    my $dbh = C4::Context->dbh();
    my $sth = $dbh->table_info( '', '', 'floating_matrix', 'TABLE' );
    my $table = $sth->fetchrow_hashref();
    unless ($table) {
        $dbh->do("
        CREATE TABLE floating_matrix ( -- Controls should we automatically transfer Items checked in to one branch to the Item's configured normal destination
            id int(11) NOT NULL AUTO_INCREMENT, -- unique id
            from_branch varchar(10) NOT NULL, -- branch where the Item has been checked in
            to_branch varchar(10) NOT NULL, -- where the Item would normally be transferred to
            floating enum('ALWAYS','POSSIBLE','CONDITIONAL') NOT NULL DEFAULT 'ALWAYS', -- type of floating; ALWAYS just skips any transports, POSSIBLE prompts if a transport is needed, CONDITIONAL is like ALWAYS if condition is met
            condition_rules varchar(100), -- if floating = CONDITIONAL, then the special condition to trigger floating.
            CHECK ( from_branch <> to_branch ), -- a dud check, mysql does not support that
            PRIMARY KEY (`id`),
            UNIQUE KEY `floating_matrix_uniq_branches` (`from_branch`,`to_branch`),
            CONSTRAINT floating_matrix_ibfk_1 FOREIGN KEY (from_branch) REFERENCES branches (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE,
            CONSTRAINT floating_matrix_ibfk_2 FOREIGN KEY (to_branch) REFERENCES branches (`branchcode`) ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
        ");
        print "Upgrade to $DBversion done (Bug 9525 - group floating rules)\n";
    }
    else {
        print "Upgrade to $DBversion already applied (Bug 9525 - group floating rules)\n";
    }

    SetVersion( $DBversion );
}
