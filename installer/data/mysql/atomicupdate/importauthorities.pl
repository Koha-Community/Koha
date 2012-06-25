#!/usr/bin/perl

use strict;
use warnings;
use C4::Context;
my $dbh = C4::Context->dbh;

$dbh->do(
q|CREATE TABLE `import_auths` (
    import_record_id int(11) NOT NULL,
    matched_authid int(11) default NULL,
    control_number varchar(25) default NULL,
    authorized_heading varchar(128) default NULL,
    original_source varchar(25) default NULL,
    CONSTRAINT import_auths_ibfk_1 FOREIGN KEY (import_record_id)
    REFERENCES import_records (import_record_id) ON DELETE CASCADE ON UPDATE CASCADE,
    KEY matched_authid (matched_authid)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;|
);
$dbh->do("ALTER TABLE import_batches
            CHANGE COLUMN num_biblios num_records int(11) NOT NULL default 0,
            ADD COLUMN record_type enum('biblio', 'auth', 'holdings') NOT NULL default 'biblio'");
$dbh->do("UPDATE import_batches SET record_type='auth' WHERE import_batch_id IN
            (SELECT import_batch_id FROM import_records WHERE record_type='auth')");

print "Upgrade done (Added support for staging authorities)\n";
