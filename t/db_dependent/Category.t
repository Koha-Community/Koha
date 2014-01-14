#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use strict;
use warnings;

use Test::More tests => 2;

BEGIN {
        use_ok('C4::Category');
}
use C4::Context;
my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;
$dbh->{AutoCommit} = 0;

my $sth=$dbh->prepare("INSERT INTO categories  (categorycode,description,enrolmentperiod,enrolmentperioddate,upperagelimit,dateofbirthrequired,
enrolmentfee,reservefee,hidelostitems,overduenoticerequired,category_type) values (?,?,?,?,?,?,?,?,?,?,?)");
$sth->execute("test", "Desc", 12, "2014-01-02", 99, 1, 1.5, 2.5, 0, 0, "A") || die $sth->errstr;
ok( my @categories = C4::Category->all);

$dbh->rollback;
