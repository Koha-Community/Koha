#! /usr/bin/perl
use strict;
use warnings;
use C4::Context;
my $dbh=C4::Context->dbh;
$dbh->do("ALTER TABLE issuingrules ADD 
		COLUMN `finedays` int(11) default NULL AFTER `fine`,
		COLUMN `renewalsallowed` smallint(6) default NULL, 
		COLUMN `reservesallowed` smallint(6) default NULL,
		");
$sth = $dbh->prepare("SELECT itemtype, renewalsallowed FROM itemtypes");
$sth->execute();

my $sthupd = $dbh->prepare("UPDATE issuingrules SET renewalsallowed = ? WHERE itemtype = ?");
    
while(my $row = $sth->fetchrow_hashref){
      $sthupd->execute($row->{renewalsallowed}, $row->{itemtype});
}
    
$dbh->do('ALTER TABLE itemtypes DROP COLUMN `renewalsallowed`;');
    
print "Upgrade done (Adding finedays renewalsallowed, and reservesallowed fields in issuingrules table)\n";
