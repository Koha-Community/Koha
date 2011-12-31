#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use strict;
use warnings;
use Test::More tests => 3;
use C4::Context;
use C4::Heading;
use MARC::Record;
use MARC::Field;
use C4::Linker::FirstMatch;


BEGIN {
        use_ok('C4::Linker');
}
my $dbh = C4::Context->dbh;

my $query = "SELECT authid, marc FROM auth_header LIMIT 1;";
my $sth = $dbh->prepare($query);
$sth->execute();
my ($authid, $marc) = $sth->fetchrow_array();
SKIP: {
    skip "No authorities", 2 unless defined $authid;
    my $linker = C4::Linker::FirstMatch->new();
    my $auth = MARC::Record->new_from_usmarc($marc);
    my $fieldmatch;
    if (C4::Context->preference('MARCFlavour') eq 'UNIMARC') {
        $fieldmatch = '2..';
    } else {
        $fieldmatch = '1..';
    }
    my $bibfield = $auth->field($fieldmatch);
    my $tag = $bibfield->tag();
    $tag =~ s/^./6/;
    $bibfield->update(tag => $tag);
    my $heading;
    ok(defined ($heading = C4::Heading->new_from_bib_field($bibfield, '')), "Creating heading from bib field");

    my $authmatch;
    my $fuzzy;
    ($authmatch, $fuzzy) = $linker->get_link($heading);
    is($authmatch, $authid, "Matched existing heading");
}
