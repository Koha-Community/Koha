#!/usr/bin/perl

use strict;
use warnings;
use C4::Context;

my $dbh = C4::Context->dbh;

my $DBversion = "3.21.00.XXX";
#if ( CheckVersion($DBversion) ) {
    $dbh->do(q{
        ALTER TABLE itemtypes
            ADD hideinopac TINYINT(1) NOT NULL DEFAULT 0 AFTER sip_media_type,
            ADD searchcategory VARCHAR(80) DEFAULT NULL AFTER hideinopac;
    });
    print "Upgrade to $DBversion done (Bug 10937 - Option to hide and group itemtypes from advanced search)\n";
#    SetVersion($DBversion);
#}
