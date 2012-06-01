#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;
# use Test::Class::Load qw ( t/db_dependent/ );
use Test::More tests => 4;
use MARC::Record;
use C4::Biblio;
use C4::XISBN;
use Data::Dumper;
use C4::Context;

BEGIN {
	use_ok('C4::XISBN');
}

# KohaTest::clear_test_database();
# KohaTest::create_test_database();

my $isbn = '0590353403';
my $isbn2 = '0684843897';

my $marc_record=MARC::Record->new;
my $field = MARC::Field->new('020','','','a' => $isbn);
$marc_record->append_fields($field);
my($biblionumber,$biblioitemnumber) = AddBiblio($marc_record,'');

my $marc_record=MARC::Record->new;
my $field = MARC::Field->new('020','','','a' => $isbn2);
$marc_record->append_fields($field);
my($biblionumber2,$biblioitemnumber2) = AddBiblio($marc_record,'');


my $trial = C4::XISBN::get_biblionumber_from_isbn($isbn);
is($trial->[0]->{biblionumber},$biblionumber,"It gets the correct biblionumber from the only isbn we have added.");

$trial = C4::XISBN::_get_biblio_from_xisbn($isbn);
is($trial->{biblionumber},$biblionumber,"Gets biblionumber like the previous test.");

my $context = C4::Context->new();
$context->set_preference('ThingISBN','on');
diag C4::Context::preference('ThingISBN');
my $var = C4::XISBN::get_xisbns($isbn);
is($var->[0]->{biblionumber},$biblionumber2,"Gets correct biblionumber from a book with a similar isbn.");

# clean up after ourselves
DelBiblio($biblionumber);
DelBiblio($biblionumber2);