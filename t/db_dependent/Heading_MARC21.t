#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;

use Test::More tests => 3;

BEGIN {
        use_ok('C4::Heading');
}

my $field = MARC::Field->new( '650', ' ', '0', a => 'Uncles', x => 'Fiction' );
my $heading = C4::Heading->new_from_bib_field($field);
is($heading->display_form(), 'Uncles--Fiction', 'Display form generation');
is($heading->search_form(), 'Uncles generalsubdiv Fiction', 'Search form generation');
