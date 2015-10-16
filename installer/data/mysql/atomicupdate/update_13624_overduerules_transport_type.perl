#! /usr/bin/perl

use strict;
use warnings;
use C4::Context;
my $dbh=C4::Context->dbh;

print "Will do : Bug 13624 - Remove columns branchcode, categorytype from table overduerules_transport_types\n";

#if ( CheckVersion($DBversion) ) {
    $dbh->do("SET FOREIGN_KEY_CHECKS=0");
    $dbh->do("ALTER TABLE overduerules RENAME old_overduerules");
    $dbh->do("CREATE TABLE overduerules (
        `overduerules_id` int(11) NOT NULL AUTO_INCREMENT,
        `branchcode` varchar(10) NOT NULL DEFAULT '',
        `categorycode` varchar(10) NOT NULL DEFAULT '',
        `delay1` int(4) DEFAULT NULL,
        `letter1` varchar(20) DEFAULT NULL,
        `debarred1` varchar(1) DEFAULT '0',
        `delay2` int(4) DEFAULT NULL,
        `debarred2` varchar(1) DEFAULT '0',
        `letter2` varchar(20) DEFAULT NULL,
        `delay3` int(4) DEFAULT NULL,
        `letter3` varchar(20) DEFAULT NULL,
        `debarred3` int(1) DEFAULT '0',
        PRIMARY KEY (`overduerules_id`),
        UNIQUE KEY `overduerules_branch_cat` (`branchcode`,`categorycode`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
    $dbh->do("INSERT INTO overduerules(branchcode, categorycode, delay1, letter1, debarred1, delay2, debarred2, letter2, delay3, letter3, debarred3) SELECT * FROM old_overduerules");
    $dbh->do("DROP TABLE old_overduerules");
    $dbh->do("ALTER TABLE overduerules_transport_types
              ADD COLUMN overduerules_id int(11) NOT NULL");
    my $mtts = $dbh->selectall_arrayref("SELECT * FROM overduerules_transport_types", { Slice => {} });
    $dbh->do("DELETE FROM overduerules_transport_types");
    $dbh->do("ALTER TABLE overduerules_transport_types
              DROP FOREIGN KEY overduerules_fk,
              ADD FOREIGN KEY overduerules_transport_types_fk (overduerules_id) REFERENCES overduerules (overduerules_id) ON DELETE CASCADE ON UPDATE CASCADE,
              DROP COLUMN branchcode,
              DROP COLUMN categorycode");
    my $s = $dbh->prepare("INSERT INTO overduerules_transport_types (overduerules_id, id, letternumber, message_transport_type) "
                         ." VALUES((SELECT overduerules_id FROM overduerules WHERE branchcode = ? AND categorycode = ?),?,?,?)");
    foreach my $mtt(@$mtts){
        $s->execute($mtt->{branchcode}, $mtt->{categorycode}, $mtt->{id}, $mtt->{letternumber}, $mtt->{message_transport_type} );
    }
    $dbh->do("SET FOREIGN_KEY_CHECKS=1");
#    print "Upgrade to $DBversion done (Bug 13624 - Remove columns branchcode, categorytype from table overduerules_transport_types)\n";
#   SetVersion ($DBversion);
#}

print "\nDone\n";
