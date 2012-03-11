#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;

use Test::More tests => 3;
use C4::Context;

BEGIN {
        use_ok('C4::Heading');
}

SKIP: {
    skip "MARC21 heading tests not applicable to UNIMARC", 2 if C4::Context->preference('marcflavour') eq 'UNIMARC';
    my $field = MARC::Field->new( '650', ' ', '0', a => 'Uncles', x => 'Fiction' );
    my $heading = C4::Heading->new_from_bib_field($field);
    is($heading->display_form(), 'Uncles--Fiction', 'Display form generation');
    is($heading->search_form(), 'Uncles generalsubdiv Fiction', 'Search form generation');
}
