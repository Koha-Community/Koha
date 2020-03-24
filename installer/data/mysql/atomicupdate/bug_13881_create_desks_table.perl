$DBversion = 'XXX';
if( CheckVersion( $DBversion ) ) {
    $dbh->do(qq{
             CREATE TABLE desks ( -- desks available in a library
             desk_id int(11) NOT NULL auto_increment, -- unique identifier added by Koha
             desk_name varchar(100) NOT NULL default '', -- name of the desk
             branchcode varchar(10) NOT NULL,       -- library the desk is located at
             PRIMARY KEY  (desk_id),
             KEY `fk_desks_branchcode` (branchcode),
             CONSTRAINT `fk_desks_branchcode` FOREIGN KEY (branchcode) REFERENCES branches (branchcode) ON DELETE CASCADE ON UPDATE CASCADE
             ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

             });
    SetVersion( $DBversion );
    print "Upgrade to $DBversion done (Bug 13881 - Add desk management)\n";
}
