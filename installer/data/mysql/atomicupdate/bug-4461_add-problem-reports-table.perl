$DBversion = 'XXX';  # will be replaced by the RM
if( CheckVersion( $DBversion ) ) {

    if( !TableExists( 'problem_reports' ) ){
        $dbh->do(q{ CREATE TABLE problem_reports (
            reportid int(11) NOT NULL auto_increment, -- unique identifier assigned by Koha
            title varchar(40) NOT NULL default '', -- report subject line
            content varchar(255) NOT NULL default '', -- report message content
            borrowernumber int(11) default NULL, -- the user who created the problem report
            branchcode varchar(10) NOT NULL default '', -- borrower's branch
            username varchar(75) default NULL, -- OPAC username
            problempage varchar(255) default NULL, -- page the user triggered the problem report form from
            recipient enum('admin','library') NOT NULL default 'library', -- the 'to-address' of the problem report
            created_on timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP, -- timestamp of report submission
            status varchar(1) NOT NULL default 'N', -- status of the report. N=new, V=viewed, C=closed
            PRIMARY KEY (reportid),
            CONSTRAINT problem_reports_ibfk1 FOREIGN KEY (borrowernumber) REFERENCES borrowers (borrowernumber) ON DELETE CASCADE ON UPDATE CASCADE,
            CONSTRAINT problem_reports_ibfk2 FOREIGN KEY (branchcode) REFERENCES branches (branchcode) ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci });
    }

    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 4461: Add problem reports table)\n";
}
