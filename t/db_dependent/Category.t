#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use Modern::Perl;

use Test::More tests => 3;

use_ok('C4::Category');

use C4::Context;
my $dbh = C4::Context->dbh;
$dbh->{RaiseError} = 1;
$dbh->{AutoCommit} = 0;

my $sth=$dbh->prepare('
    INSERT INTO categories( categorycode, description, enrolmentperiod, enrolmentperioddate, upperagelimit, dateofbirthrequired, enrolmentfee, reservefee, hidelostitems, overduenoticerequired, category_type )
    VALUES (?,?,?,?,?,?,?,?,?,?,?)
');

my $nonexistent_categorycode = 'NONEXISTEN';
$sth->execute($nonexistent_categorycode, "Desc", 12, "2014-01-02", 99, 1, 1.5, 2.5, 0, 0, "A") || die $sth->errstr;
my @categories = C4::Category->all;
ok( @categories, 'all returns categories' );

my $match = grep {$_->{categorycode} eq $nonexistent_categorycode } @categories;
is( $match, 1, 'all returns the inserted category');

$dbh->rollback;
