#!/usr/bin/perl

# small script to convert mysql tables to utf-8

use C4::Context;
use strict;

my $dbh=C4::Context->dbh();

my $database=C4::Context->config("database");
my $query="Show tables";
my $sth=$dbh->prepare($query);
$sth->execute();
while (my @table=$sth->fetchrow_array()){
    print "Altering table $table[0]\n";
    my $alter_query="ALTER TABLE $table[0] convert to CHARACTER SET UTF8 collate utf8_general_ci";
    my $sth2=$dbh->prepare($alter_query);
    $sth2->execute();
    $sth2->finish();

}
$sth->finish();
$dbh->disconnect();
