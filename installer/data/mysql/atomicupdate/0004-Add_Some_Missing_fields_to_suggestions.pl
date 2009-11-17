#!/usr/bin/perl
use strict;
use warnings;
use C4::Context;
my $dbh=C4::Context->dbh;
$dbh->do(<<SUGGESTIONS);
ALTER table suggestions 
    ADD budgetid INT(11),
    ADD branchcode VARCHAR(10) default NULL,
    ADD acceptedby INT(11) default NULL,
    ADD acceptedon date default NULL,
    ADD suggestedon date default NULL,
    ADD managedon date default NULL,
    ADD rejectedby INT(11) default NULL,
    ADD rejectedon date default NULL,
    ADD collectiontitle text default NULL,
    ADD itemtype VARCHAR(30) default NULL,
    ADD sort1 VARCHAR(80) default NULL,
    ADD sort2 VARCHAR(80) default NULL
    ;
SUGGESTIONS
print "Add some fields to suggestions";
